import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(MyApp());
}

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
  bool isReady = false;
  final String targetUUID = "952f7b6f622c04a2a8407abf6c719dba";
  bool deviceFound = false;
  bool popupShown = false;

  @override
  void initState() {
    super.initState();
    initBle();
  }

  Future<void> initBle() async {
    try {
      await checkBleSupport();
    } catch (e) {
      print('Error initializing BLE: $e');
      showAlertDialog('Initialization Error',
          'Failed to initialize Bluetooth. Please restart the app.');
    }
  }

  Future<void> checkBleSupport() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        showAlertDialog('BLE Not Supported',
            'Bluetooth Low Energy is not supported on this device.');
      } else {
        await requestPermissions();
      }
    } catch (e) {
      print('Error checking BLE support: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses.values.every((status) => status.isGranted)) {
        await checkBluetoothStatus();
      } else {
        showAlertDialog('Permissions Required',
            'Please grant all required permissions to use Bluetooth scanning.');
      }
    } else {
      await checkBluetoothStatus();
    }
  }

  Future<void> checkBluetoothStatus() async {
    try {
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.on) {
          setState(() {
            isReady = true;
          });
        } else {
          setState(() {
            isReady = false;
          });
          showAlertDialog(
              'Bluetooth is Off', 'Please turn on Bluetooth to continue.');
        }
      });
    } catch (e) {
      print('Error checking Bluetooth status: $e');
    }
  }

  void startScan() async {
    if (!isReady) {
      showAlertDialog(
          'Bluetooth is Off', 'Please turn on Bluetooth to scan for devices.');
      return;
    }

    setState(() {
      isScanning = true;
      scanResults.clear();
      deviceFound = false;
      popupShown = false;
    });

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.advertisementData.manufacturerData.isNotEmpty) {
            List<int> manufacturerData =
                result.advertisementData.manufacturerData.values.first;
            String? scannedUUID = getUuid(manufacturerData);
            if (scannedUUID == targetUUID) {
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
        }
        setState(() {
          scanResults = results;
        });
      });
    } catch (e) {
      print('Error starting scan: $e');
    }

    await Future.delayed(Duration(seconds: 4));
    setState(() {
      isScanning = false;
    });
  }

  void showAlertDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void showTargetDeviceFoundDialog() {
    showAlertDialog('Target Device Found',
        'The device with UUID $targetUUID has been found.');
  }

  String? getUuid(List<int> manufacturerData) {
    if (manufacturerData.length >= 18) {
      return manufacturerData
          .sublist(2, 18)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();
    }
    return null;
  }

  void showDeviceDetailsDialog(ScanResult result) {
    String? uuid;
    int? major;
    int? minor;

    if (result.advertisementData.manufacturerData.isNotEmpty) {
      List<int> manufacturerData =
          result.advertisementData.manufacturerData.values.first;
      uuid = getUuid(manufacturerData);
      major = getMajor(manufacturerData);
      minor = getMinor(manufacturerData);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Device Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Name: ${result.device.name.isNotEmpty ? result.device.name : 'Unknown Device'}'),
            Text('MAC Address: ${result.device.remoteId.toString()}'),
            Text('RSSI: ${result.rssi}'),
            if (uuid != null) Text('UUID: $uuid'),
            if (major != null) Text('Major: $major'),
            if (minor != null) Text('Minor: $minor'),
            if (uuid == null && major == null && minor == null)
              Text('No UUID, Major, or Minor data available'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  int? getMajor(List<int> manufacturerData) {
    if (manufacturerData.length >= 20) {
      return (manufacturerData[18] << 8) + manufacturerData[19];
    }
    return null;
  }

  int? getMinor(List<int> manufacturerData) {
    if (manufacturerData.length >= 22) {
      return (manufacturerData[20] << 8) + manufacturerData[21];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isScanning
                  ? 'Scanning for devices...'
                  : (isReady ? 'Tap to scan' : 'Initializing...'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: scanResults.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      ScanResult result = scanResults[index];
                      String? uuid = getUuid(result.advertisementData
                              .manufacturerData.values.firstOrNull ??
                          []);
                      return ListTile(
                        title: Text(result.device.name.isNotEmpty
                            ? result.device.name
                            : 'Unknown Device'),
                        subtitle: Text(uuid ?? 'No UUID'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(result.rssi.toString()),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => showDeviceDetailsDialog(result),
                              child: Text('Details'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                minimumSize: Size(60, 30),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isReady ? startScan : null,
        tooltip: 'Start Scan',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
