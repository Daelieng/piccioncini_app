import 'package:flutter/material.dart';
import '../models/emotion_state.dart';

class EmotionBoxWidget extends StatelessWidget {
  final Color boxColor;
  final EmotionState emotion;
  final bool isBluetoothConnected;
  final bool isLoading;
  final VoidCallback onEmotionTap;
  final VoidCallback? onBluetoothTap;
  final VoidCallback? onWifiTap;
  final bool showControlButtons;

  const EmotionBoxWidget({
    Key? key,
    required this.boxColor,
    required this.emotion,
    required this.isBluetoothConnected,
    required this.isLoading,
    required this.onEmotionTap,
    this.onBluetoothTap,
    this.onWifiTap,
    this.showControlButtons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, 
            blurRadius: 6, 
            spreadRadius: 2
          )
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Nome", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          GestureDetector(
            onTap: onEmotionTap,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: emotion.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                emotion.label,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // Pulsanti mostrati solo se showControlButtons è true
          if (showControlButtons) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onBluetoothTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBluetoothConnected ? Colors.blue : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: Colors.white
                          ),
                        )
                      : Icon(
                          Icons.bluetooth,
                          color: isBluetoothConnected ? Colors.white : Colors.black
                        ),
                ),
                ElevatedButton(
                  onPressed: isBluetoothConnected ? onWifiTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBluetoothConnected ? Colors.blue : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                    elevation: 2,
                  ),
                  child: Icon(Icons.wifi, color: Colors.white),
                ),
              ],
            ),
          ] else ...[
            // Spazio vuoto quando i pulsanti sono nascosti per mantenere proporzioni
            SizedBox(height: 48),
          ],
        ],
      ),
    );
  }
}