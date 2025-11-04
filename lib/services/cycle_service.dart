// lib/services/cycle_service.dart
import '../models/app_settings.dart';
import '../models/log_entry.dart';
import '../models/user_profile.dart';

// ... (SmartSuggestion class no cambia) ...
class SmartSuggestion {
  final int currentDay;
  final String phaseName;
  final String biologyInsight; 
  final String profileInsight; 
  final String actionSuggestion;
  SmartSuggestion({
    required this.currentDay,
    required this.phaseName,
    required this.biologyInsight,
    required this.profileInsight,
    required this.actionSuggestion,
  });
}

class CycleService {
  SmartSuggestion getSmartSuggestion(
    AppSettings settings,
    UserProfile profile,
    List<LogEntry> logHistory,
  ) {
    // ... (Paso 1: Cálculo Biológico no cambia) ...
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPeriod = DateTime(settings.lastPeriodDate.year,
        settings.lastPeriodDate.month, settings.lastPeriodDate.day);
    final int currentDay = today.difference(lastPeriod).inDays + 1;
    final int ovulationDay = settings.cycleDuration - 14;
    String currentPhaseName;
    String biologyInsight;
    bool isHighEnergyPhase;
    bool isPredictedLowEnergy = false; // <-- NUEVO Flag

     if (currentDay <= 5) {
      currentPhaseName = "Fase 1: Menstruación";
      biologyInsight = "Las hormonas están bajas. La energía física y emocional está en su punto más bajo. Es común sentir cansancio y cólicos.";
      isHighEnergyPhase = false;
      isPredictedLowEnergy = true; // <-- Flag
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
        isPredictedLowEnergy = true; // <-- Flag
      }
    } else {
      currentPhaseName = "Fuera de Rango";
      biologyInsight = "El ciclo calculado ya ha terminado. Es hora de actualizar la fecha de inicio del último período en 'Ajustes' para obtener nuevas predicciones.";
      isHighEnergyPhase = false;
      return SmartSuggestion(
          currentDay: currentDay,
          phaseName: currentPhaseName,
          biologyInsight: biologyInsight,
          profileInsight: "Actualiza los datos del ciclo.",
          actionSuggestion: "Ve a Ajustes (⚙️) y actualiza la fecha de inicio del último período.");
    }

    // ... (Paso 2: Generar Sugerencia Base no cambia) ...
    String profileInsight = "Tu Manual de Usuario dice...";
    String actionSuggestion = "Acción Sugerida...";
    if (isHighEnergyPhase) {
      profileInsight += "\n✓ Predicción: Energía biológica ALTA.";
      actionSuggestion = "Predicción: ¡Gran día para conectar! ";
      switch (profile.primaryLoveLanguage) {
        case LoveLanguage.time:
          actionSuggestion += "Su lenguaje principal es 'Tiempo de Calidad'. Propon un plan sin distracciones.";
          profileInsight += "\n✓ Valora el 'Tiempo de Calidad'.";
          break;
        case LoveLanguage.words:
           actionSuggestion += "Su lenguaje principal es 'Palabras de Afirmación'. Dile lo que admiras de ella.";
           profileInsight += "\n✓ Valora las 'Palabras de Afirmación'.";
          break;
        case LoveLanguage.service:
           actionSuggestion += "Su lenguaje principal es 'Actos de Servicio'. Ofrécete a ayudarla con una tarea.";
           profileInsight += "\n✓ Valora los 'Actos de Servicio'.";
          break;
        default:
          actionSuggestion += "Aprovecha la buena energía para socializar, tener una cita divertida o bromear.";
          profileInsight += "\n✓ (Sin Lenguaje de Amor definido)";
      }
    } else {
      profileInsight += "\n✓ Predicción: Energía biológica BAJA.";
      actionSuggestion = "Predicción: Día de baja energía. Paciencia y apoyo. ";
      switch (profile.stressResponse) {
        case StressResponse.space:
          actionSuggestion += "Tu manual dice que prefiere 'Espacio'. Dale su tiempo a solas, no la presiones.";
          profileInsight += "\n✓ Prefiere 'Espacio' bajo estrés.";
          break;
        case StressResponse.talk:
          actionSuggestion += "Tu manual dice que prefiere 'Hablarlo'. Ofrécele tu escucha activa, sin juicios.";
          profileInsight += "\n✓ Prefiere 'Hablarlo' bajo estrés.";
          break;
        case StressResponse.distraction:
           actionSuggestion += "Tu manual dice que prefiere 'Distracción'. Intenta animarla con un 'Botón Mágico' o una broma ligera.";
           profileInsight += "\n✓ Prefiere 'Distracciones' bajo estrés.";
          break;
        default:
          actionSuggestion += "Ofrécele confort y no tomes la irritabilidad como algo personal.";
          profileInsight += "\n✓ (Sin Respuesta al Estrés definida)";
      }
    }
    
    // ... (Paso 3: Lógica de sobrescribir con Pilar 2 no cambia) ...
    final logsDeHoy = _findLogsForDay(logHistory, today);
    bool isRealLowEnergy = false; // <-- Nuevo Flag de Realidad

    if (logsDeHoy.isNotEmpty) {
      biologyInsight = "¡Anulado por ${logsDeHoy.length} registro(s) de hoy!";
      profileInsight = "Hoy registraste lo siguiente:\n";
      actionSuggestion = "¡Realidad mata predicción! ";
      final ultimoLog = logsDeHoy.first; 
      
      for (var log in logsDeHoy) {
         profileInsight += "\n• '${log.mood.name}' (Energía: ${log.energy.name}, Sueño: ${log.sleep.name}). Causa: '${log.cause.name}'.";
         if (log.note.isNotEmpty) profileInsight += " Nota: '${log.note}'";
      }
      
      if (ultimoLog.mood == DailyMood.cansada || ultimoLog.mood == DailyMood.irritable || ultimoLog.mood == DailyMood.triste) {
        isRealLowEnergy = true; // <-- Flag
      }
      
      if (ultimoLog.cause == LogCause.vida) {
        actionSuggestion += "El factor principal parece ser 'Vida'. Enfócate en lo que registraste";
        if (ultimoLog.note.isNotEmpty) actionSuggestion += ": ${ultimoLog.note}.";
      } else {
         actionSuggestion += "Tu registro confirma que el 'Ciclo' está afectando. ";
         switch (profile.stressResponse) {
            case StressResponse.space: actionSuggestion += "Recuerda, ella prefiere 'Espacio'."; break;
            case StressResponse.talk: actionSuggestion += "Recuerda, ella prefiere 'Hablarlo'."; break;
            case StressResponse.distraction: actionSuggestion += "Recuerda, ella prefiere una 'Distracción'."; break;
            default: actionSuggestion += "Apóyala con confort.";
         }
      }
    } else {
      final logDeAyer = _findLogsForDay(logHistory, today.subtract(const Duration(days: 1)));
      if (logDeAyer.isNotEmpty && (logDeAyer.first.mood == DailyMood.irritable || logDeAyer.first.mood == DailyMood.triste)) {
        actionSuggestion = "¡OJO! " + actionSuggestion;
        profileInsight += "\n\n⚠️ ADVERTENCIA: Ayer registraste '${logDeAyer.first.mood.name}'. Aunque la predicción de hoy sea buena, ve con calma.";
        isRealLowEnergy = true; // <-- Flag
      }
    }

    // --- ¡¡PASO 4: CONECTAR LOS BOTONES MÁGICOS!! ---
    if( (isPredictedLowEnergy || isRealLowEnergy) && profile.magicButtonText.isNotEmpty) {
      // Si es un día malo (predicho O real) Y has guardado un botón mágico...
      actionSuggestion += "\n\n💡 **Botón Mágico:** Recuerda que guardaste esto como algo que suele animarla: '${profile.magicButtonText}'.";
    }

    return SmartSuggestion(
      currentDay: currentDay,
      phaseName: currentPhaseName,
      biologyInsight: biologyInsight,
      profileInsight: profileInsight,
      actionSuggestion: actionSuggestion,
    );
  }

  // ... (Función _findLogsForDay no cambia) ...
  List<LogEntry> _findLogsForDay(List<LogEntry> logHistory, DateTime day) {
    return logHistory.where(
      (log) =>
          log.date.day == day.day &&
          log.date.month == day.month &&
          log.date.year == day.year,
    ).toList();
  }
}