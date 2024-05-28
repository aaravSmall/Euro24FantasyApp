import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'search_player_page.dart';
import 'player.dart';
import 'dart:convert';

class EditTeamPage extends StatefulWidget {
  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late String selectedFormation;
  Map<String, List<Player?>> _selectedPlayers = {
    'GK': [null],
    'DF': [null, null, null, null],
    'MF': [null, null],
    'MD': [null, null, null],
    'FW': [null],
    'SUB': [null, null, null, null],
  };
  late String _positionSelected;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedFormation = '4231';
    loadFormation();
    loadPlayers();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loadPlayers();
      } else {
        savePlayers();
      }
    });

    WidgetsBinding.instance.addObserver(AppLifecycleListener(onResume: () {
      loadFormation();
      loadPlayers();
    }, onPause: () {
      saveFormation(selectedFormation);
      savePlayers();
    }, onDetach: () {
      savePlayers();
    }));
  }

  /*Future<void> savePlayers2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String playersJson = jsonEncode(_selectedPlayers.map((key, value) {
      return MapEntry(key, value.map((player) => player?.toJson()).toList());
    }));
    await prefs.setString('selectedPlayers', playersJson);
  }*/

  Future<void> loadFormation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFormation = prefs.getString('selectedFormation') ?? '4231';
    });
  }

  Future<void> saveFormation(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFormation', value);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.ref();
      await database
          .child('users')
          .child(user.uid)
          .child('formation')
          .set(value);
    }
  }

  Future<void> loadPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? playersJson = prefs.getString('selectedPlayers');
    if (playersJson != null) {
      Map<String, dynamic> playersMap = jsonDecode(playersJson);
      setState(() {
        _selectedPlayers = playersMap.map((key, value) {
          List<dynamic> playersList = value;
          return MapEntry(
              key,
              playersList
                  .map((playerJson) =>
                      playerJson != null ? Player.fromJson(playerJson) : null)
                  .toList());
        });
      });
    }
  }

  Future<void> savePlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String playersJson = jsonEncode(_selectedPlayers.map((key, value) {
      return MapEntry(key, value.map((player) => player?.toJson()).toList());
    }));
    await prefs.setString('selectedPlayers', playersJson);
  }

  Future<void> _navigateAndDisplaySelection(
      BuildContext context, String positionSelected, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchPlayerPage(positionSelected: positionSelected),
      ),
    );

    if (result != null && result is List<Player>) {
      setState(() {
        if (index < _selectedPlayers[positionSelected]!.length) {
          _selectedPlayers[positionSelected]![index] =
              result.isNotEmpty ? result[0] : null;
        } else {
          _selectedPlayers[positionSelected]!
              .add(result.isNotEmpty ? result[0] : null);
        }
      });

      savePlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Team'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedFormation,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFormation = newValue!;
                      saveFormation(newValue);
                    });
                  },
                  items: <String>[
                    '4231',
                    '442',
                    '433',
                    '541',
                    '532',
                    '523',
                    '343',
                    '352'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    savePlayers(); // Save players when confirming
                    Navigator.pop(context);
                  },
                  child: Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: buildFormation(selectedFormation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildFormation(String formation) {
    switch (formation) {
      case '4231':
        return build4231();
      case '442':
        return buildOtherFormation(4, 4, 2);
      case '433':
        return buildOtherFormation(4, 3, 3);
      case '541':
        return buildOtherFormation(5, 4, 1);
      case '532':
        return buildOtherFormation(5, 3, 2);
      case '523':
        return buildOtherFormation(5, 2, 3);
      case '343':
        return buildOtherFormation(3, 4, 3);
      case '352':
        return buildOtherFormation(3, 5, 2);
      default:
        return build4231();
    }
  }

  List<Widget> buildOtherFormation(int DF, int MD, int FW) {
    return [
      _buildPositionRow(1, 'GK'),
      _buildPositionRow(DF, 'DF'),
      _buildPositionRow(MD, 'MF'),
      _buildPositionRow(FW, 'FW'),
      SizedBox(height: 50),
      _buildPositionRow(4, 'SUB'),
    ];
  }

  List<Widget> build4231() {
    return [
      _buildPositionRow(1, 'GK'),
      _buildPositionRow(4, 'DF'),
      _buildPositionRow(2, 'MF'),
      _buildPositionRow(3, 'MD'),
      _buildPositionRow(1, 'FW'),
      SizedBox(height: 50),
      _buildPositionRow(4, 'SUB'),
    ];
  }

  Widget _buildPositionRow(int count, String positionSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: _buildPositionRowContent(positionSelected, index),
          );
        }),
      ),
    );
  }

  Widget _buildPositionRowContent(String positionSelected, int index) {
    List<Player?> players = _selectedPlayers[positionSelected] ?? [];
    if (index < players.length && players[index] != null) {
      return Container(
        width: 60,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            players[index]!.playerName,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    } else {
      return _buildSearchButton(positionSelected, index);
    }
  }

  Widget _buildSearchButton(String positionSelected, int index) {
    return InkWell(
      onTap: () {
        _navigateAndDisplaySelection(context, positionSelected, index);
      },
      child: Container(
        width: 60,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
