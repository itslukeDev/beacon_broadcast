import 'dart:async';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String uuid = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const int majorId = 1;
  static const int minorId = 100;
  static const int transmissionPower = -59;
  static const String identifier = 'com.example.myDeviceRegion';
  static const AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  static const String layout = BeaconBroadcast.altBeaconLayout;
  static const int manufacturerId = 0x0118;
  static final List<int> extraData = [100];

  late BeaconBroadcast beaconBroadcast;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isAdvertising = false;
  BeaconStatus? _isTransmissionSupported;
  StreamSubscription<bool>? _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();
    beaconBroadcast = BeaconBroadcast();

    Permission.bluetoothAdvertise.request();
    getBluetoothStatus();

    beaconBroadcast
        .checkTransmissionSupported()
        .then((BeaconStatus? isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription = beaconBroadcast
        .getAdvertisingStateChange()
        .listen((bool isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  void getBluetoothStatus() async {
    final status = await Permission.bluetoothAdvertise.status;
    setState(() {
      _permissionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Beacon Broadcast'),
        ),
        body: Visibility(
          visible: _permissionStatus.isGranted,
          replacement: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue[100]),
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Please enable Bluetooth permission to use this feature.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          child: BroadcastPage(
              isTransmissionSupported: _isTransmissionSupported,
              isAdvertising: _isAdvertising,
              beaconBroadcast: beaconBroadcast,
              uuid: uuid,
              majorId: majorId,
              minorId: minorId,
              transmissionPower: transmissionPower,
              advertiseMode: advertiseMode,
              identifier: identifier,
              layout: layout,
              manufacturerId: manufacturerId,
              extraData: extraData),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isAdvertisingSubscription?.cancel();
    super.dispose();
  }
}

class BroadcastPage extends StatelessWidget {
  const BroadcastPage({
    super.key,
    required BeaconStatus? isTransmissionSupported,
    required bool isAdvertising,
    required this.beaconBroadcast,
    required this.uuid,
    required this.majorId,
    required this.minorId,
    required this.transmissionPower,
    required this.advertiseMode,
    required this.identifier,
    required this.layout,
    required this.manufacturerId,
    required this.extraData,
  })  : _isTransmissionSupported = isTransmissionSupported,
        _isAdvertising = isAdvertising;

  final BeaconStatus? _isTransmissionSupported;
  final bool _isAdvertising;
  final BeaconBroadcast beaconBroadcast;
  final String uuid;
  final int majorId;
  final int minorId;
  final int transmissionPower;
  final AdvertiseMode advertiseMode;
  final String identifier;
  final String layout;
  final int manufacturerId;
  final List<int> extraData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Is transmission supported?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '$_isTransmissionSupported',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Has beacon started?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '$_isAdvertising',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  beaconBroadcast
                      .setUUID(uuid)
                      .setMajorId(majorId)
                      .setMinorId(minorId)
                      .setTransmissionPower(transmissionPower)
                      .setAdvertiseMode(advertiseMode)
                      .setIdentifier(identifier)
                      .setLayout(layout)
                      .setManufacturerId(manufacturerId)
                      .setExtraData(extraData)
                      .start();
                },
                child: const Text('START'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  beaconBroadcast.stop();
                },
                child: const Text('STOP'),
              ),
            ),
            Text(
              'Beacon Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('UUID: $uuid'),
            Text('Major id: $majorId'),
            Text('Minor id: $minorId'),
            Text('Tx Power: $transmissionPower'),
            Text('Advertise Mode Value: $advertiseMode'),
            Text('Identifier: $identifier'),
            Text('Layout: $layout'),
            Text('Manufacturer Id: $manufacturerId'),
            Text('Extra data: $extraData'),
          ],
        ),
      ),
    );
  }
}
