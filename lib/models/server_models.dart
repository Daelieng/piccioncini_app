import 'package:flutter/material.dart';

class DeviceAppStatus {
  final double battery1;
  final bool online1;
  final bool nostalgia1;
  final String emotion1;
  final String color1;
  final double battery2;
  final bool online2;
  final bool nostalgia2;
  final String emotion2;
  final String color2;
  final DateTime timestamp;

  DeviceAppStatus({
    required this.battery1,
    required this.online1,
    required this.nostalgia1,
    required this.emotion1,
    required this.color1,
    required this.battery2,
    required this.online2,
    required this.nostalgia2,
    required this.emotion2,
    required this.color2,
    required this.timestamp,
  });

  factory DeviceAppStatus.fromJson(List<dynamic> json) {
    return DeviceAppStatus(
      battery1: (json[0]['battery'] ?? 0).toDouble(),
      online1: json[0]['online'] ?? false,
      nostalgia1: json[0]['nostalgia'] ?? false,
      emotion1: json[0]['emotion'] ?? '',
      color1: json[0]['color'] ?? '#000000',
      battery2: (json[1]['battery'] ?? 0).toDouble(),
      online2: json[1]['online'] ?? false,
      nostalgia2: json[1]['nostalgia'] ?? false,
      emotion2: json[1]['emotion'] ?? '',
      color2: json[1]['color'] ?? '#000000',
      timestamp: DateTime.now(), // Timestamp locale
    );
  }

  Color get colorValue1 {
    try {
      String cleanColor = color1.replaceAll('#', '');
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor'; // Aggiungi alpha
      }
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
  Color get colorValue2 {
    try {
      String cleanColor = color2.replaceAll('#', '');
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor'; // Aggiungi alpha
      }
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'DeviceAppStatus(battery: $battery1%, online: $online1, nostalgia: $nostalgia1, emotion: $emotion1, color: $color1, \n battery: $battery2%, online: $online2, nostalgia: $nostalgia2, emotion: $emotion2, color: $color2))';
  }
}

class EmotionUpdateRequest {
  final String emotion;
  final String color;

  EmotionUpdateRequest({
    required this.emotion,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'color': color,
    };
  }
}

class StatusDataPoint {
final double battery1;
  final bool online1;
  final bool nostalgia1;
  final String emotion1;
  final Color color1;
  final double battery2;
  final bool online2;
  final bool nostalgia2;
  final String emotion2;
  final Color color2;
  final DateTime timestamp;

  StatusDataPoint({
    required this.timestamp,
    required this.battery1,
    required this.online1,
    required this.nostalgia1,
    required this.emotion1,
    required this.color1,
    required this.battery2,
    required this.online2,
    required this.nostalgia2,
    required this.emotion2,
    required this.color2,
  });

  factory StatusDataPoint.fromDeviceStatus(DeviceAppStatus status) {
    return StatusDataPoint(
      timestamp: status.timestamp,
      battery1: status.battery1,
      online1: status.online1,
      nostalgia1: status.nostalgia1,
      emotion1: status.emotion1,
      color1: status.colorValue1,
      battery2: status.battery2,
      online2: status.online2,
      nostalgia2: status.nostalgia2,
      emotion2: status.emotion2,
      color2: status.colorValue2,
    );
  }
}