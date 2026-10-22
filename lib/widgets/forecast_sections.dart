import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/helpers.dart';

class AdviceCard extends StatelessWidget {
  final List<Forecast> next;
  const AdviceCard({super.key, required this.next});

  @override
  Widget build(BuildContext context) {
    final s = saranCuaca(next);
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(s.icon),
          const SizedBox(width: 12),
          Expanded(child: Text(s.text)),
        ]),
      ),
    );
  }
}

class HourlyList extends StatelessWidget {
  final List<Forecast> items;
  const HourlyList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = items[i];
          return Container(
            width: 78,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(i == 0 ? 'Sekarang' : jam(f.local),
                    style: const TextStyle(fontSize: 12)),
                Icon(ikonCuaca(f.cuaca, malam: f.isNight), size: 28),
                Text('${f.suhu.round()}°',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${f.kelembapan}%',
                    style: TextStyle(
                        fontSize: 11, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DailyList extends StatelessWidget {
  final List<DayForecast> days;
  const DailyList({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < days.length; i++)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListTile(
              onTap: () => _showDetail(context, days[i], i),
              leading: Icon(ikonCuaca(days[i].cuacaDominan, malam: false), size: 30),
              title: Text(labelHari(days[i].date, i)),
              subtitle: Text(days[i].cuacaDominan +
                  (days[i].adaHujan && !days[i].cuacaDominan.toLowerCase().contains('hujan')
                      ? ' • potensi hujan'
                      : '')),
              trailing: Text(
                '${days[i].suhuMin.round()}° / ${days[i].suhuMax.round()}°',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, DayForecast day, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text('${labelHari(day.date, index)} • ${tanggal(day.date)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final f in day.slots)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                  width: 90,
                  child: Row(children: [
                    Icon(ikonCuaca(f.cuaca, malam: f.isNight)),
                    const SizedBox(width: 8),
                    Text(jam(f.local),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
                title: Text('${f.cuaca} • ${f.suhu.round()}°C'),
                subtitle: Text(
                    'Lembap ${f.kelembapan}% • Angin ${f.angin.toStringAsFixed(1)} km/j (${f.arahAngin}) • Awan ${f.awan}%'),
              ),
          ],
        ),
      ),
    );
  }
}
