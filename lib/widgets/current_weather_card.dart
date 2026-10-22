import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/helpers.dart';

class CurrentWeatherCard extends StatelessWidget {
  final Lokasi lokasi;
  final Forecast f;
  const CurrentWeatherCard({super.key, required this.lokasi, required this.f});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradienCuaca(f.cuaca, f.isNight),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.place, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(lokasi.namaSingkat,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ]),
          Text('${lokasi.kotkab}, ${lokasi.provinsi}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(children: [
            Icon(ikonCuaca(f.cuaca, malam: f.isNight), size: 72, color: Colors.white),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${f.suhu.round()}°C',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 52, fontWeight: FontWeight.w300)),
              Text(f.cuaca, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ]),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _Info(Icons.water_drop, 'Lembap ${f.kelembapan}%'),
            _Info(Icons.air, '${f.angin.toStringAsFixed(1)} km/j dari ${f.arahAngin}'),
            _Info(Icons.cloud_queue, 'Awan ${f.awan}%'),
            _Info(Icons.visibility, 'Jarak pandang ${f.jarakPandang}'),
          ]),
          const SizedBox(height: 8),
          Text('Prakiraan pukul ${jam(f.local)} • ${tanggal(f.local)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    );
  }
}
