import 'dart:convert';
import 'package:euros24fantasy/edit_team_page.dart';
import 'package:euros24fantasy/more_matches_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'player.dart';

class MainScreen extends StatefulWidget {
  final String htmlContent;
  final int userPoints;
  final String countdown;

  const MainScreen({
    Key? key,
    required this.htmlContent,
    required this.userPoints,
    required this.countdown,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Player> topScorers = [];
  List<Player> topPoints = [];

  @override
  void initState() {
    super.initState();
    fetchTopScorers();
    fetchTopPoints();
  }

  Future<void> fetchTopScorers() async {
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.reference();

    try {
      final DatabaseEvent event = await _databaseReference.once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> playersData = data.values.toList();

        List<Player> players = playersData.map((item) {
          return Player(
            playerName: item['Player'] ?? 'Unknown',
            position: item['Position'] ?? 'Unknown',
            goals: item['Goals'] ?? '0',
            assists: item['Assists'] ?? '0',
            cleanSheets: item['Clean sheets'] ?? '0',
            points: item['Points'] ?? '0',
            price: item['Price'] ?? '0.0',
            redCards: item['Red Cards'] ?? '0',
            team: item['Team'] ?? 'Unknown',
            yellowCards: item['Yellow Cards'] ?? '0',
          );
        }).toList();

        players.sort((a, b) => int.parse(b.goals).compareTo(int.parse(a.goals)));

        setState(() {
          topScorers = players.take(3).toList();
        });
      } else {
        print("No players available.");
      }
    } catch (error) {
      print("Error retrieving data: $error");
    }
  }

  Future<void> fetchTopPoints() async {
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.reference();

    try {
      final DatabaseEvent event = await _databaseReference.once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> playersData = data.values.toList();

        List<Player> players = playersData.map((item) {
          return Player(
            playerName: item['Player'] ?? 'Unknown',
            position: item['Position'] ?? 'Unknown',
            goals: item['Goals'] ?? '0',
            assists: item['Assists'] ?? '0',
            cleanSheets: item['Clean sheets'] ?? '0',
            points: item['Points'] ?? '0',
            price: item['Price'] ?? '0.0',
            redCards: item['Red Cards'] ?? '0',
            team: item['Team'] ?? 'Unknown',
            yellowCards: item['Yellow Cards'] ?? '0',
          );
        }).toList();

        players.sort((a, b) => int.parse(b.points).compareTo(int.parse(a.points)));

        setState(() {
          topPoints = players.take(3).toList();
        });
      } else {
        print("No players available.");
      }
    } catch (error) {
      print("Error retrieving data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 2.7,
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text('Rectangle'),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3.1,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Points: ${widget.userPoints}',
                        style: TextStyle(color: Colors.white),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _editTeam(context);
                        },
                        child: Text('Edit Team'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        widget.countdown,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('Score: 0 - 0'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(child: Text('Score: 0 - 0'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _navigateToMoreMatches(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'More Matches',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Scorers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 10),
                              ...topScorers.map((player) {
                                return Text(
                                  '${player.playerName} - ${player.goals} goals',
                                  style: TextStyle(fontSize: 14),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Points',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 10),
                              ...topPoints.map((player) {
                                return Text(
                                  '${player.playerName} - ${player.points} points',
                                  style: TextStyle(fontSize: 14),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editTeam(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditTeamPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, -1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToMoreMatches(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoreMatchesPage()),
    );
  }
}

                         
