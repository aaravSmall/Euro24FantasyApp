import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'player.dart'; // Importing Player class from player.dart

class SearchPlayerPage extends StatefulWidget {
  final ValueChanged<String>? onPlayerSelected;
  final String positionSelected;

  SearchPlayerPage(
      {Key? key, this.onPlayerSelected, required this.positionSelected})
      : super(key: key);

  @override
  _SearchPlayerPageState createState() => _SearchPlayerPageState();
}

class _SearchPlayerPageState extends State<SearchPlayerPage> {
  String _selectedNationality = 'Any';
  String _selectedPrice = '10.0';
  String _selectedPosition = '';

  final List<String> _nationalities = [
    'Any',
    'Scotland',
    'Switzerland',
    'Spain',
    'Croatia',
    'Italy',
    'Albania',
    'Slovenia',
    'Denmark',
    'Serbia',
    'Germany',
    'England',
    'Netherlands',
    'France',
    'Poland',
    'Hungary',
    'Austria',
    'Ukraine',
    'Belgium',
    'Romania',
    'Portugal',
    'Czech Republic',
    'Georgia',
    'Turkey',
    'Slovakia'
  ];

  final List<String> _prices = [
    '10.0',
    '9.5',
    '9.0',
    '8.5',
    '8.0',
    '7.5',
    'Any',
    '7.0',
    '6.5',
    '6.0',
    '5.5',
    '5.0',
    '4.5'
  ];

  final List<String> _positions = [
    'FW',
    'DF',
    'MF',
    'GK',
  ];

  List<bool> _isSelectedPosition = [];

  List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  List<bool> _isSelected = [];

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.positionSelected;
    _isSelectedPosition = List<bool>.filled(_positions.length, false);
    _searchPlayers();
    _filteredPlayers = _players; // Initialize _filteredPlayers with _players
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Players'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedNationality,
              onChanged: (newValue) {
                setState(() {
                  _selectedNationality = newValue!;
                });
                _applyFilters();
              },
              items: _nationalities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Nationality',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPrice,
              onChanged: (newValue) {
                setState(() {
                  _selectedPrice = newValue!;
                });
                _applyFilters();
              },
              items: _prices.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Max Price',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Search'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _confirmSelection(context);
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _filteredPlayers.isEmpty
                ? Text('No players available.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredPlayers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(_filteredPlayers[index].playerName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Position: ${_filteredPlayers[index].position}'),
                              Text('Goals: ${_filteredPlayers[index].goals}'),
                              if (_filteredPlayers[index].assists.isNotEmpty)
                                Text(
                                    'Assists: ${_filteredPlayers[index].assists}'),
                              if (_filteredPlayers[index]
                                  .cleanSheets
                                  .isNotEmpty)
                                Text(
                                    'Clean sheets: ${_filteredPlayers[index].cleanSheets}'),
                              if (_filteredPlayers[index].points.isNotEmpty)
                                Text(
                                    'Points: ${_filteredPlayers[index].points}'),
                              Text('Price: ${_filteredPlayers[index].price}'),
                            ],
                          ),
                          onTap: () {
                            _showPlayerDetails(context, index);
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _confirmSelection(BuildContext context) {
    List<String> selectedPlayers = [];
    for (int i = 0; i < _filteredPlayers.length; i++) {
      if (_isSelected[i]) {
        selectedPlayers.add(_filteredPlayers[i].playerName);
      }
    }
    widget.onPlayerSelected?.call(selectedPlayers.join(", "));
    Navigator.pop(context);
  }

  void _searchPlayers() async {
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.reference();

    try {
      final DatabaseEvent event = await _databaseReference.once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> playersData = data.values.toList();

        // Debug: Log the entire data fetched from Firebase
        print("Data fetched from Firebase: $playersData");
        //commit

        _players.clear();
        for (var item in playersData) {
          if (item is Map<dynamic, dynamic>) {
            _players.add(Player(
              playerName: item['Player'],
              position: item['Position'],
              goals: item['Goals'],
              assists: item['Assists'] ?? '0',
              cleanSheets: item['Clean sheets'] ?? '0',
              points: item['Points'] ?? '0',
              price: item['Price'],
              redCards: item['Red Cards'] ?? '0',
              team: item['Team'],
              yellowCards: item['Yellow Cards'] ?? '0',
            ));
          }
        }

        print("Players retrieved: ${_players.length}");
        for (var player in _players) {
          print(
              "Player: ${player.playerName}, Position: ${player.position}, Price: ${player.price}");
        }

        setState(() {
          _isSelected = List<bool>.filled(_players.length, false);
          _applyFilters();
        });
      } else {
        print("No players available.");
      }
    } catch (error) {
      print("Error retrieving data: $error");
    }
  }

  void _applyFilters() {
    List<Player> filteredPlayers;

    if (_selectedPosition.isEmpty &&
        _selectedPrice == 'Any' &&
        _selectedNationality == 'Any') {
      filteredPlayers = _players;
    } else {
      filteredPlayers = _players.where((player) {
        bool matches = true;
        if (_selectedPosition.isNotEmpty &&
            player.position != _selectedPosition) {
          matches = false;
        }
        if (_selectedPrice.isNotEmpty &&
            _selectedPrice != 'Any' &&
            double.parse(player.price) > double.parse(_selectedPrice)) {
          matches = false;
        }
        if (_selectedNationality.isNotEmpty &&
            _selectedNationality != 'Any' &&
            player.team != _selectedNationality) {
          matches = false;
        }
        return matches;
      }).toList();
    }

    setState(() {
      _filteredPlayers = filteredPlayers;
      _isSelected = List<bool>.filled(_filteredPlayers.length, false);
    });

    // Debug output
    print("Filtered players: ${_filteredPlayers.length}");
    for (var player in _filteredPlayers) {
      print(
          "Player: ${player.playerName}, Position: ${player.position}, Price: ${player.price}");
    }
  }

  void _showPlayerDetails(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_filteredPlayers[index].playerName),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Position: ${_filteredPlayers[index].position}'),
              Text('Goals: ${_filteredPlayers[index].goals}'),
              if (_filteredPlayers[index].assists.isNotEmpty)
                Text('Assists: ${_filteredPlayers[index].assists}'),
              if (_filteredPlayers[index].cleanSheets.isNotEmpty)
                Text('Clean sheets: ${_filteredPlayers[index].cleanSheets}'),
              if (_filteredPlayers[index].points.isNotEmpty)
                Text('Points: ${_filteredPlayers[index].points}'),
              Text('Price: ${_filteredPlayers[index].price}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SearchPlayerPage(positionSelected: "FW"), // Example position
  ));
}
