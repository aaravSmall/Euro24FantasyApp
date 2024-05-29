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

  List<Match> knockoutMatches = [];
  int currentRoundIndex = 0;

  Map<String, Team?> selectedTeams = {};

  @override
  void initState() {
    super.initState();
    _initializeKnockoutMatches();
  }

  void _initializeKnockoutMatches() {
    knockoutMatches.clear();
    for (int i = 0; i < groups.length - 1; i += 2) {
      Team? team1 = selectedTeams[groups[i].name];
      Team? team2 = selectedTeams[groups[i].name + "_second"];
      Team? team3 = selectedTeams[groups[i + 1].name];
      Team? team4 = selectedTeams[groups[i + 1].name + "_second"];
      knockoutMatches.add(Match(
        team1: team1 ?? Team('No Team Selected'),
        team2: team4 ?? Team('No Team Selected'),
      ));
      knockoutMatches.add(Match(
        team1: team3 ?? Team('No Team Selected'),
        team2: team2 ?? Team('No Team Selected'),
      ));
    }
  }

  void _updateKnockoutMatches() {
    setState(() {
      _initializeKnockoutMatches();
    });
  }

  void _progressToNextRound() {
    setState(() {
      currentRoundIndex++;
      if (currentRoundIndex == 3) {
        // Tournament finished
        return;
      }
      _initializeKnockoutMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Euro 2020 Predictor')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Group Stage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...groups.map((group) => GroupWidget(group: group, selectedTeams: selectedTeams, onUpdate: _updateKnockoutMatches)).toList(),
            SizedBox(height: 20),
            Text('Knockout Stage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...knockoutMatches.map((match) => MatchWidget(match: match)).toList(),
            ElevatedButton(
              onPressed: _progressToNextRound,
              child: Text('Proceed to Next Round'),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupWidget extends StatefulWidget {
  final Group group;
  final Map<String, Team?> selectedTeams;
  final VoidCallback onUpdate;

  GroupWidget({required this.group, required this.selectedTeams, required this.onUpdate});

  @override
  _GroupWidgetState createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  Team? firstPlace;
  Team? secondPlace;
  late List<Team> secondPlaceOptions;

  @override
  void initState() {
    super.initState();
    firstPlace = widget.selectedTeams[widget.group.name];
    secondPlace = widget.selectedTeams['${widget.group.name}_second'];
    secondPlaceOptions = widget.group.teams.where((team) => team != firstPlace).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(widget.group.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<Team>(
            value: firstPlace,
            items: widget.group.teams.map<DropdownMenuItem<Team>>((Team team) {
              return DropdownMenuItem<Team>(
                value: team,
                child: Text(team.name),
              );
            }).toList(),
            onChanged: (Team? newValue) {
              setState(() {
                firstPlace = newValue;
                widget.selectedTeams[widget.group.name] = newValue;
                secondPlaceOptions = widget.group.teams.where((team) => team != newValue).toList();
                if (secondPlaceOptions.contains(secondPlace)) {
                  secondPlace = null;
                  widget.selectedTeams['${widget.group.name}_second'] = null;
                }
                widget.onUpdate();
              });
            },
            decoration: InputDecoration(labelText: 'First Place'),
          ),
          DropdownButtonFormField<Team>(
            value: secondPlace,
            items: secondPlaceOptions.map<DropdownMenuItem<Team>>((Team team) {
              return DropdownMenuItem<Team>(
                value: team,
                child: Text(team.name),
              );
            }).toList(),
            onChanged: (Team? newValue) {
              setState(() {
                secondPlace = newValue;
                widget.selectedTeams['${widget.group.name}_second'] = newValue;
                widget.onUpdate();
              });
            },
            decoration: InputDecoration(labelText: 'Second Place'),
          ),
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

class Match {
  final Team team1;
  final Team team2;
  Team? winner;

  Match({required this.team1, required this.team2, this.winner});
}

class Group {
  final String name;
  final List<Team> teams;

  Group({required this.name, required this.teams});
}

