import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:flock_app/graph.dart';
import 'package:flock_app/parameters.dart';
import 'package:flock_app/sensor_service.dart';
import 'package:flock_app/network_service.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> sens_data_ind;
  final String node;
  const DetailsPage(this.sens_data_ind, this.node, {super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> with NetworkMonitor {
  late Map<String, dynamic> sens_data_f; // Current node's sensor data
  late String node_val; // Current node number (e.g., "NDB01001")
  late Future<Map<String, dynamic>?> _weatherFuture; // Weather API future
  StreamSubscription<List<Map<String, dynamic>>>? _subscription; // MQTT stream subscription

  @override
  void initState() {
    super.initState();
    node_val = widget.node;

    // Initialize network monitoring
    initNetworkMonitoring();

    // Initialize with passed node data from homepage
    final initialData = widget.sens_data_ind[node_val];
    if (initialData != null && initialData is Map<String, dynamic>) {
      sens_data_f = Map<String, dynamic>.from(initialData);
    } else {
      sens_data_f = {};
    }

    // Listen for live MQTT updates for this specific node only
    _subscription = sensorService.stream.listen((data) {
      if (!mounted || data.isEmpty) return;

      dynamic payload = data.first;

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

                // Update only if message is for this node
                if (message is Map<String, dynamic>) {
                  final nodeNum = message['Node Number'] ?? message['node_number'];
                  if (nodeNum != null && nodeNum.toString() == node_val) {
                    // Map MQTT field names to UI field names, preserve last values if new ones are null
                    setState(() {
                      sens_data_f = {
                        'Node Number': nodeNum,
                        'temperature_celsius': message['Temp'] ?? message['temperature_celsius'] ?? sens_data_f['temperature_celsius'],
                        'relative_humidity_percent': message['RH'] ?? message['relative_humidity_percent'] ?? sens_data_f['relative_humidity_percent'],
                        'co2_ppm': message['CO2'] ?? message['co2_ppm'] ?? sens_data_f['co2_ppm'],
                        'nh3_ppm': message['Nh3'] ?? message['nh3_ppm'] ?? sens_data_f['nh3_ppm'],
                        'h2s_ppm': message['H2s'] ?? message['h2s_ppm'] ?? sens_data_f['h2s_ppm'],
                        'ch4_data': message['CH4'] ?? message['ch4_data'] ?? sens_data_f['ch4_data'],
                        'soil_moisture': message['Soil Moisture'] ?? message['soil_moisture'] ?? sens_data_f['soil_moisture'],
                        'weight': message['WT'] ?? message['weight'] ?? sens_data_f['weight'],
                        'battery': message['Battery Per'] ?? message['battery'] ?? sens_data_f['battery'],
                        'lux': message['Lux'] ?? message['lux'] ?? sens_data_f['lux'],
                        'timestamp': DateTime.now().toString(),
                      };
                    });
                  }
                }
              }
            }
          }
        }
      }
    });

    // Fetch weather data for location
    _weatherFuture = getWeatherByCity('Coimbatore');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    disposeNetworkMonitoring();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getWeatherByCity(String city) async {
    try {
      // Get coordinates from city name
      final geoRes = await http.get(
        Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1'),
      );
      if (geoRes.statusCode != 200) return null;

      final geo = jsonDecode(geoRes.body);
      if (geo['results'] == null || geo['results'].isEmpty) return null;

      final lat = geo['results'][0]['latitude'];
      final lon = geo['results'][0]['longitude'];

      // Get weather data from coordinates
      final weatherRes = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon'
          '&current_weather=true&daily=temperature_2m_max,temperature_2m_min'
          '&hourly=relative_humidity_2m&timezone=auto',
        ),
      );
      if (weatherRes.statusCode != 200) return null;

      final w = jsonDecode(weatherRes.body);
      return {
        'avg': num.parse(w['current_weather']['temperature'].toString()).toInt(),
        'min': num.parse(w['daily']['temperature_2m_min'][0].toString()).toInt(),
        'max': num.parse(w['daily']['temperature_2m_max'][0].toString()).toInt(),
        'wind': num.parse(w['current_weather']['windspeed'].toString()).toInt(),
        'humidity': num.parse(w['hourly']['relative_humidity_2m'][0].toString()).toInt(),
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _refreshSensorData() async {
    // Refresh action - data updates automatically via MQTT stream
    setState(() {});
  }

  Widget cirul_data(String path, String tex) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(child: Image.asset(path)),
      Text(
        tex,
        style: TextStyle(
          color: Colors.black,
          fontSize:
              tex.contains('PPM')
                  ? MediaQuery.of(context).size.width * 0.3 * 0.15
                  : MediaQuery.of(context).size.width * 0.3 * 0.2,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wid = size.width, fs = wid * 0.3;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          // Network status indicator
          getNetworkStatusIcon(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Flushbar(
                margin: EdgeInsets.all(15.0),
                icon: Icon(Icons.info, color: Colors.white),
                message:
                    'Farm Batch sensor details\n${sens_data_f["timestamp"] ?? "? "}',
                flushbarPosition: FlushbarPosition.TOP,
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 1500),
              ).show(context);
            },
            icon: Icon(Icons.help),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSensorData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  gradient: lin_gra,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Batch $node_val',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fs * 0.15,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Weather & Sensor Card
              FutureBuilder<Map<String, dynamic>?>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  final wea_data = snapshot.data ?? {};
                  final avg =
                      wea_data['avg'] ??
                      sens_data_f['temperature_celsius'] ??
                      0;
                  final max = wea_data['max'] ?? sens_data_f['temp_max'] ?? avg;
                  final min = wea_data['min'] ?? sens_data_f['temp_min'] ?? avg;
                  final temp = ((avg + min + max) / 3).round();
                  final humid =
                      wea_data['humidity'] ??
                      sens_data_f['relative_humidity_percent'] ??
                      0;
                  final win_sp =
                      wea_data['wind'] ?? sens_data_f['wind_speed'] ?? 0;

                  return Container(
                    width: wid * 0.9,
                    decoration: BoxDecoration(
                      gradient: lin_gra,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.location_on_outlined, size: fs * 0.3),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Coimbatore',
                                  style: TextStyle(
                                    fontSize: fs * 0.18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      '$avg',
                                      style: TextStyle(
                                        fontSize: fs * 0.4,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '℃',
                                      style: TextStyle(
                                        fontSize: fs * 0.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 13),
                                    Column(
                                      children: [
                                        Text(
                                          'H: $max℃',
                                          style: TextStyle(
                                            fontSize: fs * 0.15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'L: $min℃',
                                          style: TextStyle(
                                            fontSize: fs * 0.15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: wid * 0.15),
                            Image.asset('assets/image/cloud_sun_svg.png'),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: wid * 0.9,
                          height: 0.5,
                          color: Colors.black,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/image/Thermometer_svg.png',
                                    ),
                                    Text(
                                      'Temp',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '$temp℃',
                                  style: TextStyle(
                                    color: Color(0xFFC34646),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 80,
                              width: 0.5,
                              color: Colors.black,
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/image/Humidity_svg.png',
                                    ),
                                    Text(
                                      'Humidity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '$humid%',
                                  style: TextStyle(
                                    color: Color(0xFF2434BE),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 80,
                              width: 0.5,
                              color: Colors.black,
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Image.asset('assets/image/Wind_svg.png'),
                                    Text(
                                      'Wind',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${win_sp}Km/hr',
                                  style: TextStyle(
                                    color: Color(0xFF0EE524),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              // Circular sensor metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: wid * 0.18,
                    backgroundColor: Color(0xFFF50000),
                    child: CircleAvatar(
                      radius: (wid * 0.18) - 5,
                      backgroundColor: Colors.white,
                      child: cirul_data(
                        'assets/image/thermome_col_svg.png',
                        sens_data_f["temperature_celsius"] != null 
                          ? '${sens_data_f["temperature_celsius"]}℃'
                          : '--',
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: wid * 0.18,
                    backgroundColor: Color(0xFF1266E2),
                    child: CircleAvatar(
                      radius: (wid * 0.18) - 5,
                      backgroundColor: Colors.white,
                      child: cirul_data(
                        'assets/image/humid_col_svg.png',
                        sens_data_f["relative_humidity_percent"] != null
                          ? '${sens_data_f["relative_humidity_percent"]}%'
                          : '--',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: wid * 0.18,
                    backgroundColor: Color(0xFF0EE524),
                    child: CircleAvatar(
                      radius: (wid * 0.18) - 5,
                      backgroundColor: Colors.white,
                      child: cirul_data(
                        'assets/image/co2_col_svg.png',
                        sens_data_f["co2_ppm"] != null
                          ? '${sens_data_f["co2_ppm"]}PPM'
                          : '--',
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: wid * 0.18,
                    backgroundColor: Color(0xFFF50000),
                    child: CircleAvatar(
                      radius: (wid * 0.18) - 5,
                      backgroundColor: Colors.white,
                      child: cirul_data(
                        'assets/image/ammonia_col_svg.png',
                        sens_data_f["nh3_ppm"] != null
                          ? '${sens_data_f["nh3_ppm"]}PPM'
                          : '--',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: wid * 0.18,
                    backgroundColor: Color(0xFF0EE524),
                    child: CircleAvatar(
                      radius: (wid * 0.18) - 5,
                      backgroundColor: Colors.white,
                      child: cirul_data(
                        'assets/image/H2S_col_svg.png',
                        sens_data_f["h2s_ppm"] != null
                          ? '${sens_data_f["h2s_ppm"]}PPM'
                          : '--',
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: wid * 0.18,
                    backgroundColor: Color(0xFFF50000),
                    child: CircleAvatar(
                      radius: (wid * 0.18) - 5,
                      backgroundColor: Colors.white,
                      child: cirul_data(
                        'assets/image/ch4_col_svg.png',
                        sens_data_f["ch4_data"] != null
                          ? '${sens_data_f["ch4_data"]}PPM'
                          : '--',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GraphScreen(chickData: dummyChickData),
                    ),
                  );
                },
                child: Text(
                  'Analysis',
                  style: TextStyle(
                    fontSize: fs * 0.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
