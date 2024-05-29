import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  List<Group> groups = [
    Group(name: 'Group A', teams: [Team('Germany'), Team('Scotland'), Team('Hungary'), Team('Switzerland')]),
    Group(name: 'Group B', teams: [Team('Spain'), Team('Croatia'), Team('Italy'), Team('Albania')]),
    Group(name: 'Group C', teams: [Team('Slovenia'), Team('Denmark'), Team('Serbia'), Team('England')]),
    Group(name: 'Group D', teams: [Team('Poland'), Team('Netherlands'), Team('Austria'), Team('France')]),
    Group(name: 'Group E', teams: [Team('Belgium'), Team('Slovakia'), Team('Romania'), Team('Ukraine')]),
    Group(name: 'Group F', teams: [Team('Turkey'), Team('Georgia'), Team('Portugal'), Team('Czech Republic')]),
  ];

  List<Match> matches = [];

  @override
  void initState() {
    super.initState();
    // Initialize knockout stage matches based on group standings
    // This is just an example, you need to implement the logic to determine the actual matches
    matches = [
      Match(team1: groups[0].teams[0], team2: groups[1].teams[1]),
      Match(team1: groups[1].teams[0], team2: groups[0].teams[1]),
      Match(team1: groups[2].teams[0], team2: groups[3].teams[1]),
      Match(team1: groups[3].teams[0], team2: groups[2].teams[1]),
      Match(team1: groups[4].teams[0], team2: groups[5].teams[1]),
      Match(team1: groups[5].teams[0], team2: groups[4].teams[1]),
      // Add other matches here
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Euro 2020 Predictor')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Group Stage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...groups.map((group) => GroupWidget(group: group)).toList(),
            SizedBox(height: 20),
            Text('Knockout Stage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...matches.map((match) => MatchWidget(match: match)).toList(),
          ],
        ),
      ),
    );
  }
}

class GroupWidget extends StatelessWidget {
  final Group group;

  GroupWidget({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(group.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...group.teams.map((team) => ListTile(title: Text(team.name))).toList(),
        ],
      ),
    );
  }
}

class MatchWidget extends StatefulWidget {
  final Match match;

  MatchWidget({required this.match});

  @override
  _MatchWidgetState createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  Team? selectedWinner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.match.team1.name),
            trailing: Radio<Team>(
              value: widget.match.team1,
              groupValue: selectedWinner,
              onChanged: (Team? value) {
                setState(() {
                  selectedWinner = value;
                  widget.match.winner = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(widget.match.team2.name),
            trailing: Radio<Team>(
              value: widget.match.team2,
              groupValue: selectedWinner,
              onChanged: (Team? value) {
                setState(() {
                  selectedWinner = value;
                  widget.match.winner = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Team {
  final String name;

  Team(this.name);
}

// models/match.dart
class Match {
  final Team team1;
  final Team team2;
  Team? winner;

  Match({required this.team1, required this.team2, this.winner});
}

// models/group.dart
class Group {
  final String name;
  final List<Team> teams;

  Group({required this.name, required this.teams});
}
