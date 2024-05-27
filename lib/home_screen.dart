import 'edit_team_page.dart';
import 'more_matches_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final String htmlContent;
  final int userPoints;
  final String countdown;

  const MainScreen({
    Key? key,
    required this.htmlContent,
    required this.userPoints,
    required this.countdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height / 2.7,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            child: Center(
              child: Text('Rectangle'),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 3.1,
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Points: $userPoints'),
                  ElevatedButton(
                    onPressed: () {
                      _editTeam(context);
                    },
                    child: Text('Edit Team'),
                    style: ElevatedButton.styleFrom(
                      // primary: Colors.blue,
                      //onPrimary: Colors.white,
                      minimumSize: Size(120, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(countdown),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: Text('Score: 0 - 0'),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: Text('Score: 0 - 0'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0),
              InkWell(
                onTap: () {
                  _navigateToMoreMatches(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: Text('More Matches'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editTeam(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditTeamPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, -1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToMoreMatches(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoreMatchesPage()),
    );
  }
}
