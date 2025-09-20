import 'package:flutter/material.dart';
import '../models/emotion_state.dart';
import '../services/emotion_service.dart';

class EmotionPickerDialog {
  static const int _ADD_NEW = -1;
  static const int _DELETE = -2;

  static Future<int?> show({
    required BuildContext context,
    required List<EmotionState> emotions,
    required VoidCallback onAddEmotion,
    required VoidCallback onDeleteEmotion,
  }) async {
    int? choice;
    do {
      choice = await _showEmotionDialog(context, emotions);
      
      if (choice == _ADD_NEW) {
        final newEmotion = await _showAddEmotionDialog(context);
        if (newEmotion != null) {
          emotions.add(newEmotion);
        }
      } else if (choice == _DELETE) {
        final deletedIndex = await _showDeleteEmotionDialog(context, emotions);
        if (deletedIndex != null) {
          emotions.removeAt(deletedIndex);
        }
      }
    } while (choice == _ADD_NEW || choice == _DELETE);

    return choice;
  }

  static Future<int?> _showEmotionDialog(BuildContext context, List<EmotionState> emotions) {
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
                  child: Text(
                    "Seleziona emozione",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: emotions.length,
                    itemBuilder: (_, i) {
                      final emotion = emotions[i];
                      return ListTile(
                        leading: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: emotion.color,
                            shape: BoxShape.circle
                          ),
                        ),
                        title: Text(emotion.label),
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
                        onPressed: () => Navigator.pop(ctx, _ADD_NEW),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.delete),
                        label: Text("Elimina"),
                        onPressed: () => Navigator.pop(ctx, _DELETE),
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

  static Future<EmotionState?> _showAddEmotionDialog(BuildContext context) async {
    String name = "";
    int selectedColorIdx = 0;
    final availableColors = EmotionService.getAvailableColors();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text("Nuova emozione"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: "Nome emozione"),
                      onChanged: (value) => name = value,
                    ),
                    SizedBox(height: 12),
                    Text("Scegli colore:"),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableColors.length, (i) {
                        final color = availableColors[i];
                        final isSelected = i == selectedColorIdx;
                        return GestureDetector(
                          onTap: () => setStateDialog(() => selectedColorIdx = i),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
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
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text("Annulla")
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text("Conferma")
                ),
              ],
            );
          }
        );
      },
    );

    if (confirmed == true && name.trim().isNotEmpty) {
      return EmotionState(
        label: name.trim(),
        color: availableColors[selectedColorIdx],
      );
    }
    
    return null;
  }

  static Future<int?> _showDeleteEmotionDialog(BuildContext context, List<EmotionState> emotions) async {
    if (emotions.isEmpty) return null;

    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Elimina emozione",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: emotions.length,
                    itemBuilder: (_, i) {
                      final emotion = emotions[i];
                      return ListTile(
                        leading: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: emotion.color,
                            shape: BoxShape.circle
                          ),
                        ),
                        title: Text(emotion.label),
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
  }
}
