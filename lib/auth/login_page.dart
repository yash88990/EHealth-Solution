import 'package:ehealthsolution/auth/signup_screen.dart';
import 'package:ehealthsolution/doctor/doctor_home_page.dart';
import 'package:ehealthsolution/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Image.asset('assets/images/plus.png' , width: 200, height: 200,),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome!',
                        style: GoogleFonts.poppins(
                            fontSize: 32, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Login first',
                        style: GoogleFonts.poppins(
                            fontSize: 24, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 60),
                      TextFormField(
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: _inputDecoration('Email'),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: _inputDecoration('Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureText,
                        onChanged: (val) => password = val,
                        validator: (val) => val!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0064FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => RegisterPage()));
                                },
                          child: Text(
                            'Don’t have an account? Register',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xffF0EFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      labelText: label,
      labelStyle:
          GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xff0064FA), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xff0064FA), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xff0064FA), width: 1.0),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        DatabaseReference userRef = _database.child('Doctors').child(user.uid);
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          _navigateToPage(const DoctorHomePage());
        } else {
          userRef = _database.child('Patients').child(user.uid);
          snapshot = await userRef.get();
          if (snapshot.exists) {
            _navigateToPage(const PatientHomePage());
          } else {
            _showErrorDialog('User role not found. Please contact support.');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_getErrorMessage(e.code));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToPage(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
