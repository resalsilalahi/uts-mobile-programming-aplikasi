import 'package:flutter/material.dart';

import '../models/weather_model.dart';

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String _two(int n) => n.toString().padLeft(2, '0');

String jam(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String tanggal(DateTime d) => '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]}';

String labelHari(DateTime d, int index) {
  if (index == 0) return 'Hari ini';
  if (index == 1) return 'Besok';
  return _hari[d.weekday - 1];
}

IconData ikonCuaca(String desc, {required bool malam}) {
  final d = desc.toLowerCase();
  if (d.contains('petir')) return Icons.thunderstorm;
  if (d.contains('hujan')) return Icons.umbrella;
  if (d.contains('kabut') || d.contains('kabur') || d.contains('asap')) return Icons.foggy;
  if (d.contains('berawan tebal')) return Icons.cloud;
  if (d.contains('berawan')) return malam ? Icons.nights_stay : Icons.wb_cloudy;
  if (d.contains('cerah')) return malam ? Icons.nightlight_round : Icons.wb_sunny;
  return Icons.cloud;
}

List<Color> gradienCuaca(String desc, bool malam) {
  final d = desc.toLowerCase();
  if (d.contains('hujan') || d.contains('petir')) {
    return [const Color(0xFF37474F), const Color(0xFF607D8B)];
  }
  if (malam) return [const Color(0xFF0D1B3E), const Color(0xFF3F51B5)];
  if (d.contains('cerah') && !d.contains('berawan')) {
    return [const Color(0xFF1E88E5), const Color(0xFFFFB74D)];
  }
  return [const Color(0xFF1976D2), const Color(0xFF90A4AE)];
}

/// Saran sederhana berdasarkan prakiraan 24 jam ke depan.
({IconData icon, String text}) saranCuaca(List<Forecast> next) {
  if (next.any((f) => f.cuaca.toLowerCase().contains('petir'))) {
    return (icon: Icons.warning_amber, text: 'Ada potensi petir. Hindari aktivitas di ruang terbuka.');
  }
  if (next.any((f) => f.isRain)) {
    return (icon: Icons.umbrella, text: 'Ada potensi hujan dalam 24 jam ke depan. Bawa payung atau jas hujan.');
  }
  if (next.any((f) {
    final d = f.cuaca.toLowerCase();
    return d.contains('kabut') || d.contains('kabur') || d.contains('asap');
  })) {
    return (icon: Icons.foggy, text: 'Jarak pandang bisa berkurang. Berkendaralah dengan hati-hati.');
  }
  final maks = next.map((f) => f.suhu).reduce((a, b) => a > b ? a : b);
  if (maks >= 33) {
    return (icon: Icons.local_drink, text: 'Cuaca cukup panas (hingga ${maks.round()}°C). Perbanyak minum air putih.');
  }
  return (icon: Icons.check_circle_outline, text: 'Cuaca relatif aman untuk beraktivitas.');
}
