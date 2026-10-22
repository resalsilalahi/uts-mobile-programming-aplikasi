import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedLocation {
  final String code;
  final String name;
  SavedLocation(this.code, this.name);

  Map<String, String> toJson() => {'code': code, 'name': name};
  factory SavedLocation.fromJson(Map<String, dynamic> j) =>
      SavedLocation(j['code'] as String, j['name'] as String);
}

/// Menyimpan daftar lokasi favorit dan lokasi terakhir yang dipilih.
class LocationStorage {
  static const defaultCode = '31.71.03.1001'; // contoh dari dokumentasi BMKG
  static const _kSaved = 'saved_locations';
  static const _kSelected = 'selected_code';

  Future<List<SavedLocation>> getSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSaved) ?? [];
    return raw
        .map((s) => SavedLocation.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(SavedLocation loc) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSaved();
    list.removeWhere((l) => l.code == loc.code);
    list.insert(0, loc);
    await prefs.setStringList(_kSaved, list.map((l) => jsonEncode(l.toJson())).toList());
  }

  Future<void> remove(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSaved();
    list.removeWhere((l) => l.code == code);
    await prefs.setStringList(_kSaved, list.map((l) => jsonEncode(l.toJson())).toList());
  }

  Future<String> getSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSelected) ?? defaultCode;
  }

  Future<void> setSelected(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelected, code);
  }
}
