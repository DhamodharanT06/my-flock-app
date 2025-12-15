import 'dart:io';

import 'package:flock_app/farmdetails.dart';
import 'package:flock_app/homepage.dart';
import 'package:flock_app/parameters.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class OTP extends StatefulWidget {
  const OTP({super.key});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  //
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  //
  // Function to return otp in 4 digit string
  String otpreturn() {
    String otpans = "";
    for (int i = 0; i < _controllers.length; i++) {
      otpans += _controllers[i].text;
    }
    return otpans;
  }

  //
  Widget otpTextField({
    required TextEditingController controller,
    required FocusNode currentNode,
    FocusNode? nextNode,
    double width = 75,
    String? initialValue,
    required int ind,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        focusNode: currentNode,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          fillColor: Colors.black12,
          filled: true,
          counterText: "",
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        onTap: () {
          if (controller.text.isEmpty) {
            controller.text = initialValue ?? '';
          }
        },
        onChanged: (val) {
          if (val.length == 1 && nextNode != null) {
            FocusScope.of(currentNode.context!).requestFocus(nextNode);
          } else if (val.isEmpty) {
            FocusScope.of(currentNode.context!).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hei = MediaQuery.of(context).size.height;
    final wid = MediaQuery.of(context).size.width;
    final fs = wid * 0.3;
    //

    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincol,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, size: fs * 0.3),
        ),
        actions: [
          IconButton(
            onPressed: () {
              for (int i = 0; i < _controllers.length; i++) {
                print("$i = ${_controllers[i].text}");
              }
            },
            icon: Icon(Icons.help, size: fs * 0.3),
          ),
        ],
      ),
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
                      SizedBox(height: hei * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: wid * 0.2),
                        child: Image.asset(logopath),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "OTP",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: fs * 0.24,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please enter the otp sent to your mobile no",
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                return otpTextField(
                                  controller: _controllers[index],
                                  currentNode: _focusNodes[index],
                                  width: wid * 0.2,
                                  nextNode:
                                      index < 3 ? _focusNodes[index + 1] : null,
                                  ind: index,
                                );
                              }),
                            ),

                            SizedBox(height: hei * 0.03),
                            Text(
                              "Didn’t recieve otp",
                              style: TextStyle(
                                fontSize: fs * 0.15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                clearAllControllers(otplist);
                              },
                              child: Text(
                                "Resend OTP",
                                style: TextStyle(
                                  fontSize: fs * 0.15,
                                  fontWeight: FontWeight.bold,
                                  color: textcol,
                                ),
                              ),
                            ),
                            SizedBox(height: hei * 0.01),
                            MaterialButton(
                              onPressed: () async {
                                print("OTP of the number : " + otpreturn());

                                // Navigator.push(  q2
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => FarmDetails(),
                                //   ),
                                // );
                                if (otpreturn().length == 4) {
                                  print(await File(privateKeyPath).exists());

                                  if (via_login) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FarmDetails(),
                                      ),
                                    );
                                  }
                                } else {
                                  Flushbar(
                                    margin: EdgeInsets.all(15.0),
                                    icon: Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                    ),
                                    message: "Enter correct OTP",
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context);
                                }
                              },
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 50,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
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
