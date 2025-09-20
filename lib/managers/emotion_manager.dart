import 'package:flutter/material.dart';
import '../models/emotion_state.dart';
import '../services/emotion_service.dart';
import '../services/api_service.dart';
import '../constants/ble_constants.dart';

class EmotionManager extends ChangeNotifier {
  List<EmotionState> _emotions = [];
  List<int> _selectedEmotionIndex = [0, 1];

  List<EmotionState> get emotions {
    if(_emotions.isEmpty)
      return [EmotionState(label: "GAY", color: Color(7)), EmotionState(label: "GAY", color: Color(7))];
    else
      return _emotions;
  }
  List<int> get selectedEmotionIndex => _selectedEmotionIndex;

  EmotionManager() {
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
    _emotions = await EmotionService.loadEmotions();
    notifyListeners();
  }

  Future<void> _saveEmotions() async {
    await EmotionService.saveEmotions(_emotions);
  }

  void setSelectedEmotion(int boxIndex, int emotionIndex) {
    if (boxIndex >= 0 && boxIndex < _selectedEmotionIndex.length &&
        emotionIndex >= 0 && emotionIndex < _emotions.length) {
      _selectedEmotionIndex[boxIndex] = emotionIndex;
      
      // Invia emozione al server
      _sendEmotionToServer(boxIndex, emotionIndex);
      
      notifyListeners();
    }
  }

  Future<void> _sendEmotionToServer(int boxIndex, int emotionIndex) async {
    final emotion = _emotions[emotionIndex];
    final colorHex = '#${emotion.color.value.toRadixString(16).substring(2)}';
    
    print('📤 Invio emozione al server: ${emotion.label}, colore: $colorHex, box: $boxIndex');
    
    final success = await ApiService.updateDeviceEmotion(
      emotion.label, 
      colorHex
    );
    
    if (success) {
      print('✅ Emozione inviata con successo');
    } else {
      print('❌ Errore nell\'invio dell\'emozione');
    }
  }

  Future<void> addEmotion(String name, Color color) async {
    if (name.trim().isNotEmpty) {
      _emotions.add(EmotionState(
        label: name.trim(),
        color: color,
      ));
      await _saveEmotions();
      notifyListeners();
    }
  }

  Future<void> deleteEmotion(int index) async {
    if (index >= 0 && index < _emotions.length) {
      _emotions.removeAt(index);
      
      // Aggiusta indici selezionati
      for (int j = 0; j < _selectedEmotionIndex.length; j++) {
        if (_selectedEmotionIndex[j] == index) {
          _selectedEmotionIndex[j] = 0;
        } else if (_selectedEmotionIndex[j] > index) {
          _selectedEmotionIndex[j]--;
        }
      }
      
      await _saveEmotions();
      notifyListeners();
    }
  }

  Future<int?> showEmotionSelectionDialog(BuildContext context) async {
    int? choice;
    do {
      choice = await _showEmotionDialog(context);
      if (choice == BLEConstants.ADD_NEW) {
        await _showAddEmotionDialog(context);
      } else if (choice == BLEConstants.DELETE) {
        await _showDeleteEmotionDialog(context);
      }
    } while (choice == BLEConstants.ADD_NEW || choice == BLEConstants.DELETE);

    return choice;
  }

  Future<int?> _showEmotionDialog(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text("Seleziona emozione",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _emotions.length,
                    itemBuilder: (_, i) {
                      final emo = _emotions[i];
                      return ListTile(
                        leading: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                              color: emo.color, shape: BoxShape.circle),
                        ),
                        title: Text(emo.label),
                        onTap: () => Navigator.pop(ctx, i),
                      );
                    },
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Nuova"),
                        onPressed: () => Navigator.pop(ctx, BLEConstants.ADD_NEW),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.delete),
                        label: Text("Elimina"),
                        onPressed: () => Navigator.pop(ctx, BLEConstants.DELETE),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddEmotionDialog(BuildContext context) async {
    String name = "";
    int selectedColorIdx = 0;
    final availableColors = EmotionService.getAvailableColors();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text("Nuova emozione"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Nome emozione"),
                    onChanged: (v) => name = v,
                  ),
                  SizedBox(height: 12),
                  Text("Scegli colore:"),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(availableColors.length, (i) {
                      final c = availableColors[i];
                      final isSel = i == selectedColorIdx;
                      return GestureDetector(
                        onTap: () => setStateDialog(() => selectedColorIdx = i),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSel
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Annulla")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Conferma")),
            ],
          );
        });
      },
    );

    if (confirmed == true) {
      await addEmotion(name, availableColors[selectedColorIdx]);
    }
  }

  Future<void> _showDeleteEmotionDialog(BuildContext context) async {
    if (_emotions.isEmpty) return;

    final toDelete = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text("Elimina emozione",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _emotions.length,
                    itemBuilder: (_, i) {
                      final emo = _emotions[i];
                      return ListTile(
                        leading: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                              color: emo.color, shape: BoxShape.circle),
                        ),
                        title: Text(emo.label),
                        onTap: () => Navigator.pop(ctx, i),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (toDelete != null) {
      await deleteEmotion(toDelete);
    }
  }
}