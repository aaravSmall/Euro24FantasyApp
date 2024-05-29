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
  ];

  List<Match> roundOf16Matches = [];
  List<Match> quarterFinalMatches = [];
  List<Match> semiFinalMatches = [];
  Match? finalMatch;
  Map<String, Team?> selectedTeams = {};

  @override
  void initState() {
    super.initState();
    _initializeKnockoutMatches();
  }

  void _initializeKnockoutMatches() {
    _setupRoundOf16();
    _setupQuarterFinals();
    _setupSemiFinals();
    _setupFinal();
  }

  void _setupRoundOf16() {
    roundOf16Matches.clear();
    for (int i = 0; i < groups.length - 1; i += 2) {
      Team? team1 = selectedTeams[groups[i].name];
      Team? team2 = selectedTeams[groups[i].name + "_second"];
      Team? team3 = selectedTeams[groups[i + 1].name];
      Team? team4 = selectedTeams[groups[i + 1].name + "_second"];
      roundOf16Matches.add(Match(
        team1: team1 ?? Team('TBD'),
        team2: team4 ?? Team('TBD'),
      ));
      roundOf16Matches.add(Match(
        team1: team3 ?? Team('TBD'),
        team2: team2 ?? Team('TBD'),
      ));
    }
  }

  void _setupQuarterFinals() {
    quarterFinalMatches.clear();
    for (int i = 0; i < roundOf16Matches.length; i += 2) {
      Team? team1 = roundOf16Matches[i].winner;
      Team? team2 = roundOf16Matches[i + 1].winner;
      print("Quarters::  Team1:  $team1    Team2: $team2");
      quarterFinalMatches.add(Match(
        team1: team1 ?? Team('TBD'),
        team2: team2 ?? Team('TBD'),
      ));
    }
  }

  void _setupSemiFinals() {
    semiFinalMatches.clear();
    for (int i = 0; i < quarterFinalMatches.length; i += 2) {
      Team? team1 = quarterFinalMatches[i].winner;
      Team? team2 = quarterFinalMatches[i + 1].winner;
      print("Semis::  Team1:  $team1    Team2: $team2");
      semiFinalMatches.add(Match(
        team1: team1 ?? Team('TBD'),
        team2: team2 ?? Team('TBD'),
      ));
    }
  }


  void _setupFinal() {
    finalMatch = null;
    if (semiFinalMatches.length == 2) {
      finalMatch = Match(
        team1: semiFinalMatches[0].winner ?? Team('TBD'),
        team2: semiFinalMatches[1].winner ?? Team('TBD'),
      );
    }
  }

  void _updateKnockoutMatches() {
    setState(() {
      _setupRoundOf16();
      _setupQuarterFinals();
      _setupSemiFinals();
      _setupFinal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Euro 2020 Predictor')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group Stage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...groups.map((group) => GroupWidget(group: group, selectedTeams: selectedTeams, onUpdate: _updateKnockoutMatches)).toList(),
            SizedBox(height: 20),
            Text('Quarter Finals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...roundOf16Matches.map((match) => MatchWidget(match: match, onUpdate: _updateKnockoutMatches)).toList(),
            SizedBox(height: 20),
            Text('Semi Finals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...quarterFinalMatches.map((match) => MatchWidget(match: match, onUpdate: _updateKnockoutMatches)).toList(),
            SizedBox(height: 20),
            Text('Finals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...semiFinalMatches.map((match) => MatchWidget(match: match, onUpdate: _updateKnockoutMatches)).toList(),
            if (finalMatch != null) ...[
              SizedBox(height: 20),
              Text('Final', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              MatchWidget(match: finalMatch!, onUpdate: _updateKnockoutMatches),
            ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
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
            SizedBox(height: 10),
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
      ),
    );
  }
}

class MatchWidget extends StatefulWidget {
  final Match match;
  final VoidCallback onUpdate;

  MatchWidget({required this.match, required this.onUpdate});

  @override
  _MatchWidgetState createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  Team? selectedWinner;

  @override
  void initState() {
    super.initState();
    selectedWinner = widget.match.winner;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                    widget.onUpdate();
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
                    widget.onUpdate();
                  });
                },
              ),
            ),
          ],
        ),
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
