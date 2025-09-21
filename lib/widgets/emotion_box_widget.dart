import 'package:flutter/material.dart';
import '../models/emotion_state.dart';

class EmotionBoxWidget extends StatelessWidget {
  final Color boxColor;
  final EmotionState emotion;
  final double batteryLevel; // NUOVO
  final bool isOnline; // NUOVO
  final bool hasServerData; // NUOVO
  final String? userName; // NUOVO: aggiunto per compatibilità
  final bool isBluetoothConnected;
  final bool isLoading;
  final VoidCallback? onEmotionTap; // MODIFICATO: ora può essere null
  final VoidCallback? onBluetoothTap;
  final VoidCallback? onWifiTap;
  final bool showControlButtons;

  const EmotionBoxWidget({
    Key? key,
    required this.boxColor,
    required this.emotion,
    this.batteryLevel = 50.0, // NUOVO: default 50%
    this.isOnline = false, // NUOVO: default offline
    this.hasServerData = false, // NUOVO: default nessun dato server
    this.userName, // NUOVO: parametro opzionale per il nome utente
    required this.isBluetoothConnected,
    required this.isLoading,
    this.onEmotionTap, // MODIFICATO: ora opzionale
    this.onBluetoothTap,
    this.onWifiTap,
    this.showControlButtons = true,
  }) : super(key: key);

  // NUOVO: Metodo per ottenere il colore della batteria in base al livello
  Color _getBatteryColor() {
    if (batteryLevel > 80) return Colors.green;
    if (batteryLevel > 60) return Colors.lightGreen;
    if (batteryLevel > 40) return Colors.orange;
    if (batteryLevel > 20) return Colors.deepOrange;
    return Colors.red;
  }

  // NUOVO: Metodo per ottenere l'icona dello stato di connessione
  Widget _getConnectionIcon() {
    if (!hasServerData) {
      return Icon(Icons.cloud_off, color: Colors.grey, size: 16);
    }
    return Icon(
      isOnline ? Icons.wifi : Icons.wifi_off,
      color: isOnline ? Colors.green : Colors.red,
      size: 16,
    );
  }

  // NUOVO: Metodo per formattare il nome utente con stato
  String _getUserDisplayName() {
    final name = userName ?? "Nome"; // Usa userName se fornito, altrimenti "Nome"
    if (!hasServerData) {
      return name; // Default quando non abbiamo dati
    }
    return isOnline ? name : "$name";  //return isOnline ? name : "$name (offline)";
  }

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
          // MODIFICATO: Nome utente con indicatore di connessione
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getUserDisplayName(), 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: hasServerData && !isOnline ? Colors.grey[600] : Colors.black,
                )
              ),
              SizedBox(width: 8),
              _getConnectionIcon(),
            ],
          ),
          
          // MODIFICATO: Barra della batteria con colore dinamico
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Batteria", 
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])
                  ),
                  Text(
                    "${batteryLevel.toStringAsFixed(0)}%", 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: _getBatteryColor()
                    )
                  ),
                ],
              ),
              SizedBox(height: 4),
              Container(
                height: 6,
                child: LinearProgressIndicator(
                  value: batteryLevel / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getBatteryColor()),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          
          // MODIFICATO: Container dell'emozione con gestione del tap
          GestureDetector(
            onTap: onEmotionTap, // Può essere null per l'utente non selezionato
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: emotion.color,
                borderRadius: BorderRadius.circular(16),
                // NUOVO: Bordo per indicare se è interattivo
                border: onEmotionTap != null 
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emotion.label,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  // NUOVO: Icona per indicare se l'emozione è modificabile
                  if (onEmotionTap != null) ...[
                    SizedBox(width: 8),
                    Icon(Icons.edit, color: Colors.white.withOpacity(0.7), size: 16),
                  ],
                ],
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