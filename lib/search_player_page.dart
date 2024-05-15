import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchPlayerPage extends StatefulWidget {
  final ValueChanged<String>? onPlayerSelected;

  SearchPlayerPage({Key? key, this.onPlayerSelected}) : super(key: key);

  @override
  _SearchPlayerPageState createState() => _SearchPlayerPageState();
}

class _SearchPlayerPageState extends State<SearchPlayerPage> {
  String _selectedNationality = '';
  String _selectedPrice = '';
  String _selectedPosition = '';

  final List<String> _nationalities = [
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
    '7.0',
    '6.5',
    '6.0',
    '5.5',
    '5.0',
    '4.5'
  ];
  final List<String> _positions = ['FW', 'MF', 'DF', 'GK'];

  List<Map<String, dynamic>> _players = [];
  List<bool> _isSelected = [];

  @override
  void initState() {
    super.initState();
    _isSelected = List<bool>.filled(_players.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedNationality.isNotEmpty
                    ? _selectedNationality
                    : null,
                onChanged: (newValue) {
                  setState(() {
                    _selectedNationality = newValue!;
                  });
                },
                items: _nationalities
                    .map<DropdownMenuItem<String>>((String value) {
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
                  TextButton(
                    onPressed: () {
                      Map<String, dynamic> filters = {
                        'Nationality': _selectedNationality,
                        'Position': _selectedPosition,
                        'Price': _selectedPrice,
                      };
                      printAllPlayers(filters);
                    },
                    child: Text('Search'),
                  ),
                  TextButton(
                    onPressed: () {
                      _confirmSelection(context);
                    },
                    child: Text('Confirm'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_players[index]['Player']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Position: ${_players[index]['Position']}'),
                          Text('Goals: ${_players[index]['Goals']}'),
                          Text('Assists: ${_players[index]['Assists']}'),
                          Text(
                              'Clean sheets: ${_players[index]['Clean sheets']}'),
                          Text('Points: ${_players[index]['Points']}'),
                          Text('Price: ${_players[index]['Price']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon:
                            Icon(_isSelected[index] ? Icons.check : Icons.add),
                        onPressed: () {
                          setState(() {
                            _isSelected[index] = !_isSelected[index];
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _isSelected[index] = !_isSelected[index];
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSelection(BuildContext context) {
    List<String> selectedPlayers = [];
    for (int i = 0; i < _players.length; i++) {
      if (_isSelected[i]) {
        selectedPlayers.add(_players[i]['Player']);
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
                  _players.add({
                    'Player': value['Player'],
                    'Position': value['Position'],
                    'Goals': value['Goals'],
                    'Assists': value['Assists'],
                    'Clean sheets': value['Clean sheets'],
                    'Points': value['Points'],
                    'Price': value['Price']
                  });
                }
              }
            } else {
              if (double.parse(value['Price']) <=
                  double.parse(filters['Price'])) {
                _players.add({
                  'Player': value['Player'],
                  'Position': value['Position'],
                  'Goals': value['Goals'],
                  'Price': value['Price']
                });
              }
            }
          });
          setState(() {
            _isSelected = List<bool>.filled(_players.length, false);
          });
        } else if (snapshot.value is List<dynamic>) {
          final data = snapshot.value as List<dynamic>;
          _players.clear();
          data.forEach((player) {
            if (player is Map<dynamic, dynamic>) {
              final playerMap = player as Map<dynamic, dynamic>;
              if (filters.containsKey('Nationality') &&
                  filters.containsKey('Position')) {
                if (playerMap['Position'] == filters['Position']) {
                  if (double.parse(playerMap['Price']) <=
                      double.parse(filters['Price'])) {
                    _players.add({
                      'Player': playerMap['Player'],
                      'Position': playerMap['Position'],
                      'Goals': playerMap['Goals'],
                      'Assists': playerMap['Assists'],
                      'Clean sheets': playerMap['Clean sheets'],
                      'Points': playerMap['Points'],
                      'Price': playerMap['Price']
                    });
                  }
                }
              } else {
                if (double.parse(playerMap['Price']) <=
                    double.parse(filters['Price'])) {
                  _players.add({
                    'Player': playerMap['Player'],
                    'Position': playerMap['Position'],
                    'Goals': playerMap['Goals'],
                    'Price': playerMap['Price']
                  });
                }
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
}

class LineupScreen extends StatelessWidget {
  final List<String> selectedPlayers;

  const LineupScreen({Key? key, required this.selectedPlayers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Players'),
      ),
      body: ListView.builder(
        itemCount: selectedPlayers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(selectedPlayers[index]),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SearchPlayerPage(),
  ));
}
