/// Model data untuk respons API prakiraan cuaca BMKG.
///
/// Struktur respons (ringkas):
/// {
///   "lokasi": { "adm4", "provinsi", "kotkab", "kecamatan", "desa", "lat", "lon", "timezone" },
///   "data": [ { "cuaca": [ [ {prakiraan 3 jam}, ... ], [hari 2], [hari 3] ] } ]
/// }

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

int _toInt(dynamic v) => _toDouble(v).round();

class Lokasi {
  final String adm4;
  final String provinsi;
  final String kotkab;
  final String kecamatan;
  final String desa;
  final double lat;
  final double lon;
  final String timezone;

  Lokasi({
    required this.adm4,
    required this.provinsi,
    required this.kotkab,
    required this.kecamatan,
    required this.desa,
    required this.lat,
    required this.lon,
    required this.timezone,
  });

  factory Lokasi.fromJson(Map<String, dynamic> j) => Lokasi(
        adm4: (j['adm4'] ?? '').toString(),
        provinsi: (j['provinsi'] ?? '').toString(),
        kotkab: (j['kotkab'] ?? '').toString(),
        kecamatan: (j['kecamatan'] ?? '').toString(),
        desa: (j['desa'] ?? '').toString(),
        lat: _toDouble(j['lat']),
        lon: _toDouble(j['lon']),
        timezone: (j['timezone'] ?? '').toString(),
      );

  String get namaSingkat => '$desa, $kecamatan';
}

class Forecast {
  final DateTime utc;
  final DateTime local; // waktu lokal lokasi (tanpa zona waktu)
  final double suhu; // t, °C
  final int kelembapan; // hu, %
  final String cuaca; // weather_desc
  final String cuacaEn;
  final double angin; // ws, km/jam
  final String arahAngin; // wd (asal angin)
  final int awan; // tcc, %
  final String jarakPandang; // vs_text
  final DateTime? analysisDate;

  Forecast({
    required this.utc,
    required this.local,
    required this.suhu,
    required this.kelembapan,
    required this.cuaca,
    required this.cuacaEn,
    required this.angin,
    required this.arahAngin,
    required this.awan,
    required this.jarakPandang,
    required this.analysisDate,
  });

  factory Forecast.fromJson(Map<String, dynamic> j) {
    DateTime parseNaive(String s) => DateTime.parse(s.replaceFirst(' ', 'T'));
    return Forecast(
      utc: DateTime.parse('${(j['utc_datetime'] as String).replaceFirst(' ', 'T')}Z'),
      local: parseNaive(j['local_datetime'] as String),
      suhu: _toDouble(j['t']),
      kelembapan: _toInt(j['hu']),
      cuaca: (j['weather_desc'] ?? '-').toString(),
      cuacaEn: (j['weather_desc_en'] ?? '').toString(),
      angin: _toDouble(j['ws']),
      arahAngin: (j['wd'] ?? '-').toString(),
      awan: _toInt(j['tcc']),
      jarakPandang: (j['vs_text'] ?? '-').toString(),
      analysisDate: j['analysis_date'] == null
          ? null
          : DateTime.tryParse('${j['analysis_date']}Z'),
    );
  }

  bool get isNight => local.hour < 6 || local.hour >= 18;

  bool get isRain {
    final d = cuaca.toLowerCase();
    return d.contains('hujan') || d.contains('petir');
  }
}

/// Ringkasan satu hari (gabungan 8 prakiraan per 3 jam).
class DayForecast {
  final DateTime date;
  final List<Forecast> slots;

  DayForecast(this.date, this.slots);

  double get suhuMin => slots.map((s) => s.suhu).reduce((a, b) => a < b ? a : b);
  double get suhuMax => slots.map((s) => s.suhu).reduce((a, b) => a > b ? a : b);
  bool get adaHujan => slots.any((s) => s.isRain);

  /// Kondisi yang paling sering muncul (diutamakan siang hari 06:00-17:59).
  String get cuacaDominan {
    final siang = slots.where((s) => !s.isNight).toList();
    final sumber = siang.isNotEmpty ? siang : slots;
    final hitung = <String, int>{};
    for (final s in sumber) {
      hitung[s.cuaca] = (hitung[s.cuaca] ?? 0) + 1;
    }
    return hitung.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

class WeatherData {
  final Lokasi lokasi;
  final List<Forecast> forecasts; // terurut menurut waktu

  WeatherData({required this.lokasi, required this.forecasts});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    final first = dataList.first as Map<String, dynamic>;
    final lokasiJson = (json['lokasi'] ?? first['lokasi']) as Map<String, dynamic>;

    final all = <Forecast>[];
    for (final hari in first['cuaca'] as List<dynamic>) {
      for (final item in hari as List<dynamic>) {
        all.add(Forecast.fromJson(item as Map<String, dynamic>));
      }
    }
    all.sort((a, b) => a.utc.compareTo(b.utc));
    return WeatherData(lokasi: Lokasi.fromJson(lokasiJson), forecasts: all);
  }

  /// Indeks prakiraan yang sedang berlaku (slot terakhir yang waktunya <= sekarang).
  int currentIndex([DateTime? nowUtc]) {
    final now = nowUtc ?? DateTime.now().toUtc();
    var idx = 0;
    for (var i = 0; i < forecasts.length; i++) {
      if (!forecasts[i].utc.isAfter(now)) idx = i;
    }
    return idx;
  }

  Forecast get current => forecasts[currentIndex()];

  /// 8 slot (24 jam) mulai dari kondisi saat ini.
  List<Forecast> get next24h {
    final i = currentIndex();
    final end = (i + 8 > forecasts.length) ? forecasts.length : i + 8;
    return forecasts.sublist(i, end);
  }

  List<DayForecast> get days {
    final map = <String, List<Forecast>>{};
    for (final f in forecasts) {
      final key = '${f.local.year}-${f.local.month}-${f.local.day}';
      map.putIfAbsent(key, () => []).add(f);
    }
    return map.values
        .map((slots) => DayForecast(
            DateTime(slots.first.local.year, slots.first.local.month, slots.first.local.day),
            slots))
        .toList();
  }

  DateTime? get diperbarui => forecasts.isEmpty ? null : forecasts.first.analysisDate;
}
