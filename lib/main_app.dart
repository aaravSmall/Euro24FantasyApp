import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'leagues_screen.dart';
import 'account_screen.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

class MainAppWithTabs extends StatefulWidget {
  @override
  _MainAppWithTabsState createState() => _MainAppWithTabsState();
}

class _MainAppWithTabsState extends State<MainAppWithTabs> {
  int _selectedIndex = 0;
  String firstFifteenChars =
      ''; // Initialize firstFifteenChars with an empty string
  int userPoints = 0; // Initialize user points
  String countdown = '00:00:00'; // Initialize countdown

  List<Widget> get _pages => [
        MainScreen(
          htmlContent: firstFifteenChars,
          userPoints: userPoints,
          countdown: countdown,
        ),
        LeaguesScreen(),
        LoginScreen(),
      ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    debugPrint('fetchData');
    final url = 'https://www.cnn.com/'; // URL for official Euro site maybe???
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final htmlText = document.documentElement?.text;

      if (htmlText != null) {
        setState(() {
          firstFifteenChars = htmlText.substring(
              0, htmlText.length < 15 ? htmlText.length : 15);
          // debugPrint('HTML Content: $htmlText');
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
    return Scaffold(
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
    );
  }
}
