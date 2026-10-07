import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../screens/offline_screen.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;

  const NetworkWrapper({super.key, required this.child});

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = [ConnectivityResult.none];
    }
    if (!mounted) {
      return Future.value(null);
    }
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: _connectivityStream,
      initialData: _connectionStatus,
      builder: (context, snapshot) {
        final connectivityList = snapshot.data;
        // If the result contains none or is empty, we assume no connection
        final isOffline =
            connectivityList == null ||
            connectivityList.isEmpty ||
            connectivityList.contains(ConnectivityResult.none);

        if (isOffline) {
          return const OfflineScreen();
        }

        return widget.child;
      },
    );
  }
}
