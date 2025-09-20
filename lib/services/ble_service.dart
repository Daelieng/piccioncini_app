import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/ble_constants.dart';

class BLEService {
  BluetoothDevice? _connectedDevice;
  BluetoothService? _targetService;
  BluetoothCharacteristic? _wifiScanCharacteristic;
  BluetoothCharacteristic? _wifiCommandCharacteristic;
  BluetoothCharacteristic? _wifiConfigCharacteristic;

  Function(String)? onWifiListReceived;
  Function(String)? onStatusMessage;

  bool get isConnected => _connectedDevice != null;

  Future<bool> requestPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final locationStatus = await Permission.locationWhenInUse.request();
    return scanStatus.isGranted && locationStatus.isGranted;
  }

  Future<BluetoothDevice?> scanForDevice(String targetName) async {
    List<ScanResult> results = [];
    
    final subscription = FlutterBluePlus.scanResults.listen((rList) {
      results = rList;
      print("🟢 Nuovi risultati: ${rList.length}");
      for (var r in rList) {
        final name = r.device.name.isNotEmpty ? r.device.name : "<no name>";
        print("  • $name [${r.device.id.id}] RSSI=${r.rssi}");
      }
    });

    print("🔍 Avvio scansione BLE…");
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
    await FlutterBluePlus.isScanning.where((s) => !s).first;
    print("🔍 Scan terminata, tot= ${results.length}");

    await subscription.cancel();

    for (var r in results) {
      if (r.device.name == targetName) {
        print("✅ Trovato target: ${r.device.id.id}");
        return r.device;
      }
    }
    return null;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      onStatusMessage?.call("Connesso a ${device.name}");
      await discoverServices(device);
      return true;
    } catch (e) {
      print("Errore connessione: $e");
      return false;
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final s in services) {
      print("Scoperto Servizi ${s.uuid}");
      if (s.uuid == BLEConstants.SERVICE_UUID) {
        _targetService = s;
        for (final c in s.characteristics) {
          print("Scoperto Caratteristiche ${c}");
          if (c.uuid == BLEConstants.WIFI_SCAN_UUID) {
            _wifiScanCharacteristic = c;
            await c.setNotifyValue(true);
            c.value.listen(_onWifiNotification);
          } else if (c.uuid == BLEConstants.WIFI_COMMAND_UUID) {
            _wifiCommandCharacteristic = c;
          } else if (c.uuid == BLEConstants.WIFI_CFG_UUID) {
            _wifiConfigCharacteristic = c;
          }
        }
        break;
      }
    }
  }

  void _onWifiNotification(List<int> data) {
    if (data.isNotEmpty) {
      final raw = utf8.decode(data);
      print("Notifica Wi‑Fi ricevuta: $raw");
      onWifiListReceived?.call(raw);
    } else {
      print("Conferma iscrizione");
    }
  }

  Future<bool> sendWifiScanCommand() async {
    if (_wifiCommandCharacteristic == null) return false;
    
    try {
      print("Invio comando WiFi scan...");
      await _wifiCommandCharacteristic!
          .write(utf8.encode("START_WIFI_SCAN"), withoutResponse: false);
      onStatusMessage?.call("Comando Wi‑Fi inviato");
      return true;
    } catch (e) {
      print("Errore sendCommand: $e");
      return false;
    }
  }

  Future<void> sendWifiCredentials(String ssid, String password) async {
    if (_wifiConfigCharacteristic == null) return;
    
    try {
      await _wifiConfigCharacteristic!.write(
        utf8.encode('%%$ssid%%$password%%'),
        withoutResponse: _wifiConfigCharacteristic!.properties.writeWithoutResponse,
      );
    } catch (e) {
      print("Errore invio credenziali WiFi: $e");
    }
  }

  Future<List<String>?> readWifiList() async {
    if (_wifiScanCharacteristic == null) return null;
    
    try {
      List<int>? data = await _wifiScanCharacteristic!.read();
      if (data == null) return null;
      
      String lista = utf8.decode(data).replaceAll(RegExp(r'[\[\]]'), '');
      return lista
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      print("Errore lettura WiFi: $e");
      return null;
    }
  }

  void disconnect() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _targetService = null;
    _wifiScanCharacteristic = null;
    _wifiCommandCharacteristic = null;
    _wifiConfigCharacteristic = null;
  }
}