import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'player.dart'; // Importing Player class from player.dart
import 'edit_team_page.dart';

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

  late List<Player> _addedPlayers = []; // List to track added players

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
    'Any',
    '10.0',
    '9.5',
    '9.0',
    '8.5',
    '8.0',
    '7.5',
    '7.0',
    '6.5',
    '6.0',
    '5.5',
    '5.0',
    '4.5'
  ];

  List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  List<bool> _isSelected = [];

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.positionSelected;
    _searchPlayers();
    _filteredPlayers = _players; // Initialize _filteredPlayers with _players
  }

  void _confirmSelection(BuildContext context) {
    List<Player> selectedPlayers = [];
    for (int i = 0; i < _filteredPlayers.length; i++) {
      if (_isSelected[i]) {
        selectedPlayers.add(_filteredPlayers[i]);
      }
    }
    Navigator.pop(context, selectedPlayers); // Pass back the selected players
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
            _buildPositionButtons(),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Nationality',
              value: _selectedNationality,
              items: _nationalities,
              onChanged: (value) {
                setState(() {
                  _selectedNationality = value!;
                });
                _applyFilters();
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Max Price',
              value: _selectedPrice,
              items: _prices,
              onChanged: (value) {
                setState(() {
                  _selectedPrice = value!;
                });
                _applyFilters();
              },
            ),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 20),
            _buildPlayerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['GK', 'DF', 'MF', 'FW'].map((position) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPosition = position;
            });
            _applyFilters();
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _selectedPosition == position ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                position,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _applyFilters,
          icon: Icon(Icons.search),
          label: Text('Search'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _confirmSelection(context);
          },
          icon: Icon(Icons.check),
          label: Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildPlayerList() {
    if (_filteredPlayers.isEmpty) {
      return Text('No players available.');
    } else {
      return Container(
        height: 500, // Specify a fixed height for the ListView
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _filteredPlayers.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: ListTile(
                title: Text(_filteredPlayers[index].playerName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Position: ${_filteredPlayers[index].position}'),
                    Text('Goals: ${_filteredPlayers[index].goals}'),
                    if (_filteredPlayers[index].assists.isNotEmpty)
                      Text('Assists: ${_filteredPlayers[index].assists}'),
                    if (_filteredPlayers[index].cleanSheets.isNotEmpty)
                      Text(
                          'Clean sheets: ${_filteredPlayers[index].cleanSheets}'),
                    if (_filteredPlayers[index].points.isNotEmpty)
                      Text('Points: ${_filteredPlayers[index].points}'),
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
      );
    }
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

        setState(() {
          _isSelected = List<bool>.filled(_players.length, false);
          _applyFilters();
        });
      }
    } catch (error) {
      print("Error retrieving data: $error");
    }
  }

  void _applyFilters() {
    List<Player> filteredPlayers = _players.where((player) {
      bool matches = true;
      if (_selectedPosition.isNotEmpty) {
        matches = player.position == _selectedPosition;
      }
      if (_selectedPrice != 'Any' &&
          double.parse(player.price) > double.parse(_selectedPrice)) {
        matches = false;
      }
      if (_selectedNationality != 'Any' &&
          player.team != _selectedNationality) {
        matches = false;
      }
      return matches;
    }).toList();

    setState(() {
      _filteredPlayers = filteredPlayers;
      _isSelected = List<bool>.filled(_filteredPlayers.length, false);
    });
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSelected[index] = !_isSelected[index];
                });
                Navigator.of(context).pop();
              },
              child: Text(_isSelected[index] ? 'Deselect' : 'Select'),
            ),
          ],
        );
      },
    );
  }
}
