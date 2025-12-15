import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'parameters.dart';

/// Singleton service for managing MQTT connection and sensor data streaming
class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  // Broadcast stream controller to send MQTT data to all listeners (homepage, details page)
  final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get stream => _controller.stream;

  late MqttServerClient _client; // MQTT client for AWS IoT connection
  bool _connected = false; // Connection status flag

  /// Connect to MQTT broker and start listening for sensor data messages
  Future<void> connectAndListen(String phone) async {
    try {
      // Load SSL certificates for secure AWS IoT connection
      final cert = await rootBundle.load(certPath);
      final key = await rootBundle.load(privateKeyPath);
      final ca = await rootBundle.load(caPath);

      final securityContext = SecurityContext.defaultContext;
      securityContext.useCertificateChainBytes(cert.buffer.asUint8List());
      securityContext.usePrivateKeyBytes(key.buffer.asUint8List());
      securityContext.setTrustedCertificatesBytes(ca.buffer.asUint8List());

      // Initialize MQTT client with AWS IoT endpoint
      _client = MqttServerClient.withPort(
        sens_data,
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        8883,
      );

      _client.secure = true;
      _client.securityContext = securityContext;
      _client.logging(on: false);
      _client.keepAlivePeriod = 20;
      _client.onDisconnected = _onDisconnected;
      _client.onConnected = _onConnected;
      _client.onSubscribed = _onSubscribed;

      _client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      await _client.connect();
    } catch (e) {
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _connected = true;
      const topic = 'iotvalue'; // Main MQTT topic for sensor data
      _client.subscribe(topic, MqttQos.atMostOnce);

      // Listen for incoming MQTT messages and broadcast to stream
      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        if (c == null || c.isEmpty) return;

        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        try {
          final decoded = jsonDecode(payload);
          List<Map<String, dynamic>> dataList = [];

          if (decoded is Map<String, dynamic>) {
            dataList.add(decoded);
          } else if (decoded is List) {
            for (var item in decoded) {
              if (item is Map<String, dynamic>) dataList.add(item);
            }
          }

          if (dataList.isNotEmpty) {
            _controller.add(dataList); // Broadcast to all listeners
          }
        } catch (e) {
          // Ignore malformed messages
        }
      });
    } else {
      _client.disconnect();
    }
  }

  void _onConnected() {}
  void _onDisconnected() {}
  void _onSubscribed(String topic) {}

  /// Disconnect from MQTT broker
  void disconnect() {
    if (_connected) {
      _client.disconnect();
      _connected = false;
    }
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _controller.close();
  }
}

final sensorService = SensorService();
