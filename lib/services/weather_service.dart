import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  @override
  String toString() => message;
}

class WeatherService {
  static const _host = 'api.bmkg.go.id';
  static const _path = '/publik/prakiraan-cuaca';

  final http.Client _client;
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil prakiraan cuaca 3 hari untuk kode wilayah tingkat IV (adm4).
  Future<WeatherData> fetchForecast(String adm4) async {
    final uri = Uri.https(_host, _path, {'adm4': adm4});

    final http.Response res;
    try {
      res = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw WeatherException('Server BMKG tidak merespons. Coba lagi nanti.');
    } on SocketException {
      throw WeatherException('Tidak ada koneksi internet.');
    } on http.ClientException {
      throw WeatherException('Gagal terhubung ke server BMKG.');
    }

    switch (res.statusCode) {
      case 200:
        break;
      case 404:
        throw WeatherException('Kode wilayah "$adm4" tidak ditemukan.');
      case 429:
        throw WeatherException('Terlalu banyak permintaan (maks. 60/menit). Tunggu sebentar.');
      default:
        throw WeatherException('Server BMKG mengembalikan status ${res.statusCode}.');
    }

    try {
      final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final data = WeatherData.fromJson(json);
      if (data.forecasts.isEmpty) {
        throw WeatherException('Data prakiraan kosong untuk wilayah ini.');
      }
      return data;
    } on WeatherException {
      rethrow;
    } on FormatException {
      throw WeatherException('Respons server bukan JSON yang valid.');
    } on TypeError {
      throw WeatherException('Struktur data dari BMKG tidak sesuai harapan.');
    } on StateError {
      throw WeatherException('Data prakiraan tidak tersedia untuk wilayah ini.');
    }
  }
}
