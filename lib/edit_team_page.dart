import 'package:flutter/material.dart';
import 'search_player_page.dart';

class EditTeamPage extends StatefulWidget {
  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 70,
            right: 30,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement the functionality for the first button
                  },
                  child: Text('Button 1'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Implement the functionality for the second button
                  },
                  child: Text('Button 2'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Implement the functionality for the third button
                  },
                  child: Text('Button 3'),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                    _buildSearchButton(),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPlayerPage()),
        );
      },
      child: Container(
        width: 80,
        height: 100,
        color: Colors.blue,
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
