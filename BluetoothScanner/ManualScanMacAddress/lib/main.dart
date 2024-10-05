import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothScannerPage(),
    );
  }
}

class BluetoothScannerPage extends StatefulWidget {
  @override
  _BluetoothScannerPageState createState() => _BluetoothScannerPageState();
}

class _BluetoothScannerPageState extends State<BluetoothScannerPage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  Timer? scanTimer;
  final String targetMacAddress = "B0:A7:32:DA:98:B2";
  bool deviceFound = false;
  bool popupShown = false;

  @override
  void initState() {
    super.initState();
    checkBleSupport();
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    super.dispose();
  }

  void checkBleSupport() async {
    try {
      bool isSupported = await FlutterBluePlus.isAvailable;
      if (!isSupported) {
        print('BLE is not supported on this device');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('BLE Not Supported'),
            content:
                Text('Bluetooth Low Energy is not supported on this device.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        requestPermissions();
      }
    } catch (e) {
      print('Error checking BLE support: $e');
    }
  }

  void requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses.values.every((status) => status.isGranted)) {
        checkBluetoothStatus();
      } else {
        print('Permissions not granted');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permissions Required'),
            content: Text(
                'Please grant all required permissions to use Bluetooth scanning.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      checkBluetoothStatus();
    }
  }

  void checkBluetoothStatus() async {
    try {
      bool isOn = await FlutterBluePlus.isOn;
      if (isOn) {
        startScan();
        startContinuousScan();
      } else {
        print('Bluetooth is off');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Bluetooth is Off'),
            content: Text('Please turn on Bluetooth to continue.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error checking Bluetooth status: $e');
    }
  }

  void startContinuousScan() {
    scanTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      startScan();
    });
  }

  void startScan() async {
    bool isOn = await FlutterBluePlus.isOn;
    if (!isOn) {
      print('Bluetooth is off');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Bluetooth is Off'),
          content: Text('Please turn on Bluetooth to scan for devices.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    await FlutterBluePlus.stopScan();

    setState(() {
      isScanning = true;
      scanResults.clear();
      deviceFound = false;
    });

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.remoteId.toString() == targetMacAddress) {
            setState(() {
              deviceFound = true;
            });
            if (!popupShown) {
              showTargetDeviceFoundDialog();
              popupShown = true;
            }
            break;
          }
        }
        setState(() {
          scanResults = results;
        });
      });
    } catch (e) {
      print('Error starting scan: $e');
      setState(() {
        isScanning = false;
      });
    }

    await Future.delayed(Duration(seconds: 4));
    setState(() {
      isScanning = false;
    });
  }

  void showTargetDeviceFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Target Device Found'),
        content: Text(
            'The device with MAC Address $targetMacAddress has been found.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isScanning
                  ? 'Scanning for devices...'
                  : (deviceFound
                      ? 'Target device found: $targetMacAddress'
                      : 'Target device not found. Waiting for next scan...'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: scanResults.isEmpty
                ? Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      ScanResult result = scanResults[index];
                      return ListTile(
                        title: Text(result.device.name.isNotEmpty
                            ? result.device.name
                            : 'Unknown Device'),
                        subtitle: Text(result.device.remoteId.toString()),
                        trailing: Text(result.rssi.toString()),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startScan,
        child: Icon(Icons.refresh),
        tooltip: 'Start Scan',
      ),
    );
  }
}
