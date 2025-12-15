import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flock_app/details.dart';
import 'package:flock_app/farmdetails.dart';
import 'package:flock_app/parameters.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flock_app/sensor_service.dart';
import 'package:flock_app/network_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with NetworkMonitor {
  List<Map<String, dynamic>> sens_data_var = []; // Raw MQTT data list
  List<Map<String, dynamic>> sens_data_fil_mob = []; // Filtered data for display
  StreamSubscription? _subscription; // MQTT stream subscription
  Map<String, Map<String, dynamic>> _nodeDataMap = {}; // Stores latest data per node (key: nodeNumber)

  @override
  void initState() {
    super.initState();

    // Initialize network monitoring
    initNetworkMonitoring();

    // Start MQTT connection and listen for sensor data
    sensorService.connectAndListen(mobilenum.text.trim());

    // Subscribe to live MQTT stream
    _subscription = sensorService.stream.listen((freshData) {
      if (freshData.isEmpty || !mounted) return;

      dynamic payload = freshData.first;

      // Decode JSON if payload is string
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } catch (e) {
          return;
        }
      }

      // Parse MQTT payload: {"Records": [{"Sns": {"Message": "{\"Node Number\": \"NDB01001\", ...}"}}]}
      if (payload is Map<String, dynamic> && payload.containsKey('Records')) {
        final records = payload['Records'];
        if (records is List && records.isNotEmpty) {
          for (var record in records) {
            if (record is Map && record.containsKey('Sns')) {
              final sns = record['Sns'];
              if (sns is Map && sns.containsKey('Message')) {
                var message = sns['Message'];
                
                // Decode Message if it's a JSON string
                if (message is String) {
                  try {
                    message = jsonDecode(message);
                  } catch (e) {
                    continue;
                  }
                }

                // Extract node number and map MQTT field names to UI field names
                if (message is Map<String, dynamic>) {
                  final nodeNum = message['Node Number'] ?? message['node_number'];
                  if (nodeNum != null) {
                    // Store mapped sensor data by node number
                    _nodeDataMap[nodeNum.toString()] = {
                      'Node Number': nodeNum,
                      'temperature_celsius': message['Temp'] ?? message['temperature_celsius'],
                      'relative_humidity_percent': message['RH'] ?? message['relative_humidity_percent'],
                      'co2_ppm': message['CO2'] ?? message['co2_ppm'],
                      'nh3_ppm': message['Nh3'] ?? message['nh3_ppm'],
                      'h2s_ppm': message['H2s'] ?? message['h2s_ppm'],
                      'ch4_data': message['CH4'] ?? message['ch4_data'],
                      'soil_moisture': message['Soil Moisture'] ?? message['soil_moisture'],
                      'weight': message['WT'] ?? message['weight'],
                      'battery': message['Battery Per'] ?? message['battery'],
                      'lux': message['Lux'] ?? message['lux'],
                      'timestamp': DateTime.now().toString(),
                    };
                  }
                }
              }
            }
          }

          // Build display structure with node list and data records
          if (_nodeDataMap.isNotEmpty) {
            final mappedNodes = _nodeDataMap.keys.toList()..sort();
            final records = Map<String, dynamic>.from(_nodeDataMap);

            setState(() {
              sens_data_var = [{
                "mapped_nodes": mappedNodes,
                "records": records,
              }];
              sens_data_fil_mob = sens_data_var;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    disposeNetworkMonitoring();
    sensorService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hei = size.height, wid = size.width, fs = wid * 0.3;

    // Extract node list and data records from MQTT stream
    final mappedNodes =
        (sens_data_fil_mob.isNotEmpty &&
                sens_data_fil_mob.first["mapped_nodes"] != null &&
                sens_data_fil_mob.first["mapped_nodes"] is List)
            ? sens_data_fil_mob.first["mapped_nodes"] as List
            : [];

    final records =
        (sens_data_fil_mob.isNotEmpty &&
                sens_data_fil_mob.first["records"] != null &&
                sens_data_fil_mob.first["records"] is Map)
            ? sens_data_fil_mob.first["records"] as Map
            : {};

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          // Network status indicator
          getNetworkStatusIcon(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Flushbar(
                margin: const EdgeInsets.all(15.0),
                icon: const Icon(Icons.info, color: Colors.white),
                message: "List of your Farm Batches",
                flushbarPosition: FlushbarPosition.TOP,
                backgroundColor: Colors.green,
                duration: const Duration(milliseconds: 1500),
              ).show(context);
            },
            icon: const Icon(Icons.help),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: wid),
          const SizedBox(height: 10),
          Image.asset("assets/image/farmer_avatar.png"),
          const SizedBox(height: 10),
          Text(
            "Hi, Farmer",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fs * 0.2),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child:
                  mappedNodes.isEmpty
                      ? Center(
                        child: Text(
                          "No data available\nAdd Farm Batches with + button",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fs * 0.15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      )
                      : GridView.builder(
                        itemCount: mappedNodes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 30,
                              mainAxisSpacing: 30,
                            ),
                        itemBuilder: (context, index) {
                          final mapped_node = mappedNodes[index];

                          return GestureDetector(
                            onTap: () {
                              // Pass the entire records map, details page will extract its node
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsPage(
                                    Map<String, dynamic>.from(records),
                                    mapped_node.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: wid * 0.08,
                                vertical: hei * 0.02,
                              ),
                              decoration: BoxDecoration(
                                color: maincol,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/image/chicken_avatar.png",
                                  ),
                                  const SizedBox(height: 15),
                                  Text("$mapped_node"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          const SizedBox(height: 10),
          MaterialButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FarmDetails()),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(
              vertical: hei * 0.02,
              horizontal: wid * 0.15,
            ),
            color: textcol,
            child: Text(
              "Edit Farm",
              style: TextStyle(
                fontSize: fs * 0.15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            textfie_edit_but = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FarmDetails()),
          );
        },
        backgroundColor: maincol,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
