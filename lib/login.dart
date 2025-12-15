import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flock_app/signup.dart';
import 'package:flutter/material.dart';

import 'package:flock_app/parameters.dart';
import 'package:flock_app/otp.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final baseUrl = loginurl;

  Future<Map<String, dynamic>> login({required String mobile}) async {
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
        return jsonDecode(response.body);
      } else {
        return {'error': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Login API error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  Future<bool> status() async {
    try {
      final res = await login(mobile: mobilenum.text.trim());

      if (res.containsKey('error')) {
        print("API Error: ${res['error']}");
        // Show error to user
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
        return false;
      }

      if (res.containsKey('phonenumber')) {
        print("Login successful for: ${res['phonenumber']}");
        return true;
      }

      print("Unexpected response: $res");
      return false;
    } catch (e) {
      print("Login exception: $e");
      return false;
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
                        "Please enter your number to log in",
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
                        height: hei * 0.48,
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
                            // Text(
                            //   "Number Format Example:\n+919876543210",
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w500,
                            //     fontSize: fs * 0.15,
                            //   ),
                            //   textAlign: TextAlign.center,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have account?",
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
                                        builder: (context) => SignUp(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign Up",
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
                                  via_login = true;
                                });

                                final userExists = await status();

                                if (userExists) {
                                  print(
                                    "Sending login request for: ${mobilenum.text.trim()}",
                                  );
                                  Flushbar(
                                    message: "User exists",
                                    backgroundColor: Colors.green,
                                    duration: Duration(milliseconds: 800),
                                    margin: EdgeInsets.all(15.0),
                                    icon: Icon(Icons.info),
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context);
                                  await Future.delayed(
                                    Duration(milliseconds: 900),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OTP(),
                                    ),
                                  );
                                } else {
                                  Flushbar(
                                    margin: EdgeInsets.all(15),
                                    icon: Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                    ),
                                    message:
                                        "User not Found\n..Create Account..",
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context);
                                }

                                print("IS Status: $userExists");
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
                                "Submit",
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
