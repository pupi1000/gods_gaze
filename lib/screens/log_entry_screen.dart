// lib/screens/log_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <-- Importación para DateFormat

// Importaciones relativas
import '../models/log_entry.dart';
import '../services/storage_service.dart';

class LogEntryScreen extends StatefulWidget {
  final LogEntry? logToEdit;
  final int? currentCycleDay; 
  final DateTime? selectedDate; // <-- ¡NUEVO! Acepta la fecha
  
  const LogEntryScreen({
    Key? key,
    this.logToEdit,
    this.currentCycleDay,
    this.selectedDate, // <-- ¡NUEVO!
  }) : super(key: key);

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {
  late DateTime _selectedDate;
  DailyMood? _selectedMood;
  late LogCause _selectedCause;
  late DailyEnergy _selectedEnergy;
  late SleepQuality _selectedSleep;
  late TextEditingController _noteController;
  late int _cycleDay;

  bool get isEditing => widget.logToEdit != null;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();

    if (isEditing) {
      final log = widget.logToEdit!;
      _selectedDate = log.date;
      _selectedMood = log.mood;
      _selectedCause = log.cause;
      _selectedEnergy = log.energy;
      _selectedSleep = log.sleep;
      _noteController.text = log.note;
      _cycleDay = log.cycleDay;
    } else {
      // --- ¡ARREGLO DEL BUG DE FECHA! ---
      // Usa la fecha seleccionada que pasamos, O (si no hay) usa hoy.
      final now = DateTime.now();
      _selectedDate = widget.selectedDate != null 
          ? DateTime(widget.selectedDate!.year, widget.selectedDate!.month, widget.selectedDate!.day)
          : DateTime(now.year, now.month, now.day);
      // ---------------------------------
      _selectedMood = null;
      _selectedCause = LogCause.noseguro;
      _selectedEnergy = DailyEnergy.noseguro; 
      _selectedSleep = SleepQuality.noseguro;
      _cycleDay = widget.currentCycleDay ?? 1;
    }
  }

  Future<void> _saveLog() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un estado de ánimo')),
      );
      return;
    }

    final storage = context.read<StorageService>();

    if (isEditing) {
      final log = widget.logToEdit!;
      log.date = _selectedDate;
      log.mood = _selectedMood!;
      log.cause = _selectedCause;
      log.energy = _selectedEnergy;
      log.sleep = _selectedSleep;
      log.note = _noteController.text;
      log.cycleDay = _cycleDay;
      
      await log.save(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro actualizado')),
      );

    } else {
      final newLog = LogEntry(
        date: _selectedDate, // <-- ¡Ahora usa la fecha correcta!
        mood: _selectedMood!,
        cause: _selectedCause,
        note: _noteController.text,
        energy: _selectedEnergy,
        sleep: _selectedSleep,
        cycleDay: _cycleDay,
      );
      
      await storage.saveLogEntry(newLog);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro guardado')),
      );
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _moodToText(DailyMood mood) {
    switch (mood) {
      case DailyMood.feliz: return 'Feliz / Con energía';
      case DailyMood.calmada: return 'Calmada / Normal'; // <-- Corregido
      case DailyMood.triste: return 'Triste / Sensible';
      case DailyMood.irritable: return 'Irritable / Molesta';
      case DailyMood.cansada: return 'Cansada / Baja energía';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Registro' : 'Registrar Estado (Día $_cycleDay)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Mostramos la fecha que estamos editando ---
            if (!isEditing) // Solo muestra esto si es un registro nuevo
              Center(
                child: Text(
                  DateFormat.yMMMMd('es_ES').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
              ),
            const SizedBox(height: 16),

            Text('1. ¿Cómo fue la calidad de sueño anoche?',
                style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<SleepQuality>(
              segments: const [
                ButtonSegment(value: SleepQuality.mala, label: Text('Mala'), icon: Icon(Icons.mood_bad)),
                ButtonSegment(value: SleepQuality.regular, label: Text('Regular'), icon: Icon(Icons.sentiment_neutral)),
                ButtonSegment(value: SleepQuality.buena, label: Text('Buena'), icon: Icon(Icons.mood)),
                ButtonSegment(value: SleepQuality.noseguro, label: Text('No Sé'), icon: Icon(Icons.help_outline)),
              ],
              selected: {_selectedSleep},
              onSelectionChanged: (Set<SleepQuality> newSelection) {
                setState(() {
                  _selectedSleep = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
             Text('2. ¿Cuál es su nivel de energía hoy?',
                style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<DailyEnergy>(
              segments: const [
                ButtonSegment(value: DailyEnergy.baja, label: Text('Baja'), icon: Icon(Icons.battery_alert)),
                ButtonSegment(value: DailyEnergy.media, label: Text('Media'), icon: Icon(Icons.battery_std)),
                ButtonSegment(value: DailyEnergy.alta, label: Text('Alta'), icon: Icon(Icons.battery_full)),
                ButtonSegment(value: DailyEnergy.noseguro, label: Text('No Sé'), icon: Icon(Icons.help_outline)),
              ],
              selected: {_selectedEnergy},
              onSelectionChanged: (Set<DailyEnergy> newSelection) {
                setState(() {
                  _selectedEnergy = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Text('3. ¿Cuál es su estado de ánimo principal?',
                style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: DailyMood.values.map((mood) {
                return ChoiceChip(
                  label: Text(_moodToText(mood)),
                  selected: _selectedMood == mood,
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedMood = mood;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('4. ¿Cuál crees que es la causa principal?',
                style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<LogCause>(
              segments: const [
                ButtonSegment(value: LogCause.ciclo, label: Text('Ciclo')),
                ButtonSegment(value: LogCause.vida, label: Text('Vida')),
                ButtonSegment(value: LogCause.noseguro, label: Text('No sé')),
              ],
              selected: {_selectedCause},
              onSelectionChanged: (Set<LogCause> newSelection) {
                setState(() {
                  _selectedCause = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Text('5. Nota (Contexto de "Vida")',
                style: Theme.of(context).textTheme.titleMedium),
            const Text('Ej: "Tuvo un mal día en el trabajo", "Durmió mal"',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Añade un contexto...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _saveLog,
              child: Text(isEditing ? 'Actualizar Registro' : 'Guardar Registro'),
            ),
          ],
        ),
      ),
    );
  }
}