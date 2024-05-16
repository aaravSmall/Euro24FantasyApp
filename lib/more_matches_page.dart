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
          // You can customize this widget to display match details
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      'https://via.placeholder.com/200',
                      width: 100,
                      height: 100,
                    ),
                    Image.network(
                      'https://via.placeholder.com/200',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
                SizedBox(height: 10), // Adjust spacing between images and scores
                // Scores and "more" text
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Home: 2 - Away: 1'), 
                      // "More" text
                      SizedBox(height: 5), // Adjust spacing between scores and "more" text
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
