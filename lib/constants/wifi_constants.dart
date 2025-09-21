class WiFiConstants {
  // Configurazione Server
  static const String BASE_URL = "http://192.168.1.232:5000";
  static const String DEVICE_ID = "1"; // Modifica questo ID se necessario
  
  // Endpoints API
  static String get getDeviceAppEndpoint => "/devices";
  static String get putDeviceAppEndpoint => "/devices/$DEVICE_ID/app";
  
  // Headers comuni
  static const Map<String, String> DEFAULT_HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout
  static const Duration REQUEST_TIMEOUT = Duration(seconds: 10);
  static const Duration POLLING_INTERVAL = Duration(seconds: 10);
}