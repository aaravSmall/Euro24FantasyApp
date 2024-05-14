import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchPlayerPage extends StatefulWidget {
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

  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isDense: true,
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
                        child: Text(truncateText(value, 15)), // Truncate text if it's too long
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Nationality',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isDense: true,
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
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isDense: true,
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
                ),
              ],
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
                    Navigator.pop(
                        context); // Navigate back to the previous screen
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

    query.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        print("Players:");
        if (snapshot.value is Map<dynamic, dynamic>) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            if (filters.containsKey('Nationality') &&
                filters.containsKey('Position')) {
              if (value['Position'] == filters['Position']) {
                if (double.parse(value['Price']) <=
                    double.parse(filters['Price'])) {
                  print("Player Name: ${value['Player']}");
                  print("Position: ${value['Position']}");
                  print("Goals: ${value['Goals']}");
                  print("Assists: ${value['Assists']}");
                  print("Clean sheets: ${value['Clean sheets']}");
                  print("Points: ${value['Points']}");
                  print("Price: ${value['Price']}");
                  print("-------------------");
                }
              }
            } else {
              if (double.parse(value['Price']) <=
                  double.parse(filters['Price'])) {
                print("Player Name: ${value['Player']}");
                print("Position: ${value['Position']}");
                print("Goals: ${value['Goals']}");
                print("Price: ${value['Price']}");
                print("-------------------");
              }
            }
          });
        } else if (snapshot.value is List<dynamic>) {
          (snapshot.value as List<dynamic>).forEach((player) {
            if (player is Map<dynamic, dynamic>) {
              final playerMap = player as Map<dynamic, dynamic>;
              if (filters.containsKey('Nationality') &&
                  filters.containsKey('Position')) {
                if (playerMap['Position'] == filters['Position']) {
                  if (double.parse(playerMap['Price']) <=
                      double.parse(filters['Price'])) {
                    print("Player Name: ${playerMap['Player']}");
                    print("Position: ${playerMap['Position']}");
                    print("Goals: ${playerMap['Goals']}");
                    print("Assists: ${playerMap['Assists']}");
                    print("Clean sheets: ${playerMap['Clean sheets']}");
                    print("Points: ${playerMap['Points']}");
                    print("Price: ${playerMap['Price']}");
                    print("-------------------");
                  }
                }
              } else {
                if (double.parse(playerMap['Price']) <=
                    double.parse(filters['Price'])) {
                  print("Player Name: ${playerMap['Player']}");
                  print("Position: ${playerMap['Position']}");
                  print("Goals: ${playerMap['Goals']}");
                  print("Price: ${playerMap['Price']}");
                  print("-------------------");
                }
              }
            }
          });
        }
      } else {
        print("No players available.");
      }
    }, onError: (error) {
      print("Error retrieving data: $error");
    });
  }
}

class Player {
  final String playerName;
  final String position;
  final String goals;
  final String assists;
  final String cleanSheets;
  final String points;
  final String price;
  final String redCards;
  final String team;
  final String yellowCards;

  Player({
    required this.playerName,
    required this.position,
    required this.goals,
    required this.assists,
    required this.cleanSheets,
    required this.points,
    required this.price,
    required this.redCards,
    required this.team,
    required this.yellowCards,
  });
}
