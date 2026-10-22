import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/location_storage.dart';
import '../services/weather_service.dart';
import '../utils/helpers.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_sections.dart';
import '../widgets/state_views.dart';
import 'location_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WeatherService();
  final _storage = LocationStorage();

  String _code = LocationStorage.defaultCode;
  late Future<WeatherData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Membaca lokasi terpilih (jika tidak diberikan), lalu mengambil data dari API.
  Future<WeatherData> _load({String? code}) async {
    _code = code ?? await _storage.getSelected();
    return _service.fetchForecast(_code);
  }

  void _reload() {
    setState(() {
      _future = _load(code: _code);
    });
  }

  Future<void> _pullRefresh() async {
    _reload();
    try {
      await _future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _pickLocation() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => LocationScreen(currentCode: _code)),
    );
    if (code != null) {
      await _storage.setSelected(code);
      if (!mounted) return;
      setState(() {
        _future = _load(code: code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca BMKG'),
        actions: [
          IconButton(
              tooltip: 'Muat ulang', onPressed: _reload, icon: const Icon(Icons.refresh)),
          IconButton(
              tooltip: 'Ganti lokasi',
              onPressed: _pickLocation,
              icon: const Icon(Icons.edit_location_alt)),
        ],
      ),
      body: FutureBuilder<WeatherData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(); // Loading
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            ); // Error
          }
          return _buildContent(snapshot.data!); // Success
        },
      ),
    );
  }

  Widget _buildContent(WeatherData data) {
    final now = data.current;
    final next = data.next24h;
    final updated = data.diperbarui?.toLocal();

    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          CurrentWeatherCard(lokasi: data.lokasi, f: now),
          const SizedBox(height: 12),
          AdviceCard(next: next),
          const SizedBox(height: 20),
          Text('24 Jam ke Depan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          HourlyList(items: next),
          const SizedBox(height: 20),
          Text('Prakiraan 3 Hari', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DailyList(days: data.days),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika)'
                  '${updated != null ? '\nData dianalisis ${tanggal(updated)} ${jam(updated)}' : ''}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}