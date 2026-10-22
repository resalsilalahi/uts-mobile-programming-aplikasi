import 'package:flutter/material.dart';

import '../services/location_storage.dart';
import '../services/weather_service.dart';

class LocationScreen extends StatefulWidget {
  final String currentCode;
  const LocationScreen({super.key, required this.currentCode});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _storage = LocationStorage();
  final _service = WeatherService();
  final _controller = TextEditingController();
  final _kodeRegex = RegExp(r'^\d{2}\.\d{2}\.\d{2}\.\d{4}$');

  List<SavedLocation> _saved = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final list = await _storage.getSaved();
    if (mounted) setState(() => _saved = list);
  }

  Future<void> _add() async {
    final code = _controller.text.trim();
    if (!_kodeRegex.hasMatch(code)) {
      setState(() => _error = 'Format kode harus seperti 35.73.05.1002');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Validasi kode sekaligus mengambil nama wilayah dari API.
      final data = await _service.fetchForecast(code);
      await _storage.save(SavedLocation(code, '${data.lokasi.desa}, ${data.lokasi.kecamatan}'));
      if (mounted) Navigator.pop(context, code);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(SavedLocation loc) async {
    await _storage.remove(loc.code);
    await _loadSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tambah lokasi (kode wilayah tingkat IV)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
              'Kode desa/kelurahan mengacu pada Kepmendagri No. 100.1.1-6117 Tahun 2022.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Kode wilayah',
              hintText: '31.71.03.1001',
              errorText: _error,
            ),
            onSubmitted: (_) => _add(),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final c in const ['31.71.03.1001', '31.71.01.1001'])
              ActionChip(
                label: Text('Contoh $c'),
                onPressed: () => _controller.text = c,
              ),
          ]),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _add,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_location_alt),
            label: Text(_loading ? 'Memeriksa...' : 'Tambah & Gunakan'),
          ),
          const Divider(height: 40),
          Text('Lokasi tersimpan', style: Theme.of(context).textTheme.titleMedium),
          if (_saved.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Belum ada lokasi tersimpan.'),
            ),
          for (final loc in _saved)
            Card(
              child: ListTile(
                leading: Icon(
                  loc.code == widget.currentCode ? Icons.radio_button_checked : Icons.place,
                ),
                title: Text(loc.name),
                subtitle: Text(loc.code),
                onTap: () => Navigator.pop(context, loc.code),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _remove(loc),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
