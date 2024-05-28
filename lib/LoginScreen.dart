import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        final database = FirebaseDatabase.instance.ref();
        DatabaseEvent event = await database
            .child('users')
            .child(user.uid)
            .child('formation')
            .once();
        DataSnapshot snapshot = event.snapshot;

        String formation = snapshot.value as String? ?? '4231';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedFormation', formation);

        // Navigate to the main app
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() {
          _errorMessage = 'User is null';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login successful!'),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration successful!'),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _errorMessage = 'Google sign-in cancelled';
        });
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      if (googleAuth == null) {
        setState(() {
          _errorMessage = 'Google authentication failed';
        });
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        final database = FirebaseDatabase.instance.ref();
        DatabaseEvent event = await database
            .child('users')
            .child(user.uid)
            .child('formation')
            .once();
        DataSnapshot snapshot = event.snapshot;

        String formation = snapshot.value as String? ?? '4231';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedFormation', formation);

        // Navigate to the main app
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() {
          _errorMessage = 'User is null';
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Google Sign-In successful!'),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20.0),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20.0),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _login,
                    icon: Icon(Icons.login),
                    label: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: _register,
                    icon: Icon(Icons.person_add),
                    label: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Icon(Icons.golf_course),
                    label: Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, side: BorderSide(color: Colors.black),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
