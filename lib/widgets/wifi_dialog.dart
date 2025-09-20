import 'package:flutter/material.dart';

class WiFiDialog {
  static void showWifiList(
    BuildContext context, 
    String rawData, 
    Function(String) onWifiSelected
  ) {
    final nets = rawData
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("WiFi Disponibili"),
        content: nets.isEmpty
            ? Text("Nessuna rete trovata")
            : Container(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: nets.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(nets[i]),
                    onTap: () {
                      Navigator.pop(context);
                      onWifiSelected(nets[i]);
                    },
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Chiudi")
          )
        ],
      ),
    );
  }

  static Future<String?> showPasswordDialog(
    BuildContext context, 
    String ssid
  ) async {
    return showDialog<String>(
      context: context,
      builder: (_) {
        String input = "";
        return AlertDialog(
          title: Text("Inserisci password per $ssid"),
          content: TextField(
            onChanged: (v) => input = v,
            decoration: InputDecoration(hintText: "Password"),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Annulla")
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input), 
              child: Text("OK")
            ),
          ],
        );
      },
    );
  }

  static void showDeviceNotFound(BuildContext context, String deviceName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Dispositivo non trovato"),
        content: Text("Il dispositivo '$deviceName' non è stato trovato."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Chiudi")
          ),
        ],
      ),
    );
  }
}