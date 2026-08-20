import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/leader_scale.dart';

/// Lädt die Itembank aus dem gebündelten Asset.
///
/// Die Fragen liegen bewusst als JSON und nicht im Dart-Code: So lassen sie
/// sich überarbeiten, ohne dass jemand Dart anfassen muss, und eine zweite
/// Sprache wäre nur eine weitere Datei.
class ItemBankLoader {
  const ItemBankLoader._();

  static const String assetPath = 'assets/items/leader_items_de.json';

  static Future<ItemBank> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ItemBank.fromJson(json);
  }
}
