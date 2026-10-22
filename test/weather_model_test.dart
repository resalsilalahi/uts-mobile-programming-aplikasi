import 'package:cuaca_bmkg/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = {
    'lokasi': {
      'adm4': '31.71.03.1001',
      'provinsi': 'DKI Jakarta',
      'kotkab': 'Kota Adm. Jakarta Pusat',
      'kecamatan': 'Kemayoran',
      'desa': 'Kemayoran',
      'lon': 106.8,
      'lat': -6.1,
      'timezone': 'Asia/Jakarta',
    },
    'data': [
      {
        'cuaca': [
          [
            {
              'utc_datetime': '2026-10-21 00:00:00',
              'local_datetime': '2026-10-21 07:00:00',
              't': 28,
              'hu': 80,
              'weather_desc': 'Cerah Berawan',
              'weather_desc_en': 'Mostly Sunny',
              'ws': 5.2,
              'wd': 'SW',
              'tcc': 40,
              'vs_text': '> 10 km',
              'analysis_date': '2026-10-20T18:00:00',
            },
            {
              'utc_datetime': '2026-10-21 03:00:00',
              'local_datetime': '2026-10-21 10:00:00',
              't': 31,
              'hu': 70,
              'weather_desc': 'Hujan Ringan',
              'weather_desc_en': 'Light Rain',
              'ws': 7,
              'wd': 'W',
              'tcc': 80,
              'vs_text': '< 8 km',
              'analysis_date': '2026-10-20T18:00:00',
            },
          ]
        ],
      }
    ],
  };

  test('JSON BMKG dikonversi menjadi objek Dart', () {
    final data = WeatherData.fromJson(sample);
    expect(data.lokasi.desa, 'Kemayoran');
    expect(data.forecasts.length, 2);
    expect(data.forecasts.first.suhu, 28.0);
    expect(data.days.length, 1);
    expect(data.days.first.adaHujan, isTrue);
  });

  test('slot saat ini dipilih berdasarkan waktu UTC', () {
    final data = WeatherData.fromJson(sample);
    expect(data.currentIndex(DateTime.utc(2026, 10, 21, 1)), 0);
    expect(data.currentIndex(DateTime.utc(2026, 10, 21, 4)), 1);
  });
}
