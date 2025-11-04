// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gods_gaze/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime? _selectedDate;
  final _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<StorageService>().settings;
    if (settings != null) {
      _selectedDate = settings.lastPeriodDate;
      _durationController.text = settings.cycleDuration.toString();
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 40)),
      lastDate: now,
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  void _saveSettings() {
    if (_selectedDate == null || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration < 20 || duration > 45) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La duración del ciclo debe ser un número realista (ej. 28)')),
      );
      return;
    }

    context.read<StorageService>().saveSettings(_selectedDate!, duration);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Guardado!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat.yMMMMd('es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Ciclo'),
      ),
      // --- ARREGLO DEL BUG ---
      // 1. Envolvemos el Padding en un SingleChildScrollView
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('1. ¿Cuándo fue el primer día de su último período?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? 'Seleccionar Fecha'
                      : formatter.format(_selectedDate!),
                ),
                onPressed: () => _pickDate(context),
              ),
              const SizedBox(height: 24),
              Text('2. ¿Cuánto dura su ciclo usualmente? (ej. 28)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Duración en días',
                  border: OutlineInputBorder(),
                ),
              ),
              
              // 2. Reemplazamos el Spacer() por un SizedBox
              // Esto asegura que el botón siempre esté visible
              const SizedBox(height: 32), 

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveSettings,
                child: const Text('Guardar Configuración'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}