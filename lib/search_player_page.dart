import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'player.dart'; // Importing Player class from player.dart

class SearchPlayerPage extends StatefulWidget {
  final ValueChanged<String>? onPlayerSelected;
  final String positionSelected;

  SearchPlayerPage({Key? key, this.onPlayerSelected, required this.positionSelected}) : super(key: key);
  

  @override
  _SearchPlayerPageState createState() => _SearchPlayerPageState();
}

class _SearchPlayerPageState extends State<SearchPlayerPage> {
  String _selectedNationality = '';
  String _selectedPrice = '';
  String _selectedPosition = '';

  final List<String> _nationalities = [
    'Any', 'Scotland', 'Switzerland', 'Spain', 'Croatia', 'Italy', 'Albania', 'Slovenia', 'Denmark',
    'Serbia', 'Germany', 'England', 'Netherlands', 'France', 'Poland', 'Hungary', 'Austria', 'Ukraine',
    'Belgium', 'Romania', 'Portugal', 'Czech Republic', 'Georgia', 'Turkey', 'Slovakia'
  ];

  final List<String> _prices = [
    'Any', '10.0', '9.5', '9.0', '8.5', '8.0', '7.5', '7.0', '6.5', '6.0', '5.5', '5.0', '4.5'
  ];

  final List<String> _positions = ['Any', 'FW', 'MF', 'DF', 'GK'];

  List<Player> _players = [];
  List<bool> _isSelected = [];

  @override
  void initState() {
    super.initState();
    _isSelected = List<bool>.filled(_players.length, false);
    _selectedPosition = _positions.contains(widget.positionSelected) ? widget.positionSelected : _positions.first;
    if (_selectedPosition != 'SUB') {
      _positions.remove(widget.positionSelected);
    }
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
              value: _selectedNationality.isNotEmpty ? _selectedNationality : null,
              onChanged: (newValue) {
                setState(() {
                  _selectedNationality = newValue!;
                });
              },
              items: _nationalities.map<DropdownMenuItem<String>>((String value) {
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
              value: _selectedPrice.isNotEmpty ? _selectedPrice : null,
              onChanged: (newValue) {
                setState(() {
                  _selectedPrice = newValue!;
                });
              },
              items: _prices.map<DropdownMenuItem<String>>((String value) {
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
            if (_selectedPosition == 'Any' || _selectedPosition == 'SUB')
              DropdownButtonFormField<String>(
                value: _selectedPosition.isNotEmpty ? _selectedPosition : null,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPosition = newValue!;
                  });
                },
                items: _positions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> filters = {
                      if (_selectedPosition == 'Any' || _selectedPosition == 'SUB') 'Nationality': _selectedNationality,
                      'Position': _selectedPosition,
                      'Price': _selectedPrice,
                    };
                    printAllPlayers(filters);
                  },
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: _players.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_players[index].playerName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Position: ${_players[index].position}'),
                        Text('Goals: ${_players[index].goals}'),
                        if (_players[index].assists.isNotEmpty) Text('Assists: ${_players[index].assists}'),
                        if (_players[index].cleanSheets.isNotEmpty) Text('Clean sheets: ${_players[index].cleanSheets}'),
                        if (_players[index].points.isNotEmpty) Text('Points: ${_players[index].points}'),
                        Text('Price: ${_players[index].price}'),
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
    for (int i = 0; i < _players.length; i++) {
      if (_isSelected[i]) {
        selectedPlayers.add(_players[i].playerName);
      }
    }
    widget.onPlayerSelected?.call(selectedPlayers.join(", "));
    Navigator.pop(context);
  }

  Future<void> printAllPlayers(Map<String, dynamic> filters) async {
    final DatabaseReference _databaseReference =
    FirebaseDatabase.instance.reference();

    Query query;

    if (filters.containsKey('Nationality') && filters.containsKey('Position')) {
      query = _databaseReference
          .orderByChild('Team')
          .equalTo(filters['Nationality']);
    } else if (filters.containsKey('Nationality')) {
      query = _databaseReference
          .orderByChild('Team')
          .equalTo(filters['Nationality']);
    } else if (filters.containsKey('Position')) {
      query = _databaseReference
          .orderByChild('Position')
          .equalTo(filters['Position']);
    } else {
      query = _databaseReference;
    }

    query.once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        if (snapshot.value is Map<dynamic, dynamic>) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          _players.clear();
          data.forEach((key, value) {
            if (filters.containsKey('Nationality') &&
                filters.containsKey('Position')) {
              if (value['Position'] == filters['Position']) {
                if (double.parse(value['Price']) <=
                    double.parse(filters['Price'])) {
                  _players.add(Player(
                    playerName: value['Player'],
                    position: value['Position'],
                    goals: value['Goals'],
                    assists: value.containsKey('Assists') ? value['Assists'] : '',
                    cleanSheets: value.containsKey('Clean sheets') ? value['Clean sheets'] : '',
                    points: value.containsKey('Points') ? value['Points'] : '',
                    price: value['Price'],
                    redCards: value.containsKey('Red cards') ? value['Red cards'] : '',
                    team: value.containsKey('Team') ? value['Team'] : '',
                    yellowCards: value.containsKey('Yellow cards') ? value['Yellow cards'] : '',
                  ));
                }
              }
            } else {
              if (double.parse(value['Price']) <=
                  double.parse(filters['Price'])) {
                _players.add(Player(
                  playerName: value['Player'],
                  position: value['Position'],
                  goals: value['Goals'],
                  price: value['Price'],
                  assists: value['Assists'],
                  cleanSheets: value['Clean sheets'],
                  points: value['Points'],
                  redCards: value['Red cards'],
                  yellowCards: value['Yellow cards'],
                  team: value['Team']
                ));
              }
            }
          });
          setState(() {
            _isSelected = List<bool>.filled(_players.length, false);
          });
        } else if (snapshot.value is List<dynamic>) {
          final data = snapshot.value as List<dynamic>;
          _players.clear();
          data.forEach((playerMap) {
            if (filters.containsKey('Nationality') &&
                filters.containsKey('Position')) {
              if (playerMap['Position'] == filters['Position']) {
                if (double.parse(playerMap['Price']) <=
                    double.parse(filters['Price'])) {
                  _players.add(Player(
                    playerName: playerMap['Player'],
                    position: playerMap['Position'],
                    goals: playerMap['Goals'],
                    assists: playerMap.containsKey('Assists') ? playerMap['Assists'] : '',
                    cleanSheets: playerMap.containsKey('Clean sheets') ? playerMap['Clean sheets'] : '',
                    points: playerMap.containsKey('Points') ? playerMap['Points'] : '',
                    price: playerMap['Price'],
                    redCards: playerMap.containsKey('Red cards') ? playerMap['Red cards'] : '',
                    team: playerMap.containsKey('Team') ? playerMap['Team'] : '',
                    yellowCards: playerMap.containsKey('Yellow cards') ? playerMap['Yellow cards'] : '',
                  ));
                }
              }
            } else {
              if (double.parse(playerMap['Price']) <=
                  double.parse(filters['Price'])) {
                _players.add(Player(
                  playerName: playerMap['Player'],
                  position: playerMap['Position'],
                  goals: playerMap['Goals'],
                  price: playerMap['Price'],
                  assists: playerMap['Assists'],
                  cleanSheets: playerMap['Clean sheets'],
                  points: playerMap['Points'],
                  redCards: playerMap['Red cards'],
                  yellowCards: playerMap['Yellow cards'],
                  team: playerMap['Team']
                ));
              }
            }
          });
          setState(() {
            _isSelected = List<bool>.filled(_players.length, false);
          });
        }
      } else {
        print("No players available.");
      }
    }).catchError((error) {
      print("Error retrieving data: $error");
    });
  }

  void _showPlayerDetails(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_players[index].playerName),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Position: ${_players[index].position}'),
              Text('Goals: ${_players[index].goals}'),
              if (_players[index].assists.isNotEmpty) Text('Assists: ${_players[index].assists}'),
              if (_players[index].cleanSheets.isNotEmpty) Text('Clean sheets: ${_players[index].cleanSheets}'),
              if (_players[index].points.isNotEmpty) Text('Points: ${_players[index].points}'),
              Text('Price: ${_players[index].price}'),
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
    home: SearchPlayerPage(positionSelected: "SUB"),
  ));
}
