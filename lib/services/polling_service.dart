import 'dart:async';
import '../constants/wifi_constants.dart';
import '../models/server_models.dart';
import 'api_service.dart';

class PollingService {
  Timer? _timer;
  Function(StatusDataPoint)? onDataReceived;
  Function(String)? onError;
  
  bool _isRunning = false;
  List<StatusDataPoint> _dataHistory = [];
  
  bool get isRunning => _isRunning;
  List<StatusDataPoint> get dataHistory => _dataHistory;

  void startPolling() {
    if (_isRunning) return;
    
    _isRunning = true;
    print('🔄 Avvio polling ogni ${WiFiConstants.POLLING_INTERVAL.inSeconds}s');
    print('🎯 Target: ${WiFiConstants.BASE_URL}${WiFiConstants.getDeviceAppEndpoint}');
    
    // Prima richiesta immediata
    _fetchData();
    
    // Poi polling periodico
    _timer = Timer.periodic(WiFiConstants.POLLING_INTERVAL, (_) {
      _fetchData();
    });
  }

  void stopPolling() {
    if (!_isRunning) return;
    
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    print('⏹️ Polling fermato');
  }

  Future<void> _fetchData() async {
    try {
      print('\n📡 [${DateTime.now().toIso8601String()}] Fetching device status...');
      final status = await ApiService.getDeviceAppStatus();
      
      if (status != null) {
        final dataPoint = StatusDataPoint.fromDeviceStatus(status);
        _dataHistory.add(dataPoint);
        
        // Mantieni solo gli ultimi 50 punti
        if (_dataHistory.length > 50) {
          _dataHistory.removeAt(0);
        }
        
        // Plot su terminale
        
        onDataReceived?.call(dataPoint);
      } else {
        print('❌ Nessun dato ricevuto dal server');
        onError?.call('Errore nel recupero dati dal server');
      }
    } catch (e) {
      print('❌ Polling error: $e');
      onError?.call('Errore di connessione: $e');
    }
  }

  void _printBatteryBar(double battery) {
    const int barLength = 20;
    final int filledBars = (battery / 100 * barLength).round();
    
    String bar = '[';
    for (int i = 0; i < barLength; i++) {
      if (i < filledBars) {
        bar += '█';
      } else {
        bar += '░';
      }
    }
    bar += '] ${battery.toStringAsFixed(1)}%';
    
    // Colore in base al livello
    String status = '';
    if (battery > 80) status = '🟢 Excellent';
    else if (battery > 60) status = '🟡 Good';
    else if (battery > 40) status = '🟠 Medium';
    else if (battery > 20) status = '🔴 Low';
    else status = '🚨 Critical';
    
    print('$bar $status');
  }


  void dispose() {
    stopPolling();
  }
}