// lib/services/cycle_service.dart
import 'dart:math'; 
import './suggestion_library.dart';
// Importaciones relativas
import '../models/app_settings.dart';
import '../models/log_entry.dart';
import '../models/user_profile.dart';
import '../models/pattern_info.dart'; 

class SmartSuggestion {
  final int currentDay;
  final String phaseName;
  final String biologyInsight;    
  final String profileInsight;    
  final String realityInsight;    
  final String actionSuggestion;  

  SmartSuggestion({
    required this.currentDay,
    required this.phaseName,
    required this.biologyInsight,
    required this.profileInsight,
    required this.realityInsight, 
    required this.actionSuggestion,
  });
}

class CycleService {

  final SuggestionLibrary _lib = SuggestionLibrary();

  SmartSuggestion getSmartSuggestion(
    AppSettings settings,
    UserProfile profile,
    List<LogEntry> logHistory,
    DateTime forDate,
  ) {
    // === PASO 1: CÁLCULO BIOLÓGICO (Pilar 1) ===
    final date = DateTime(forDate.year, forDate.month, forDate.day);
    final lastPeriod = DateTime(settings.lastPeriodDate.year,
        settings.lastPeriodDate.month, settings.lastPeriodDate.day);
    final int currentDay = date.difference(lastPeriod).inDays + 1;
    final int ovulationDay = settings.cycleDuration - 14;
    
    String currentPhaseName;
    String biologyInsight;
    bool isPredictedLowEnergy = false; 
    
    // --- ¡¡ARREGLO #2!! ---
    // 'isHighEnergyPhase' se define aquí para que exista en todo el "scope"
    bool isHighEnergyPhase; 

     if (currentDay <= 5) {
      currentPhaseName = "Fase 1: Menstruación";
      biologyInsight = "Las hormonas están bajas. La energía física y emocional está en su punto más bajo. Es común sentir cansancio y cólicos.";
      isHighEnergyPhase = false;
      isPredictedLowEnergy = true; 
    } else if (currentDay > 5 && currentDay < ovulationDay) {
      currentPhaseName = "Fase 2: Folicular";
      biologyInsight = "El estrógeno está subiendo. Esto trae un aumento de energía, buen humor, confianza y creatividad.";
      isHighEnergyPhase = true;
    } else if (currentDay >= ovulationDay && currentDay <= ovulationDay + 2) {
      currentPhaseName = "Fase 3: Ovulación";
      biologyInsight = "¡Pico de hormonas! Máxima energía, libido y habilidades de comunicación. La conexión es más fácil.";
      isHighEnergyPhase = true;
    } else if (currentDay > ovulationDay + 2 &&
        currentDay <= settings.cycleDuration) {
      final int spmStarts = settings.cycleDuration - 7;
      if (currentDay < spmStarts) {
        currentPhaseName = "Fase 4: Lútea (Temprana)";
        biologyInsight = "La progesterona domina. Es una fase de calma y energía estable. Buena para tareas que requieren enfoque.";
        isHighEnergyPhase = true;
      } else {
        currentPhaseName = "Fase 4: Lútea (Tardía - SPM)";
        if (profile.age != null && profile.age! >= 40) { 
           biologyInsight = "¡Alerta de SPM (Perimenopausia)! Las hormonas caen bruscamente. El cansancio, la irritabilidad y la sensibilidad pueden ser MÁS intensos e impredecibles.";
        } else {
           biologyInsight = "¡Alerta de SPM! Las hormonas caen. Es común sentir cansancio, irritabilidad, antojos y sensibilidad emocional.";
        }
        isHighEnergyPhase = false;
        isPredictedLowEnergy = true;
      }
    } else {
      currentPhaseName = "Fuera de Rango";
      biologyInsight = "El ciclo calculado ya ha terminado. Es hora de actualizar la fecha de inicio del último período en 'Ajustes' para obtener nuevas predicciones.";
      isHighEnergyPhase = false; // Añadido para que la variable esté inicializada
      return SmartSuggestion(
          currentDay: currentDay,
          phaseName: currentPhaseName,
          biologyInsight: biologyInsight,
          profileInsight: "Actualiza los datos del ciclo.",
          realityInsight: "N/A",
          actionSuggestion: "Ve a Ajustes (⚙️) y actualiza la fecha de inicio del último período.");
    }

    // === PASO 2: CONSTRUIR INSIGHTS (Pilar 3 y 2) ===
    String profileInsight = "Tu Manual de Usuario dice:\n"
                           "✓ Valora el '${profile.primaryLoveLanguage.name}'.\n"
                           "✓ Prefiere '${profile.stressResponse.name}' bajo estrés.";
    
    String realityInsight = "Aún no hay registros para este día.";
    String actionSuggestion = "";
    bool isRealLowEnergy = false; 

    // --- ¡¡ARREGLO #3!! ---
    // 'logsDeHoy' se define aquí para que exista en todo el "scope"
    final logsDeHoy = _findLogsForDay(logHistory, date);
    final pattern = _findPatternForDay(logHistory, currentDay);

    if (logsDeHoy.isNotEmpty) {
      // --- Lógica de Pilar 2 (Realidad) ---
      final ultimoLog = logsDeHoy.first; 
      realityInsight = "¡Dato en tiempo real! Hoy registraste:\n";
      for (var log in logsDeHoy) {
         realityInsight += "\n• '${log.mood.name}' (Energía: ${log.energy.name}, Sueño: ${log.sleep.name}). Causa: '${log.cause.name}'.";
         if (log.note.isNotEmpty) realityInsight += " Nota: '${log.note}'";
      }
      
      if (ultimoLog.mood == DailyMood.cansada || ultimoLog.mood == DailyMood.irritable || ultimoLog.mood == DailyMood.triste) {
        isRealLowEnergy = true;
      }
      
      actionSuggestion = _lib.getRealTimeLogSuggestion(ultimoLog, profile);

    } else if (pattern != null) {
      // --- Lógica de Pilar 2 (IA de Patrones) ---
      isRealLowEnergy = (pattern.mostCommonMood == DailyMood.triste || 
                         pattern.mostCommonMood == DailyMood.irritable || 
                         pattern.mostCommonMood == DailyMood.cansada);

      realityInsight = "¡Patrón Detectado! (Pilar 2):\n"
                       "Has registrado este día del ciclo ${pattern.logCount} veces.\n"
                       "El patrón más común es: '${pattern.mostCommonMood.name}'.";
      
      actionSuggestion = _lib.getPatternSuggestion(pattern, profile);

    } else {
      // --- No hay datos del Pilar 2 ---
      realityInsight = "No hay registros o patrones para este día. Usando predicción biológica.";
      
      // --- ¡¡ARREGLO #4!! ---
      // Esta lógica se mueve DENTRO del 'else'
      if (isHighEnergyPhase) {
        actionSuggestion = _lib.getHighEnergySuggestion(profile.primaryLoveLanguage);
      } else {
        actionSuggestion = _lib.getLowEnergySuggestion(profile.stressResponse, profile.magicButtonText);
      }
      
      // Si el día de AYER fue malo, añadimos una advertencia
      final logDeAyer = _findLogsForDay(logHistory, date.subtract(const Duration(days: 1)));
      if (logDeAyer.isNotEmpty && (logDeAyer.first.mood == DailyMood.irritable || logDeAyer.first.mood == DailyMood.triste)) {
        actionSuggestion = "¡OJO! " + actionSuggestion;
        profileInsight += "\n\n⚠️ ADVERTENCIA: Ayer registraste '${logDeAyer.first.mood.name}'. Aunque la predicción de hoy sea buena, ve con calma.";
      }
    }

    // === PASO 3: LÓGICA FINAL (Botones Mágicos, etc.) ===
    
    // --- ¡¡ARREGLO #5!! ---
    // Esta lógica se movió aquí, pero ahora llama a la función PÚBLICA
    if( (isPredictedLowEnergy || isRealLowEnergy) && 
        logsDeHoy.isEmpty && // Solo si no hay un log de hoy (porque el log ya lo añade)
        pattern == null &&   // Solo si no hay un patrón (porque el patrón ya lo añade)
        profile.magicButtonText.isNotEmpty) 
    {
      actionSuggestion += _lib.getMagicButtonSuggestion(profile.magicButtonText);
    }

    return SmartSuggestion(
      currentDay: currentDay,
      phaseName: currentPhaseName,
      biologyInsight: biologyInsight,
      profileInsight: profileInsight,
      realityInsight: realityInsight,
      actionSuggestion: actionSuggestion,
    );
  }

  // --- Función de Ayuda para buscar logs de UN día ---
  List<LogEntry> _findLogsForDay(List<LogEntry> logHistory, DateTime day) {
    return logHistory.where(
      (log) =>
          log.date.day == day.day &&
          log.date.month == day.month &&
          log.date.year == day.year,
    ).toList();
  }
  
  // --- Función de "IA" ---
  PatternInfo? _findPatternForDay(List<LogEntry> logHistory, int cycleDay) {
    final logsForThisDay = logHistory.where((log) => log.cycleDay == cycleDay).toList();
    if (logsForThisDay.length < 2) { 
      return null;
    }
    Map<DailyMood, int> moodCounts = {};
    for (var log in logsForThisDay) {
      moodCounts[log.mood] = (moodCounts[log.mood] ?? 0) + 1;
    }
    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final mostCommonMood = sortedMoods.first.key;
    return PatternInfo(
      logCount: logsForThisDay.length,
      mostCommonMood: mostCommonMood,
    );
  }
}