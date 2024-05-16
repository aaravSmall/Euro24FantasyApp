import 'package:flutter/material.dart';

class MoreMatchesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More Matches'),
      ),
      body: ListView.builder(
        itemCount: 10, // Change this to the number of matches you want to display
        itemBuilder: (context, index) {
          // You can customize this ListTile to display match details
          return ListTile(
            title: Text('Match ${index + 1}'),
            subtitle: Text('Details of the match'),
            onTap: () {
              // Add functionality if you want to handle tapping on a match
            },
          );
        },
      ),
    );
  }
}
