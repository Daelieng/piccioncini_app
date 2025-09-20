import 'package:flutter/material.dart';
import '../services/ble_service.dart';
import '../services/polling_service.dart';
import '../managers/emotion_manager.dart';
import '../managers/user_manager.dart';
import '../models/server_models.dart';
import '../widgets/emotion_box_widget.dart';
import '../widgets/image_box_widget.dart';
import '../widgets/wifi_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final BLEService _bleService;
  late final EmotionManager _emotionManager;
  late final PollingService _pollingService;
  late final UserManager _userManager;
  
  bool _isLoading = false;
  List<StatusDataPoint> _statusHistory = [];

  @override
  void initState() {
    super.initState();
    _bleService = BLEService();
    _emotionManager = EmotionManager();
    _pollingService = PollingService();
    _userManager = UserManager();
    
    // Inizializza il UserManager
    _userManager.initialize();
    
    // Setup callbacks per BLE
    _bleService.onWifiListReceived = _onWifiListReceived;
    _bleService.onStatusMessage = _showSnackBar;
    
    // Setup callbacks per polling
    _pollingService.onDataReceived = _onStatusDataReceived;
    _pollingService.onError = _showSnackBar;
    
    // Listen to emotion changes
    _emotionManager.addListener(() {
      setState(() {});
    });

    // Listen to user selection changes
    _userManager.addListener(() {
      setState(() {});
    });

    // Avvia polling
    _pollingService.startPolling();
  }

  @override
  void dispose() {
    _bleService.disconnect();
    _emotionManager.dispose();
    _pollingService.dispose();
    _userManager.dispose();
    super.dispose();
  }

  void _onStatusDataReceived(StatusDataPoint dataPoint) {
    setState(() {
      _statusHistory.add(dataPoint);
      // Mantieni solo gli ultimi 20 punti per performance UI
      if (_statusHistory.length > 20) {
        _statusHistory.removeAt(0);
      }
    });
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  Future<void> _onBluetoothPressed() async {
    setState(() => _isLoading = true);

    try {
      // Richiedi permessi
      if (!await _bleService.requestPermissions()) {
        _showSnackBar("Permessi Bluetooth non concessi");
        return;
      }

      // Cerca dispositivo
      final device = await _bleService.scanForDevice("Piccioncino_Ila");
      
      if (device != null) {
        await _bleService.connectToDevice(device);
      } else {
        WiFiDialog.showDeviceNotFound(context, "Piccioncino_Ila");
      }
    } catch (e) {
      print("Errore Bluetooth: $e");
      _showSnackBar("Errore di connessione Bluetooth");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBluetoothConnection() async {
    if (_bleService.isConnected) {
      _bleService.disconnect();
      setState(() {});
      _showSnackBar("Disconnesso");
    } else {
      await _onBluetoothPressed();
    }
  }

  Future<void> _sendWifiCommand() async {
    setState(() => _isLoading = true);
    try {
      await _bleService.sendWifiScanCommand();
    } catch (e) {
      print("Errore comando WiFi: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onWifiListReceived(String rawData) {
    WiFiDialog.showWifiList(context, rawData, _onWifiSelected);
  }

  Future<void> _onWifiSelected(String ssid) async {
    final password = await WiFiDialog.showPasswordDialog(context, ssid);
    if (password != null) {
      await _bleService.sendWifiCredentials(ssid, password);
      _showSnackBar("Credenziali WiFi inviate");
    }
  }

  Future<void> _showEmotionPicker(int boxIndex) async {
    final selectedIndex = await _emotionManager.showEmotionSelectionDialog(context);
    if (selectedIndex != null && selectedIndex >= 0) {
      _emotionManager.setSelectedEmotion(boxIndex, selectedIndex);
    }
  }

  void _onUserImageLongPress(int userIndex) {
    _userManager.selectUser(userIndex);
  }

  Widget _buildUserRow(int userIndex, String imagePath, Color boxColor) {
    final isSelected = _userManager.isUserSelected(userIndex);
    final showControls = _userManager.shouldShowControls(userIndex);
    
    return Expanded(
      flex: isSelected ? _userManager.getMainRowFlex() : _userManager.getSecondaryRowFlex(),
      child: Row(
        children: [
          // Colonna immagine
          Expanded(
            flex: 3,
            child: GestureDetector(
              onLongPress: () => _onUserImageLongPress(userIndex),
              child: Container(
                decoration: BoxDecoration(
                  border: isSelected 
                    ? Border.all(color: Colors.blue, width: 3)
                    : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ImageBoxWidget(
                  imagePath: imagePath,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Colonna box emozionale
          Expanded(
            flex: 4,
            child: EmotionBoxWidget(
              boxColor: boxColor,
              emotion: _emotionManager.emotions[
                _emotionManager.selectedEmotionIndex[userIndex]
              ],
              isBluetoothConnected: _bleService.isConnected,
              isLoading: _isLoading,
              showControlButtons: showControls, // Usa il parametro corretto del tuo widget
              onEmotionTap: () => _showEmotionPicker(userIndex),
              onBluetoothTap: showControls ? _toggleBluetoothConnection : null,
              onWifiTap: showControls ? _sendWifiCommand : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Piccioncini App",
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Piccioncini App",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Riga utente 1 (femmina)
              _buildUserRow(0, 'assets/female_img.png', Colors.blue[200]!),
              
              SizedBox(height: 16),
              
              // Riga utente 2 (maschio)
              _buildUserRow(1, 'assets/male_img.png', Colors.green[200]!),
            ],
          ),
        ),
      ),
    );
  }
}