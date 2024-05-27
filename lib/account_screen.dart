import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            user != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        user.photoURL ?? 'https://via.placeholder.com/150'),
                  )
                : Container(),
            SizedBox(height: 20),
            Text(
              'Name: ${user?.displayName ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'UID: ${user?.uid ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
