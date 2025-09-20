import 'package:flutter/material.dart';

class EmotionState {
  final String label;
  final Color color;
  
  EmotionState({required this.label, required this.color});

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'color': color.value,
    };
  }

  factory EmotionState.fromJson(Map<String, dynamic> json) {
    return EmotionState(
      label: json['label'],
      color: Color(json['color']),
    );
  }
}