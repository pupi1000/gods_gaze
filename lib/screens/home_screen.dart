// lib/screens/home_screen.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';

// Importaciones relativas (para evitar errores de caché)
import '../models/log_entry.dart';
import '../models/user_profile.dart';
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
    final CycleService cycleService = CycleService();

    final settings = storage.settings;
    final profile = storage.profile;
    final logHistory = storage.logHistory;

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
      body: !isDataReady
          ? const WelcomeView()
          : MainDashboard(
              // Le pasamos LOS 3 PILARES al cerebro
              suggestion: cycleService.getSmartSuggestion(
                settings, 
                profile,
                logHistory,
              ),
              logHistory: logHistory,
            ),
      floatingActionButton: isDataReady
          ? FloatingActionButton(
              onPressed: () {
                // Ir a la pantalla de crear (sin logToEdit)
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const LogEntryScreen()),
                );
              },
              tooltip: 'Registrar estado de hoy',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// --- WIDGETS HIJOS ---

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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

// --- DASHBOARD (CON ARREGLO DE SCROLL) ---
class MainDashboard extends StatelessWidget {
  final SmartSuggestion suggestion;
  final List<LogEntry> logHistory; 

  const MainDashboard({
    Key? key,
    required this.suggestion,
    required this.logHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // --- Header ---
        SliverToBoxAdapter(
          child: _HomeHeader(
            currentDay: suggestion.currentDay,
            phaseName: suggestion.phaseName,
          ),
        ),
        
        // --- Sugerencia Inteligente ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _SuggestionCard(
              // Usamos una key más robusta para forzar el redibujo
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
              'Historial Reciente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // --- Lista del Historial ---
        if (logHistory.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 96.0), 
                child: Text('Aún no hay registros.\nPresiona el botón "+" para empezar.', 
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.grey.shade600)),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _LogEntryCard(log: logHistory[index]);
              },
              childCount: logHistory.length,
            ),
          ),
        
        // --- ¡ARREGLO DEL BUG DE SCROLL! ---
        SliverToBoxAdapter(
          child: SizedBox(height: 96), 
        ),
      ],
    );
  }
}

// --- _HomeHeader ---
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
            colorScheme.primary.withOpacity(0.8),
            colorScheme.primary,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
                ?.copyWith(color: Colors.white.withOpacity(0.8), letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

// --- _SuggestionCard ---
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

// --- _SuggestionCardContent ---
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
              'Sugerencia Inteligente',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb,
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

// --- _SuggestionDetailView ---
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
            _DetailSection(
              icon: Icons.biotech,
              title: "Pilar 1: Contexto Biológico",
              content: suggestion.biologyInsight,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.person,
              title: "Pilar 3: Tu Manual de Usuario",
              content: suggestion.profileInsight,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.lightbulb,
              title: "Acción Sugerida",
              content: suggestion.actionSuggestion,
              color: Colors.green,
              isAction: true,
            ),
          ],
        ),
      ),
    );
  }
}

// --- _DetailSection ---
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


// --- _LogEntryCard (CON EDITAR Y BORRAR) ---
class _LogEntryCard extends StatelessWidget {
  final LogEntry log;
  const _LogEntryCard({Key? key, required this.log}) : super(key: key);

  // Helper para convertir enum a texto
  String _moodToText(DailyMood mood) {
    switch (mood) {
      case DailyMood.feliz: return 'Feliz';
      case DailyMood.calmada: return 'Calmada';
      case DailyMood.triste: return 'Triste';
      case DailyMood.irritable: return 'Irritable';
      case DailyMood.cansada: return 'Cansada';
    }
  }

  // Helper para el ícono
  IconData _moodToIcon(DailyMood mood) {
     switch (mood) {
      case DailyMood.feliz: return Icons.sentiment_very_satisfied;
      case DailyMood.calmada: return Icons.sentiment_satisfied;
      case DailyMood.triste: return Icons.sentiment_dissatisfied;
      case DailyMood.irritable: return Icons.sentiment_very_dissatisfied;
      case DailyMood.cansada: return Icons.airline_seat_individual_suite;
    }
  }

  // Diálogo de confirmación para borrar
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
          // --- ACCIÓN DE EDITAR (Tap corto) ---
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => LogEntryScreen(logToEdit: log),
              ),
            );
          },
          // --- ACCIÓN DE BORRAR (Tap largo) ---
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
                  children: [
                    Icon(_moodToIcon(log.mood),
                        color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(_moodToText(log.mood),
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
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
                // ¡Pista visual para el usuario!
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