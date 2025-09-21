import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  int _selectedUserIndex = 0; // 0 = utente 1 (riga in alto), 1 = utente 2 (riga in basso)
  
  static const String _selectedUserKey = 'selected_user_index';

  int get selectedUserIndex => _selectedUserIndex;

  // AGGIUNTO: Metodi per i nomi utenti
  String getUserName(int userIndex) {
    switch (userIndex) {
      case 0:
        return "Femmina";
      case 1:
        return "Maschio";
      default:
        return "Utente ${userIndex + 1}";
    }
  }

  // AGGIUNTO: Per compatibilità con il nuovo codice
  int get totalUsers => 2;

  /// Inizializza il manager caricando le preferenze salvate
  Future<void> initialize() async {
    await _loadSelectedUser();
  }

  /// Carica l'utente selezionato dalle SharedPreferences
  Future<void> _loadSelectedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedUserIndex = prefs.getInt(_selectedUserKey) ?? 0;
      notifyListeners();
    } catch (e) {
      print('Errore nel caricamento delle preferenze utente: $e');
      _selectedUserIndex = 0; // Default fallback
    }
  }

  /// Salva l'utente selezionato nelle SharedPreferences
  Future<void> _saveSelectedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_selectedUserKey, _selectedUserIndex);
    } catch (e) {
      print('Errore nel salvataggio delle preferenze utente: $e');
    }
  }

  /// Seleziona un utente specifico
  Future<void> selectUser(int userIndex) async {
    if (userIndex >= 0 && userIndex <= 1 && userIndex != _selectedUserIndex) {
      _selectedUserIndex = userIndex;
      await _saveSelectedUser();
      notifyListeners();
    }
  }

  /// Verifica se un utente specifico è selezionato
  bool isUserSelected(int userIndex) {
    return _selectedUserIndex == userIndex;
  }

  /// Ottieni il flex per la riga principale (selezionata)
  int getMainRowFlex() => 7; // 70%

  /// Ottieni il flex per la riga secondaria (non selezionata)
  int getSecondaryRowFlex() => 3; // 30%

  /// Verifica se i controlli (bluetooth/wifi) devono essere mostrati per un utente
  bool shouldShowControls(int userIndex) {
    return isUserSelected(userIndex);
  }

}