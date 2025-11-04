// lib/screens/home_screen.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart'; 

// Importaciones relativas
import '../models/log_entry.dart';
import '../models/user_profile.dart';
import '../models/pattern_info.dart'; // <-- ¡Importante!
import '../services/cycle_service.dart';
import '../services/storage_service.dart';
import './log_entry_screen.dart';
import './profile_screen.dart';
import './settings_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final settings = storage.settings;
    final profile = storage.profile;

    final bool isDataReady = (settings != null &&
        profile != null &&
        profile.primaryLoveLanguage != LoveLanguage.none);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "God's Gaze",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Hacemos que el texto y los iconos del AppBar sean oscuros
        foregroundColor: Colors.black87, 
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Manual de Usuario',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración del Ciclo',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,

      // --- ¡NUEVO FONDO BONITO! ---
      body: Container(
        // Añadimos el gradiente sutil
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50, // Un azul cielo muy, muy claro
            ],
          ),
        ),
        child: !isDataReady
            ? const WelcomeView()
            : MainDashboard(
                // Ya no pasamos el historial, el Dashboard lo leerá
              ),
      ),
      
      floatingActionButton: isDataReady
          ? FloatingActionButton(
              onPressed: () {
                // El FAB siempre registra para HOY
                final cycleService = CycleService();
                final settings = context.read<StorageService>().settings!;
                final profile = context.read<StorageService>().profile!;
                final logHistory = context.read<StorageService>().logHistory;
                
                // Calculamos el día del ciclo para HOY
                final suggestionForToday = cycleService.getSmartSuggestion(
                  settings, profile, logHistory, DateTime.now()
                );
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => LogEntryScreen(
                      currentCycleDay: suggestionForToday.currentDay, 
                      selectedDate: DateTime.now(), // ¡Le pasamos la fecha de HOY!
                    )
                  ),
                );
              },
              tooltip: 'Registrar estado de hoy',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// ... (WelcomeView no cambia) ...
class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // ... (código idéntico de antes) ...
    final storage = context.watch<StorageService>();
    String message;
    if (storage.settings == null) {
      message =
          "Para empezar, necesito los datos del ciclo. Presiona el ícono de Ajustes (⚙️) arriba a la derecha.";
    } else if (storage.profile == null ||
        storage.profile!.primaryLoveLanguage == LoveLanguage.none) {
      message =
          "¡Genial! Ahora ve al 'Manual de Usuario' (👤) para personalizar la app con su perfil.";
    } else {
      message = "Cargando...";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'Bienvenido a tu Copiloto',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


// --- ¡¡GRAN CAMBIO AQUÍ!! ---
// MainDashboard ahora es un StatefulWidget para guardar el día del calendario
class MainDashboard extends StatefulWidget {
  // Ya no necesita recibir nada, lo leerá todo de Provider
  const MainDashboard({ Key? key }) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // El estado del calendario ahora vive aquí
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _focusedDay = DateTime.now();
  
  // Guardamos la sugerencia que se está mostrando
  SmartSuggestion? _suggestionForDisplay;
  
  // Guardamos los logs para el día seleccionado
  List<LogEntry> _logsForSelectedDay = [];
  late Map<DateTime, List<LogEntry>> _logEvents;

  // El cerebro
  final CycleService _cycleService = CycleService();

  @override
  void initState() {
    super.initState();
    // Cargamos los datos iniciales (para HOY)
    final storage = context.read<StorageService>();
    _logEvents = _groupLogsByDay(storage.logHistory);
    _logsForSelectedDay = _getLogsForDay(_selectedDay, _logEvents);
    _recalculateSuggestion(_selectedDay);
  }
  
  // Actualiza el calendario si el historial de logs cambia (ej. al borrar/añadir)
  void _rebuildData() {
    final storage = context.read<StorageService>();
    _logEvents = _groupLogsByDay(storage.logHistory);
    _logsForSelectedDay = _getLogsForDay(_selectedDay, _logEvents);
    _recalculateSuggestion(_selectedDay);
  }

  // --- Lógica del Calendario movida aquí ---
  Map<DateTime, List<LogEntry>> _groupLogsByDay(List<LogEntry> logs) {
    Map<DateTime, List<LogEntry>> data = {};
    for (var log in logs) {
      final day = DateTime.utc(log.date.year, log.date.month, log.date.day);
      final existingLogs = data[day] ?? [];
      existingLogs.add(log);
      data[day] = existingLogs;
    }
    return data;
  }

  List<LogEntry> _getLogsForDay(DateTime day, Map<DateTime, List<LogEntry>> events) {
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    return events[dayUtc] ?? [];
  }
  
  // --- ¡ESTA ES LA LÓGICA CLAVE! ---
  // Se llama cuando el usuario toca un día
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay; 
      _logsForSelectedDay = _getLogsForDay(selectedDay, _logEvents);
      // ¡Recalculamos la sugerencia para el día seleccionado!
      _recalculateSuggestion(selectedDay);
    });
  }

  // --- ¡NUEVA FUNCIÓN! ---
  // Calcula la sugerencia para cualquier día
  void _recalculateSuggestion(DateTime forDate) {
    final storage = context.read<StorageService>();
    // Nos aseguramos de que los datos estén listos
    if (storage.settings != null && storage.profile != null) {
      _suggestionForDisplay = _cycleService.getSmartSuggestion(
        storage.settings!,
        storage.profile!,
        storage.logHistory, // Le pasamos el historial completo
        forDate, // ¡Le pasamos la fecha seleccionada!
      );
    }
  }

  // Calcula el "día del ciclo" para una fecha seleccionada
  int _calculateCycleDayForDate(DateTime selectedDate) {
    final settings = context.read<StorageService>().settings;
    if (settings == null) return 1; 

    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final lastPeriod = DateTime(settings.lastPeriodDate.year,
        settings.lastPeriodDate.month, settings.lastPeriodDate.day);
    
    return date.difference(lastPeriod).inDays + 1;
  }
  
  @override
  Widget build(BuildContext context) {
    // ¡¡IMPORTANTE!! Usamos 'watch' aquí.
    // Si un log cambia (se añade/borra), esto se re-ejecutará
    // y llamará a _rebuildData()
    final logHistory = context.watch<StorageService>().logHistory;
    
    // Comprobamos si el historial en memoria es diferente al del storage
    if (logHistory.length != _logEvents.values.expand((x) => x).length) {
       _rebuildData();
    }
    
    // Si la sugerencia aún no se ha calculado, muestra un 'cargando'
    if (_suggestionForDisplay == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final suggestion = _suggestionForDisplay!;

    return CustomScrollView(
      // --- ¡ARREGLO DE SCROLL! ---
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics()
      ),
      slivers: [
        // --- Header (ahora usa la sugerencia del estado) ---
        SliverToBoxAdapter(
          child: _HomeHeader(
            currentDay: suggestion.currentDay,
            phaseName: suggestion.phaseName,
          ),
        ),
        
        // --- Sugerencia Inteligente (ahora usa la sugerencia del estado) ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _SuggestionCard(
              key: ValueKey(suggestion.currentDay.toString() + suggestion.actionSuggestion),
              suggestion: suggestion,
            ),
          ),
        ),
        
        // --- Título del Historial ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              'Historial de Registros',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // --- Widget de Calendario ---
        SliverToBoxAdapter(
          child: _HistoryCalendar(
            logEvents: _logEvents,
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
            getLogsForDay: (day) => _getLogsForDay(day, _logEvents),
          ),
        ),

        // --- ¡¡ARREGLO DEL BUG DE REGISTRO!! ---
        if (_logsForSelectedDay.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'No hay registros para este día.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    // ¡EL BOTÓN PARA ARREGLAR EL BUG!
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text('Añadir registro para el ${DateFormat.MMMd('es_ES').format(_selectedDay)}'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => LogEntryScreen(
                              currentCycleDay: _calculateCycleDayForDate(_selectedDay),
                              selectedDate: _selectedDay, // <-- ¡LA MAGIA!
                            )
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _LogEntryCard(log: _logsForSelectedDay[index]);
              },
              childCount: _logsForSelectedDay.length,
            ),
          ),

        // Espacio al final
        const SliverToBoxAdapter(
          child: SizedBox(height: 96), 
        ),
      ],
    );
  }
}


// --- ¡WIDGET DE CALENDARIO MODIFICADO! ---
class _HistoryCalendar extends StatelessWidget {
  final Map<DateTime, List<LogEntry>> logEvents;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<LogEntry> Function(DateTime) getLogsForDay;

  const _HistoryCalendar({
    Key? key,
    required this.logEvents,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.getLogsForDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        locale: 'es_ES', 
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        eventLoader: getLogsForDay,
      ),
    );
  }
}

// --- _LogEntryCard (CON EDICIÓN DE FECHA) ---
class _LogEntryCard extends StatelessWidget {
  final LogEntry log;
  const _LogEntryCard({Key? key, required this.log}) : super(key: key);

  String _moodToText(DailyMood mood) {
    switch (mood) {
      case DailyMood.feliz: return 'Feliz';
      case DailyMood.calmada: return 'Calmada';
      case DailyMood.triste: return 'Triste';
      case DailyMood.irritable: return 'Irritable';
      case DailyMood.cansada: return 'Cansada';
    }
  }

  IconData _moodToIcon(DailyMood mood) {
     switch (mood) {
      case DailyMood.feliz: return Icons.sentiment_very_satisfied;
      case DailyMood.calmada: return Icons.sentiment_satisfied;
      case DailyMood.triste: return Icons.sentiment_dissatisfied;
      case DailyMood.irritable: return Icons.sentiment_very_dissatisfied;
      case DailyMood.cansada: return Icons.airline_seat_individual_suite;
    }
  }

  void _showDeleteDialog(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Borrado'),
          content: const Text('¿Estás seguro de que quieres borrar este registro? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Borrar'),
              onPressed: () {
                storage.deleteLogEntry(log);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final DateFormat formatter = DateFormat.yMMMMd('es');
    final storage = context.read<StorageService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => LogEntryScreen(
                  logToEdit: log,
                  currentCycleDay: log.cycleDay,
                  selectedDate: log.date,
                ),
              ),
            );
          },
          onLongPress: () {
            _showDeleteDialog(context, storage);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(log.date),
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                    Text(
                      "Causa: ${log.cause.name}",
                      style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_moodToIcon(log.mood),
                            color: colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        Text(_moodToText(log.mood),
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(
                      "Día ${log.cycleDay}",
                      style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Sueño: ${log.sleep.name} | Energía: ${log.energy.name}",
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                  ),
                ),
                if (log.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Nota: "${log.note}"',
                      style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade800),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Toca para editar, mantén presionado para borrar',
                      style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- WIDGETS DE LA TARJETA DE SUGERENCIA ---
// (¡Con el error 'shadowColor' arreglado!)

class _HomeHeader extends StatelessWidget {
  final int currentDay;
  final String phaseName;
  const _HomeHeader(
      {Key? key, required this.currentDay, required this.phaseName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
         boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('DÍA',
                      style: textTheme.titleMedium
                          ?.copyWith(color: Colors.white70)),
                  Text(
                    currentDay.toString(),
                    style: textTheme.displayLarge
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            phaseName.toUpperCase(),
            style: textTheme.titleMedium
                ?.copyWith(color: Colors.white.withOpacity(0.9), letterSpacing: 1.2, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SmartSuggestion suggestion;
  const _SuggestionCard({Key? key, required this.suggestion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, _) =>
          _SuggestionDetailView(suggestion: suggestion),
      closedElevation: 8,
      // --- ¡¡ARREGLO #3!! ---
      // 'shadowColor' no existe, lo borramos
      // -----------------------
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      closedColor: Theme.of(context).cardColor,
      closedBuilder: (context, openContainer) {
        return _SuggestionCardContent(
          suggestion: suggestion,
          onTap: openContainer,
        );
      },
    );
  }
}

class _SuggestionCardContent extends StatelessWidget {
  final SmartSuggestion suggestion;
  final VoidCallback onTap;
  const _SuggestionCardContent(
      {Key? key, required this.suggestion, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sugerencia del Día', // <-- Título cambiado
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline,
                    color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion.actionSuggestion,
                    style:
                        textTheme.bodyLarge?.copyWith(height: 1.5, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Toca para ver el porqué...',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- ¡¡WIDGET MEJORADO!! ---
// Ahora muestra 3 Pilares
class _SuggestionDetailView extends StatelessWidget {
  final SmartSuggestion suggestion;
  const _SuggestionDetailView({Key? key, required this.suggestion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('El Porqué de la Sugerencia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ¡NUEVO! PILAR 2 (REALIDAD) ---
            // Lo ponemos primero porque es lo más importante
            _DetailSection(
              icon: Icons.history,
              title: "Pilar 2: Realidad (Tus Registros)",
              content: suggestion.realityInsight,
              color: Colors.orange.shade700, // Un color nuevo
            ),
            const SizedBox(height: 16),
            
            // --- PILAR 1 (BIOLOGÍA) ---
            _DetailSection(
              icon: Icons.biotech,
              title: "Pilar 1: Contexto Biológico",
              content: suggestion.biologyInsight,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            
            // --- PILAR 3 (MANUAL) ---
            _DetailSection(
              icon: Icons.person,
              title: "Pilar 3: Tu Manual de Usuario",
              content: suggestion.profileInsight,
              color: Colors.purple.shade700,
            ),
            const SizedBox(height: 16),
            
            // --- ACCIÓN ---
            _DetailSection(
              icon: Icons.lightbulb,
              title: "Acción Sugerida",
              content: suggestion.actionSuggestion,
              color: Colors.green.shade700,
              isAction: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final bool isAction;

  const _DetailSection({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    this.isAction = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5))),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              content,
              style: textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                  fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}