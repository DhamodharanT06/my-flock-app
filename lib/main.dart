import 'package:flock_app/login.dart';
import 'package:flock_app/parameters.dart';
import 'package:flock_app/network_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize network service
  await networkService.initialize();
  
  runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and then navigate to NextPage
    fetchAndNavigate();
  }

  @override
  void dispose() {
    super.dispose();
    clearAllControllers(allControllers);
  }

  Future<void> fetchAndNavigate() async {
    await Future.delayed(Duration(seconds: 2)); // Splash screen delay
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final wid = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: maincol,
        child: Padding(
          padding: EdgeInsets.all(wid * 0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(logopath),
              SizedBox(height: 20),

              Text(
                "ಸ್ವಾಗತ",
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontSize: wid * 0.3 * 0.24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
