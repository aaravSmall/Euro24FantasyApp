import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_player_page.dart';

class EditTeamPage extends StatefulWidget {
  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late String selectedFormation;

  @override
  void initState() {
    super.initState();
    selectedFormation = '4231';
    loadFormation();
  }

  Future<void> loadFormation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFormation = prefs.getString('selectedFormation') ?? '4231';
    });
  }

  Future<void> saveFormation(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFormation', value);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.ref();
      await database
          .child('users')
          .child(user.uid)
          .child('formation')
          .set(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 70,
              right: 30,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: selectedFormation,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFormation = newValue!;
                        saveFormation(newValue); // Save selected formation
                      });
                    },
                    items: <String>[
                      '4231',
                      '442',
                      '433',
                      '541',
                      '532',
                      '523',
                      '343',
                      '352'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the previous screen
                    },
                    child: Text('Confirm'),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: buildFormation(selectedFormation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildFormation(String formation) {
    switch (formation) {
      case '4231':
        return build4231();
      case '442':
        return buildOtherFormation(4, 4, 2);
      case '433':
        return buildOtherFormation(4, 3, 3);
      case '541':
        return buildOtherFormation(5, 4, 1);
      case '532':
        return buildOtherFormation(5, 3, 2);
      case '523':
        return buildOtherFormation(5, 2, 3);
      case '343':
        return buildOtherFormation(3, 4, 3);
      case '352':
        return buildOtherFormation(3, 5, 2);
      default:
        return build4231();
    }
  }

  List<Widget> buildOtherFormation(int DF, int MD, int FW) {
    List<Widget> formationWidgets = [];

    // Row 1: Goalkeeper
    formationWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton('GK'),
          SizedBox(width: 20),
        ],
      ),
    );

    // Row 2: Defender Formation
    formationWidgets.add(SizedBox(height: 20));
    formationWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildPositionRow(DF, "DF"),
      ),
    );

    // Row 3: Midfielder Formation
    formationWidgets.add(SizedBox(height: 20));
    formationWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildPositionRow(MD, "MF"),
      ),
    );

    // Row 4: Forward Formation
    formationWidgets.add(SizedBox(height: 20));
    formationWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildPositionRow(FW, "FW"),
      ),
    );

    // Add a 100px space between the forward row and the sub bench row
    formationWidgets.add(SizedBox(height: 100));

    // Sub Bench Formation
    formationWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildPositionRow(4, "SUB"),
      ),
    );

    return formationWidgets;
  }

  List<Widget> _buildPositionRow(int count, String pos) {
    List<Widget> positionRow = [];
    double spacing = 10.0;
    double boxWidth = 50.0;
    double totalWidth = count * boxWidth + (count - 1) * spacing;

    for (int i = 0; i < count; i++) {
      positionRow.add(
        Row(
          children: [
            SizedBox(width: i == 0 ? 20 : spacing),
            _buildSearchButton(pos),
            SizedBox(width: i == count - 1 ? 20 : spacing),
          ],
        ),
      );
    }
    return positionRow;
  }

  List<Widget> build4231() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton('GK'),
          SizedBox(width: 20),
        ],
      ), //GK
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton('DF'),
          SizedBox(width: 20),
          _buildSearchButton('DF'),
          SizedBox(width: 20),
          _buildSearchButton('DF'),
          SizedBox(width: 20),
          _buildSearchButton('DF'),
          SizedBox(width: 20),
        ],
      ), //Defenders
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton('MF'),
          SizedBox(width: 20),
          _buildSearchButton('MF'),
          SizedBox(width: 20),
        ],
      ), // Midfielders
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton('MD'),
          SizedBox(width: 20),
          _buildSearchButton('MD'),
          SizedBox(width: 20),
          _buildSearchButton('MD'),
          SizedBox(width: 20),
        ],
      ), // Attackers/midfields Midfielders
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton('FW'),
          SizedBox(width: 20),
        ], // Attackers
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          _buildSearchButton("SUB"),
          SizedBox(width: 20),
          _buildSearchButton("SUB"),
          SizedBox(width: 20),
          _buildSearchButton("SUB"),
          SizedBox(width: 20),
          _buildSearchButton("SUB"),
          SizedBox(width: 20),
        ],
      ),
    ];
  }

  Widget _buildSearchButton(String positionSelected) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchPlayerPage(positionSelected: positionSelected),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 100,
        color: Colors.blue,
        margin: EdgeInsets.only(bottom: 10),
        child: Center(
          child: Text(
            '+',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
        ),
      ),
    );
  }
}
