import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_state.dart';

class EmotionService {
  static const String _prefsKey = 'my_emotions';
  
  static List<EmotionState> getDefaultEmotions() {
    return [
      EmotionState(label: "Felice", color: Colors.yellow[700]!),
      EmotionState(label: "Triste", color: Colors.blue[700]!),
      EmotionState(label: "Arrabbiato", color: Colors.red[700]!),
      EmotionState(label: "Rilassato", color: Colors.green[700]!),
    ];
  }

  static Future<List<EmotionState>> loadEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_prefsKey);
    
    if (rawJson != null) {
      try {
        List<dynamic> decoded = jsonDecode(rawJson);
        return decoded.map((item) => EmotionState.fromJson(item)).toList();
      } catch (_) {
        // Se JSON corrotto, restituisci quelli di default
        return getDefaultEmotions();
      }
    }
    
    return getDefaultEmotions();
  }

  static Future<void> saveEmotions(List<EmotionState> emotions) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> raw = emotions.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(raw));
  }

  static List<Color> getAvailableColors() {
    return [
      Colors.red, Colors.redAccent,
      Colors.pink, Colors.pinkAccent,
      Colors.purple, Colors.purpleAccent,
      Colors.deepPurple, Colors.deepPurpleAccent,
      Colors.indigo, Colors.indigoAccent,
      Colors.blue, Colors.blueAccent,
      Colors.lightBlue, Colors.lightBlueAccent,
      Colors.cyan, Colors.cyanAccent,
      Colors.teal, Colors.tealAccent,
      Colors.green, Colors.greenAccent,
      Colors.lightGreen, Colors.lightGreenAccent,
      Colors.lime, Colors.limeAccent,
      Colors.yellow, Colors.yellowAccent,
      Colors.amber, Colors.amberAccent,
      Colors.orange, Colors.orangeAccent,
      Colors.deepOrange, Colors.deepOrangeAccent,
      Colors.brown,
      Colors.grey, Colors.grey.shade700,
      Colors.blueGrey, Colors.blueGrey.shade700,
      Colors.black, Colors.white,
      Colors.red.shade200, Colors.red.shade400,
      Colors.blue.shade200, Colors.blue.shade400,
      Colors.green.shade200, Colors.green.shade400,
    ];
  }
}