import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flock_app/login.dart';
import 'package:flutter/material.dart';

import 'package:flock_app/parameters.dart';
import 'package:flock_app/otp.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final baseUrl = loginurl;
  Future<String> signup({required String mobile}) async {
    try {
      final url = Uri.parse('$baseUrl');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phonenumber': mobile}),
      ).timeout(Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return jsonEncode({'error': 'Server error: ${response.statusCode}'});
      }
    } catch (e) {
      print('Signup API error: $e');
      return jsonEncode({'error': 'Network error: $e'});
    }
  }

  Future<bool> status() async {
    try {
      final response = await signup(mobile: mobilenum.text.trim());
      final res = jsonDecode(response);

      if (res.containsKey('error')) {
        print("API Error: ${res['error']}");
        if (mounted) {
          Flushbar(
            message: "Connection failed. Check internet.",
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
            margin: EdgeInsets.all(15.0),
            icon: Icon(Icons.error_outline, color: Colors.white),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
        return true; // treat error as user exists to prevent accidental bypass
      }

      final userStatus = res['user_status']?.toString().toLowerCase();

      if (userStatus == 'new user added') {
        print("✅ New user created.");
        return false; // false = not existing user
      }

      print("🚫 User already exists or unknown status: $userStatus");
      return true; // true = user exists
    } catch (e) {
      print("❌ Signup error: $e");
      return true; // treat error as user exists to prevent accidental bypass
    }
  }

  @override
  Widget build(BuildContext context) {
    final hei = MediaQuery.of(context).size.height;
    final wid = MediaQuery.of(context).size.width;
    final fs = wid * 0.3;

    return Scaffold(
      body: Container(
        color: maincol,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: wid * 0.2),
                        child: Image.asset(logopath),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Mobile Number",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: fs * 0.24,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please enter to create account",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: fs * 0.15,
                        ),
                      ),
                      Spacer(), // this works now
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(fs * 1.1),
                          ),
                        ),
                        height: hei * 0.45,
                        width: wid,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            textfie(
                              "Mobile Number",
                              "Mobile No. : +919876543210",
                              mobilenum,
                              wid * 0.9,
                              mobilenum.text,
                            ),
                            SizedBox(height: hei * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have account?",
                                  style: TextStyle(
                                    fontSize: fs * 0.15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: fs * 0.15,
                                      fontWeight: FontWeight.bold,
                                      color: textcol,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: hei * 0.01),
                            MaterialButton(
                              onPressed: () async {
                                setState(() {
                                  via_login = false;
                                });
                                bool userExists = await status();

                                if (!userExists) {
                                  // Proceed to OTP
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OTP(),
                                    ),
                                  );
                                } else {
                                  Flushbar(
                                    message:
                                        "User already exists. Please login.",
                                    margin: EdgeInsets.all(15),
                                    icon: Icon(Icons.info, color: Colors.white),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context);
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 50,
                              ),
                              color: textcol,
                              child: Text(
                                "Verify",
                                style: TextStyle(
                                  fontSize: fs * 0.2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
