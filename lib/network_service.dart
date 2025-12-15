import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:another_flushbar/flushbar.dart';

/// Singleton service for network connectivity monitoring
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _isConnected = true;

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result.first != ConnectivityResult.none;
    _controller.add(_isConnected);

    _connectivity.onConnectivityChanged.listen((results) {
      final wasConnected = _isConnected;
      _isConnected = results.first != ConnectivityResult.none;
      if (wasConnected != _isConnected) _controller.add(_isConnected);
    });
  }

  void dispose() => _controller.close();
}

final networkService = NetworkService();

/// Mixin for adding network monitoring UI to any StatefulWidget
mixin NetworkMonitor<T extends StatefulWidget> on State<T> {
  StreamSubscription<bool>? _netSub;
  bool _isConnected = true;

  void initNetworkMonitoring() {
    _isConnected = networkService.isConnected;
    _netSub = networkService.onConnectivityChanged.listen((connected) {
      if (!mounted) return;
      setState(() => _isConnected = connected);
      Flushbar(
        margin: const EdgeInsets.all(15),
        icon: Icon(connected ? Icons.wifi : Icons.wifi_off, color: Colors.white),
        message: connected ? 'Internet Connected' : 'No Internet Connection',
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: connected ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ).show(context);
    });
  }

  void disposeNetworkMonitoring() => _netSub?.cancel();

  Widget getNetworkStatusIcon() => Icon(
    _isConnected ? Icons.wifi : Icons.wifi_off,
    color: _isConnected ? Colors.green : Colors.red,
  );

  bool get isNetworkConnected => _isConnected;
}
