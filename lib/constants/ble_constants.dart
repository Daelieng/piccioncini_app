import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEConstants {
  static Guid SERVICE_UUID      = Guid("00ff");
  static Guid WIFI_SCAN_UUID    = Guid("ff20");
  static Guid WIFI_COMMAND_UUID = Guid("ff11");
  static Guid WIFI_CFG_UUID     = Guid("ff21");
  
  static const int ADD_NEW = -1;
  static const int DELETE = -2;
}