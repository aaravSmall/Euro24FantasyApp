import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

class MoreMatchesPage extends StatefulWidget {
  @override
  _MoreMatchesPageState createState() => _MoreMatchesPageState();
}

class _MoreMatchesPageState extends State<MoreMatchesPage> {
  List<String> matchDates = [
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

  Map<String, List<String>> matchesByDate = {};

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
        for (String date in matchDates) {
          final startIndex = htmlText.indexOf(date);
          final endIndex = htmlText.indexOf(_getNextDate(date), startIndex);
          final extractedText = htmlText.substring(startIndex, endIndex == -1 ? htmlText.length : endIndex);
          matchesByDate[date] = _extractMatches(extractedText);
        }
        setState(() {});
      } else {
        print("No data available at the specified reference.");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  String _getNextDate(String currentDate) {
    final currentIndex = matchDates.indexOf(currentDate);
    return currentIndex == matchDates.length - 1 ? 'BRACKET - ROUND OF 16' : matchDates[currentIndex + 1];
  }

  List<String> _extractMatches(String text) {
    final matches = text.split(RegExp(r'(?=\b(?:Group|BRACKET))'));
    matches.removeWhere((element) => element.trim().isEmpty || matchDates.any((date) => element.contains(date)));
    return matches;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Schedule'),
      ),
      body: ListView.builder(
        itemCount: matchDates.length,
        itemBuilder: (context, index) {
          final date = matchDates[index];
          final matches = matchesByDate[date] ?? [];
          if (matches.isNotEmpty) {
            // Print to debug console
            print("Date: $date");
            for (String match in matches) {
              print("Match: $match");
            }
          }
          return matches.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  date,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              SizedBox(height: 8),
              ...matches.map((match) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      match,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )).toList(),
              SizedBox(height: 16),
            ],
          ) : SizedBox.shrink();
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MoreMatchesPage(),
  ));
}

class Match{
    final String team1;
    final String team2;
    final String location; 
    final String time;
    final String group;

    Match({
    required this.team1,
    required this.team2,
    required this.location,
    required this.time,
    required this.group,
  });
}
