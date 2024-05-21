import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

class Match {
  String team1;
  String team2;
  String location;
  String time;
  String group;

  Match({required this.team1, required this.team2, required this.location, required this.time, required this.group});

  @override
  String toString() {
    return 'Match: $team1 vs $team2\nLocation: $location\nTime: $time\nGroup: $group\n';
  }
}


class MoreMatchesPage extends StatefulWidget {
  @override
  _MoreMatchesPageState createState() => _MoreMatchesPageState();
}

class _MoreMatchesPageState extends State<MoreMatchesPage> {
  List<Match> matches = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
  const url = 'https://www.espn.com/soccer/story/_/page/uefaeuro/euro-2024-bracket-fixtures-schedule-finals';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final document = htmlParser.parse(response.body);
    final htmlText = document.documentElement?.text;

    if (htmlText != null) {
      final matchesData = htmlText.split(RegExp(r'(?=Wednesday, June 26)')).first;
      final matchLines = matchesData.trim().split(RegExp(r'(?=Group [A-F]:)')).sublist(1);
      
      for (String matchData in matchLines) {
        final matchDetails = matchData.trim().split('\n');

        final team1 = matchDetails[0].split(':')[1].trim().split(' vs ')[0].split(' ')[0].trim();
        //print('Team 1: $team1');

        final team2 = matchDetails[0].split('vs.')[1].split('(')[0].trim();
        //print('Team 2: $team2');

        final location = matchDetails[0].split('(')[1].split(';')[0].trim();
        //print('Location: $location');

        final time = matchDetails[0].split('(')[1].split(';')[1].split(')')[0].trim();
        //print('Time: $time');

        final group = matchDetails[0].split(':')[0].trim();
        //print('Group: $group');


        final match = Match(team1: team1, team2: team2, location: location, time: time, group: group);
        matches.add(match);
      }

      // Print Match objects to the console
      matches.forEach((match) {
        print(match);
      });
    } else {
      print("No data available at the specified reference.");
    }
  } else {
    print("Error: ${response.statusCode}");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More Matches'),
      ),
      body: Center(
        child: Text(
          'Match schedule will be printed to the console after fetching data.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
