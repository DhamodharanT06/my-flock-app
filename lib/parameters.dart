import 'package:flutter/material.dart';

Color maincol = Color(0xFFFFD470);
Color textcol = Color(0xFfF6780D);
LinearGradient lin_gra = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
  colors: <Color>[Color(0xFFF1BD27).withAlpha(120), Color(0xFFF88523)],
);
LinearGradient lin_gra_1 = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: <Color>[
    Color(0xFFFF3C3C).withAlpha(100),
    Color(0xFFF91919).withAlpha(200),
  ],
);

// Main Data
String logopath = "assets/image/rooster_logo.png";
String fontpoppins = "Poppins";

// Login Page
TextEditingController mobilenum = TextEditingController();
final List<TextEditingController> _controllers = List.generate(
  4,
  (_) => TextEditingController(),
);
bool via_login = true;

// Farm Details Page
TextEditingController name_f = TextEditingController();
TextEditingController farm_name_f = TextEditingController();
TextEditingController email_f = TextEditingController();
TextEditingController uid_f = TextEditingController();
TextEditingController whatsno_f = TextEditingController();
TextEditingController address_f = TextEditingController();
TextEditingController city_f = TextEditingController();
String vert_or_cons_f = "None";
List<String> dropdownItems = ['None', 'Veterinarian', 'Consultant'];
bool vert_f = false, cons_f = false;
TextEditingController vert_name_f = TextEditingController();
TextEditingController cons_name_f = TextEditingController();
TextEditingController vert_num_f = TextEditingController();
TextEditingController cons_num_f = TextEditingController();
bool batch_show = false, medication_show = false;
bool textfie_edit_but = false;
int chick_count_b_d = 20,
    batch_age_b_d = 3,
    feed_b_d = 20,
    avg_wei_b_d = 200,
    morta_b_d = 20;

//

const String loginurl =
    'https://lm6pfwq1li.execute-api.ap-south-1.amazonaws.com/dev/userLogin';
const String sens_data = "a709gubess6fb-ats.iot.ap-south-1.amazonaws.com";
const String graph_url =
    "https://lm6pfwq1li.execute-api.ap-south-1.amazonaws.com/dev/fetchAvgData";

const certPath = "assets/certs/device_certificate.crt";
const privateKeyPath = "assets/certs/private_key.key";
const caPath = "assets/certs/AmazonRootCA1.pem";

// Function for getting input (TextField)
Widget textfie(
  String name,
  String hint,
  TextEditingController conc,
  double wi,
  String? val_text,
) {
  return Container(
    width: wi,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: (name == " " ? 15 : 20)),
      child: TextField(
        onTap: () {
          conc.text = val_text!;
        },
        controller: conc,
        maxLength: name == " " ? 1 : 1000,
        textAlign: name == " " ? TextAlign.center : TextAlign.start,
        maxLines: name == "Address" ? 4 : 1,
        keyboardType: name == " " ? TextInputType.number : TextInputType.text,
        readOnly: textfie_edit_but,
        decoration: InputDecoration(
          fillColor: Colors.black12,
          filled: true,
          hintText: hint,
          labelText: name,
          counterText: "",
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ), // or any color you want on focus
          ),
        ),
      ),
    ),
  );
}

//  For clearing all controllers at a time
final List<TextEditingController> otplist = _controllers;
final List<TextEditingController> allControllers = [
  // OTP
  mobilenum,
  _controllers[0],
  _controllers[1],
  _controllers[2],
  _controllers[3],
  // Farm Details
  name_f,
  farm_name_f,
  email_f, uid_f,
  whatsno_f,
  address_f, city_f,
  vert_name_f, vert_num_f,
  cons_name_f, cons_num_f,
];

void clearAllControllers(List<TextEditingController> allcon) {
  for (final contr in allcon) {
    contr.clear();
  }
}

final dummyChickData = [
  {
    "timestamp": "2025-07-28 09:00:00",
    "temperature_celsius": 27,
    "relative_humidity_percent": 60,
    "weight_kg": 1.2,
  },
  {
    "timestamp": "2025-07-28 15:00:00",
    "temperature_celsius": 28,
    "relative_humidity_percent": 62,
    "weight_kg": 1.3,
  },
  {
    "timestamp": "2025-07-29 09:00:00",
    "temperature_celsius": 29,
    "relative_humidity_percent": 64,
    "weight_kg": 1.4,
  },
  {
    "timestamp": "2025-07-30 09:00:00",
    "temperature_celsius": 30,
    "relative_humidity_percent": 66,
    "weight_kg": 1.6,
  },
  {
    "timestamp": "2025-07-31 09:00:00",
    "temperature_celsius": 29,
    "relative_humidity_percent": 65,
    "weight_kg": 1.8,
  },
  {
    "timestamp": "2025-08-01 09:00:00",
    "temperature_celsius": 28,
    "relative_humidity_percent": 63,
    "weight_kg": 2.0,
  },
  {
    "timestamp": "2025-08-02 09:00:00",
    "temperature_celsius": 27,
    "relative_humidity_percent": 62,
    "weight_kg": 2.1,
  },
];

// Future<void> sendOtp(String mobile) async {
//   final url = Uri.parse('$otpUrl'); // your OTP API
//   final response = await http.post(
//     url,
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'phonenumber': mobile}),
//   );
//
//   print('OTP Status: ${response.statusCode}');
//   print('OTP Response: ${response.body}');
// }
// await sendOtp(mobilenum.text.trim());
//
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => OTP()),
// );

// 📊 Top 5 SMS/OTP APIs Comparison Table
// Provider	Free Limit	Cost (Approx)	Usage Area	Advantages	Disadvantages
// Twilio	$15 trial credits	₹0.35/SMS (India)	🌍 Global	Reliable, Global, API	Costly, Verified-Only, Setup
// Fast2SMS	₹50–₹100 credits	₹0.12–₹0.20/SMS	🇮🇳 India only	Cheap, Fast, Easy	India-Only, Docs-Poor, Spam Risk
// MSG91	10 Free SMS	₹0.18–₹0.26/SMS	🇮🇳 India + Global	OTP-Focused, Scalable, Secure	Signup-Heavy, UI-Old, Confusing Plans
// Textbelt	1 SMS/day (Free key)	$0.04/SMS (Paid)	🇺🇸 Mostly US	Simple, No Signup, Quick	1 SMS/day, No Logs, Not Global
// D7 Networks	Trial credits	₹0.25–₹0.35/SMS	🌍 Global	API-Ready, Global, Secure	Trial Limited, Less Docs, Slower Setup
