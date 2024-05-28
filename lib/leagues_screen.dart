import 'package:flutter/material.dart';

void main() {
  runApp(BracketPredictorApp());
}

class BracketPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euro 2024 Bracket Predictor',
      home: BracketPredictorScreen(),
    );
  }
}

class BracketPredictorScreen extends StatefulWidget {
  @override
  _BracketPredictorScreenState createState() => _BracketPredictorScreenState();
}

class _BracketPredictorScreenState extends State<BracketPredictorScreen> {
  List<String> groupA = ['Germany', 'Scotland', 'Hungary', 'Switzerland'];
  List<String> groupB = ['Spain', 'Croatia', 'Italy', 'Albania'];
  List<String> groupC = ['Slovenia', 'Denmark', 'Serbia', 'England'];
  List<String> groupD = ['Poland', 'Netherlands', 'Austria', 'France'];
  List<String> groupE = ['Belgium', 'Slovakia', 'Romania', 'Ukraine'];
  List<String> groupF = ['Turkey', 'Georgia', 'Portugal', 'Czech Republic'];
  // Add other groups similarly

  late List<String?> selectedTeams;

  @override
  void initState() {
    super.initState();
    selectedTeams = List.filled(24, null); // 24 teams in total
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Euro 2024 Bracket Predictor'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bracket Stage Predictions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            buildGroupBracket(groupA, 'Group A'),
            SizedBox(height: 20),
            buildGroupBracket(groupB, 'Group B'),
            SizedBox(height: 20),
            buildGroupBracket(groupC, 'Group C'),
            SizedBox(height: 20),
            buildGroupBracket(groupD, 'Group D'),
            SizedBox(height: 20),
            buildGroupBracket(groupE, 'Group E'),
            SizedBox(height: 20),
            buildGroupBracket(groupF, 'Group F'),
            SizedBox(height: 20),
            // Add other group brackets similarly
            ElevatedButton(
              onPressed: () {
                // Handle button press to submit predictions
              },
              child: Text('Submit Predictions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGroupBracket(List<String> groupTeams, String groupName) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            buildMatchup('Winner A', groupTeams[0], groupTeams[1]),
            SizedBox(height: 8),
            buildMatchup('Winner B', groupTeams[2], groupTeams[3]),
          ],
        ),
      ),
    );
  }

  Widget buildMatchup(String label, String team1, String team2) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: DropdownButton<String>(
            value: selectedTeams[groupA.indexOf(team1)] ?? null,
            onChanged: (value) {
              setState(() {
                final index = groupA.indexOf(team1);
                if (index != -1) {
                  selectedTeams[index] = value;
                }
              });
            },
            items: [team1, team2].map<DropdownMenuItem<String>>((String team) {
              return DropdownMenuItem<String>(
                value: team,
                child: Text(team),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
