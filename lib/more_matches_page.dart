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
  Map<String, List<Match>> matchesByDate = {};

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
        final dates = [
          'Friday, June 14',
          'Saturday, June 15',
          'Sunday, June 16',
          'Monday, June 17',
          'Tuesday, June 18',
          'Wednesday, June 19',
          'Thursday, June 20',
          'Friday, June 21',
          'Saturday, June 22',
          'Sunday, June 23',
          'Monday, June 24',
          'Tuesday, June 25',
          'Wednesday, June 26',
        ];

        for (String date in dates) {
          final startIndex = htmlText.indexOf(date);
          final endIndex = dates.indexOf(date) == dates.length - 1
              ? htmlText.indexOf('BRACKET - ROUND OF 16')
              : htmlText.indexOf(dates[dates.indexOf(date) + 1]);
          final matchesData = htmlText.substring(startIndex, endIndex);

          final matchLines = matchesData.trim().split(RegExp(r'(?=Group [A-F]:)')).sublist(1);
          List<Match> matchesForDate = [];

          for (String matchData in matchLines) {
            final matchDetails = matchData.trim().split('\n');

            final team1 = matchDetails[0].split(':')[1].trim().split('vs.')[0].split(' ')[0].trim();
            final team2 = matchDetails[0].split('vs.')[1].split('(')[0].trim();
            final location = matchDetails[0].split('(')[1].split(';')[0].trim();
            final time = matchDetails[0].split('(')[1].split(';')[1].split(')')[0].trim();
            final group = matchDetails[0].split(':')[0].trim();

            final match = Match(team1: team1, team2: team2, location: location, time: time, group: group);
            matchesForDate.add(match);
          }

          matchesByDate[date] = matchesForDate;
        }

        setState(() {
          matches = matchesByDate.values.expand((element) => element).toList();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade700],
          ),
        ),
        child: ListView.builder(
          itemCount: matchesByDate.length,
          itemBuilder: (context, index) {
            String date = matchesByDate.keys.toList()[index];
            List<Match> matchesForDate = matchesByDate[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: matchesForDate.length,
                  itemBuilder: (context, index) {
                    Match match = matchesForDate[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      color: Colors.white,
                      child: ListTile(
                        title: Text('${match.team1} vs ${match.team2}'),
                        subtitle: Text('${match.location}, ${match.time}'),
                        trailing: Text('Group: ${match.group}'),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
