// lib/screens/log_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importaciones relativas
import '../models/log_entry.dart';
import '../services/storage_service.dart';

class LogEntryScreen extends StatefulWidget {
  final LogEntry? logToEdit;
  
  const LogEntryScreen({
    Key? key,
    this.logToEdit,
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
    } else {
      _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      _selectedMood = null;
      _selectedCause = LogCause.noseguro;
      _selectedEnergy = DailyEnergy.noseguro; 
      _selectedSleep = SleepQuality.noseguro;
    }
  }

  // --- ¡ARREGLO #2 AQUÍ! ---
  // 1. Hacemos la función 'async'
  Future<void> _saveLog() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un estado de ánimo')),
      );
      return;
    }

    // Usamos 'context.read' porque estamos DENTRO de una función/callback
    final storage = context.read<StorageService>();

    if (isEditing) {
      final log = widget.logToEdit!;
      log.date = _selectedDate;
      log.mood = _selectedMood!;
      log.cause = _selectedCause;
      log.energy = _selectedEnergy;
      log.sleep = _selectedSleep;
      log.note = _noteController.text;
      
      // 2. AÑADIMOS 'await' para esperar a que termine de guardar
      await log.save(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro actualizado')),
      );

    } else {
      final newLog = LogEntry(
        date: _selectedDate,
        mood: _selectedMood!,
        cause: _selectedCause,
        note: _noteController.text,
        energy: _selectedEnergy,
        sleep: _selectedSleep,
      );
      
      // 3. AÑADIMOS 'await' aquí también
      await storage.saveLogEntry(newLog);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro guardado')),
      );
    }
    
    // 4. Esta línea AHORA SÍ espera a que el guardado termine
    // (Asegurándonos de que el widget no esté montado si el usuario cerró la app mientras guardaba)
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  // --- FIN DEL ARREGLO #2 ---


  String _moodToText(DailyMood mood) {
    switch (mood) {
      case DailyMood.feliz: return 'Feliz / Con energía';
      case DailyMood.calmada: return 'Calmada / Normal';
      case DailyMood.triste: return 'Triste / Sensible';
      case DailyMood.irritable: return 'Irritable / Molesta';
      case DailyMood.cansada: return 'Cansada / Baja energía';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Registro' : 'Registrar Estado de Hoy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. SUEÑO ---
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

            // --- 2. ENERGÍA ---
             Text('2. ¿Cuál es su nivel de energía hoy?',
                style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<DailyEnergy>(
              segments: const [
                ButtonSegment(value: DailyEnergy.baja, label: Text('Baja'), icon: Icon(Icons.battery_alert)),
                // --- ¡¡ARREGLO #1 AQUÍ!! ---
                // Cambiado de 'DailyFullEnergy.media' a 'DailyEnergy.media'
                ButtonSegment(value: DailyEnergy.media, label: Text('Media'), icon: Icon(Icons.battery_std)),
                // ---------------------------------
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

            // --- 3. HUMOR ---
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

            // --- 4. CAUSA ---
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

            // --- 5. NOTA ---
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

            // --- BOTÓN DE GUARDAR ---
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