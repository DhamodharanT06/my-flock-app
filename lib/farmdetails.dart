import 'package:another_flushbar/flushbar.dart';
import 'package:flock_app/homepage.dart';
import 'package:flock_app/parameters.dart';
import 'package:flutter/material.dart';

class FarmDetails extends StatefulWidget {
  const FarmDetails({super.key});

  @override
  State<FarmDetails> createState() => _FarmDetailsState();
}

class _FarmDetailsState extends State<FarmDetails> {
  String farmerid = "Farmerid", email = "Email";

  Widget textforcard(String text, double fss) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fss,
        color: Colors.black,
        fontFamily: fontpoppins,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget build(BuildContext context) {
    //
    final size = MediaQuery.of(context).size;
    final hei = size.height, wid = size.width, fs = wid * 0.3;
    //
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //
              SizedBox(height: hei * 0.05),
              Center(
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  width: wid * 0.9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Color(0xFFF1BD27).withAlpha(140),
                        Color(0xFFF88523),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                          textforcard("Profile", fs * 0.25),
                          IconButton(
                            onPressed: () {
                              Flushbar(
                                margin: EdgeInsets.all(15.0),
                                icon: Icon(Icons.info, color: Colors.white),
                                message:
                                    "Enter the new Farm Batch details and fill all data",
                                flushbarPosition: FlushbarPosition.TOP,
                                backgroundColor: Colors.green,
                                duration: Duration(milliseconds: 1500),
                              ).show(context);
                            },
                            icon: Icon(Icons.help),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: wid * 0.05),
                          Container(
                            child: Image.asset("assets/image/user_avatar.png"),
                            decoration: BoxDecoration(
                              color: Color(0xFFE8DBDB),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white,
                                width: 4.0,
                              ),
                            ),
                          ),
                          SizedBox(width: wid * 0.1),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              textforcard(farmerid, fs * 0.18),
                              textforcard(email, fs * 0.13),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              //
              SizedBox(height: hei * 0.06),
              textfie("Name", "Name :", name_f, wid * 0.9, name_f.text),
              SizedBox(height: hei * 0.03),
              textfie(
                "Farm Name",
                "Farm Name :",
                farm_name_f,
                wid * 0.9,
                farm_name_f.text,
              ),
              SizedBox(height: hei * 0.03),
              textfie("Email", "Email :", email_f, wid * 0.9, email_f.text),
              SizedBox(height: hei * 0.03),
              textfie("UID", "UID number :", uid_f, wid * 0.9, uid_f.text),
              SizedBox(height: hei * 0.03),
              textfie(
                "Whatsapp Number",
                "Whatsapp No. :",
                whatsno_f,
                wid * 0.9,
                mobilenum.text,
              ),
              SizedBox(height: hei * 0.03),
              textfie(
                "Address",
                "Address :",
                address_f,
                wid * 0.9,
                address_f.text,
              ),
              SizedBox(height: hei * 0.03),
              textfie("City", "City :", city_f, wid * 0.9, city_f.text),
              SizedBox(height: hei * 0.03),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.black12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Veterinarian/Consultant :"),
                    DropdownButton<String>(
                      value: vert_or_cons_f,
                      onChanged: (String? newValue) {
                        setState(() {
                          vert_or_cons_f = newValue!;
                          if (newValue == "Veterinarian") {
                            vert_f = true;
                            cons_f = false;
                          } else if (newValue == "Consultant") {
                            vert_f = false;
                            cons_f = true;
                          } else {
                            vert_f = false;
                            cons_f = false;
                          }
                        });
                      },
                      items:
                          dropdownItems.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: hei * 0.03),
              Visibility(
                visible: vert_f,
                child: Column(
                  children: [
                    textfie(
                      "Veterinarian Name",
                      "Veterinarian Name :",
                      vert_name_f,
                      wid * 0.9,
                      vert_name_f.text,
                    ),
                    SizedBox(height: hei * 0.03),
                    textfie(
                      "Veterinarian Number",
                      "Veterinarian Number :",
                      vert_num_f,
                      wid * 0.9,
                      vert_num_f.text,
                    ),
                    SizedBox(height: hei * 0.03),
                  ],
                ),
              ),
              Visibility(
                visible: cons_f,
                child: Column(
                  children: [
                    textfie(
                      "Consultant Name",
                      "Consultant Name :",
                      cons_name_f,
                      wid * 0.9,
                      cons_name_f.text,
                    ),
                    SizedBox(height: hei * 0.03),
                    textfie(
                      "Consultant Number",
                      "Consultant Number :",
                      cons_num_f,
                      wid * 0.9,
                      cons_num_f.text,
                    ),
                    SizedBox(height: hei * 0.03),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        textfie_edit_but = false;
                      });
                    },
                    padding: EdgeInsets.symmetric(
                      vertical: hei * 0.02,
                      horizontal: wid * 0.15,
                    ),
                    color: textcol,
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: fs * 0.15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print(via_login);
                      if (!via_login) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    padding: EdgeInsets.symmetric(
                      vertical: hei * 0.02,
                      horizontal: wid * 0.15,
                    ),
                    color: textcol,
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: fs * 0.15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: hei * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
