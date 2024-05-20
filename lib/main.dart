import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:euros24fantasy/account_screen.dart';
import 'package:euros24fantasy/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}
/*await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: 'AIzaSyA-LETZlocCknTlGtZhRBzotlHr0tTeOpk',
    appId: '1:541882838462:ios:200c638ab8f9216a545def',
    messagingSenderId: '541882838462',
    projectId: 'euro24-631f3',
    databaseURL: 'https://euro24-631f3-default-rtdb.firebaseio.com',
    storageBucket: 'euro24-631f3.appspot.com',
    iosClientId: '541882838462-s1rpe73i7rlstphp6bv1j9pronpuvobg.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication2',
    )
  );*/

//runApp(MainApp());

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

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0; // Index of the selected page
  String firstFifteenChars =
      ''; // Initialize firstFifteenChars with an empty string
  int userPoints = 0; // Initialize user points
  String countdown = '00:00:00'; // Initialize countdown

  List<Widget> get _pages => [
        MainScreen(
          htmlContent: firstFifteenChars,
          userPoints: userPoints,
          countdown: countdown,
        ), // Placeholder for Home page
        LeaguesScreen(),
        LoginScreen(), // Placeholder for Leagues page
        // Placeholder for Account page
      ];

  @override
  void initState() {
    super.initState();
    //fetchData();
  }

  Future<void> fetchData() async {
    debugPrint('fetchData');
    final url = 'https://www.cnn.com/'; //URL for official Euro site maybe???
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final htmlText = document.documentElement?.text;

      if (htmlText != null) {
        setState(() {
          firstFifteenChars = htmlText.substring(
              0, htmlText.length < 15 ? htmlText.length : 15);
          //debugPrint('HTML Content: $htmlText');
        });
      } else {
        print("No data available at the specified reference.");
      }
    }
    onError:
    (Object error) {
      print("Error: $error");
    };
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'Leagues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class LeaguesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Leagues Screen'),
    );
  }
}
