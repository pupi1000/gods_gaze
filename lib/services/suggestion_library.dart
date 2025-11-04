// lib/services/suggestion_library.dart
import 'dart:math'; 
// Importaciones relativas
import '../models/user_profile.dart';
import '../models/log_entry.dart';
import '../models/pattern_info.dart'; 

class SuggestionLibrary {
  
  String _getRandom(List<String> list) {
    list.shuffle(Random());
    return list.first;
  }

  // === 1. FRASES PARA DÍAS DE ALTA ENERGÍA ===
  String getHighEnergySuggestion(LoveLanguage lang) {
    String baseSuggestion = _getRandom([
      "La predicción biológica sugiere un día de alta energía.",
      "La biología predice un buen estado de ánimo y confianza.",
      "Predicción: Energía en aumento. Un gran momento para conectar.",
    ]);

    String langSuggestion = "";
    switch (lang) {
      case LoveLanguage.time:
        langSuggestion = _getRandom([
          "Ideal para 'Tiempo de Calidad'. ¿Qué tal un plan sin distracciones, solo ustedes dos?",
          "Es un día perfecto para 'Tiempo de Calidad'. Pregúntale cómo está y escucha activamente.",
        ]);
        break;
      case LoveLanguage.words:
        langSuggestion = _getRandom([
          "Perfecto para 'Palabras de Afirmación'. Dile algo que admiras de ella hoy.",
          "Aprovecha la buena energía. Hoy es un gran día para recordarle lo mucho que la quieres con palabras.",
        ]);
        break;
      case LoveLanguage.service:
        langSuggestion = _getRandom([
          "Un 'Acto de Servicio' sería genial hoy. ¿Puedes prepararle el café o ayudarla con algo del trabajo?",
          "Pregúntale: '¿Hay algo que pueda hacer por ti hoy para hacerte el día más fácil?'.",
        ]);
        break;
      default:
        langSuggestion = "Aprovecha la buena vibra para un plan divertido.";
    }
    
    return "$baseSuggestion $langSuggestion";
  }

  // === 2. FRASES PARA DÍAS DE BAJA ENERGÍA ===
  String getLowEnergySuggestion(StressResponse stress, String magicButton) {
    String baseSuggestion = _getRandom([
      "Predicción: Día de baja energía. Paciencia y apoyo son clave hoy.",
      "Predicción: Las hormonas están bajando. Es un día para tomárselo con calma y ofrecer confort.",
      "Predicción: Día de baja energía. No tomes la irritabilidad o el cansancio como algo personal.",
    ]);

    String stressSuggestion = "";
    switch (stress) {
      case StressResponse.space:
        stressSuggestion = "Recuerda que prefiere 'Espacio' cuando está así. Dale su tiempo a solas, no la presiones.";
        break;
      case StressResponse.talk:
        stressSuggestion = "Recuerda que prefiere 'Hablarlo'. Ofrécele tu escucha activa, sin juicios.";
        break;
      case StressResponse.distraction:
         stressSuggestion = "Recuerda que prefiere una 'Distracción'. Intenta animarla con una broma ligera.";
         break;
      default:
        stressSuggestion = "Ofrécele confort y paciencia.";
    }

    if (magicButton.isNotEmpty) {
      stressSuggestion += getMagicButtonSuggestion(magicButton); // <-- Llama a la función pública
    }
    
    return "$baseSuggestion $stressSuggestion";
  }

  // === 3. FRASES PARA LA "IA" ===

  String getRealTimeLogSuggestion(LogEntry log, UserProfile profile) {
     String base = _getRandom([
      "¡Dato en tiempo real! ",
      "¡Registro de hoy! ",
      "¡Tu registro anula la predicción! ",
    ]);

    if (log.mood == DailyMood.feliz || log.mood == DailyMood.calmada) {
      base += "Has registrado que se siente '${log.mood.name}'. ¡Genial! ";
      switch (profile.primaryLoveLanguage) {
        case LoveLanguage.time: 
          base += "Aprovecha esta buena racha para 'Tiempo de Calidad', como salir a pasear.";
          break;
        case LoveLanguage.words:
          base += "Aprovecha para darle 'Palabras de Afirmación' y celebrar el buen momento.";
          break;
        default:
          base += "Es un momento perfecto para un plan divertido o socializar.";
      }
    } else {
      base += "Has registrado que se siente '${log.mood.name}'. Paciencia y apoyo. ";
      switch (profile.stressResponse) {
          case StressResponse.space: base += "Recuerda, ella prefiere 'Espacio'."; break;
          case StressResponse.talk: base += "Recuerda, ella prefiere 'Hablarlo'."; break;
          case StressResponse.distraction: base += "Recuerda, ella prefiere una 'Distracción'."; break;
          default: base += "Apóyala con confort.";
      }
      if (profile.magicButtonText.isNotEmpty) {
        base += getMagicButtonSuggestion(profile.magicButtonText);
      }
    }
    return base;
  }

  String getPatternSuggestion(PatternInfo pattern, UserProfile profile) {
    String base = _getRandom([
      "¡Patrón Detectado! ",
      "¡IA de Patrones Activada! ",
      "¡El historial es claro! ",
    ]);

    base += "El historial de este día (${pattern.mostCommonMood.name}) es más fuerte que la predicción biológica. ";
    
    if (pattern.mostCommonMood == DailyMood.triste || 
        pattern.mostCommonMood == DailyMood.irritable || 
        pattern.mostCommonMood == DailyMood.cansada) 
    {
      switch (profile.stressResponse) {
        case StressResponse.space: base += "Tu manual dice que prefiere 'Espacio' en días así. Dale su tiempo."; break;
        case StressResponse.talk: base += "Tu manual dice que prefiere 'Hablarlo'. Ofrécele tu escucha."; break;
        case StressResponse.distraction: base += "Tu manual dice que prefiere una 'Distracción'. Intenta animarla."; break;
        default: base += "Prepárate para dar confort y paciencia, como has hecho antes.";
      }
      if (profile.magicButtonText.isNotEmpty) {
        base += getMagicButtonSuggestion(profile.magicButtonText);
      }
    } else {
      base += "¡El historial confirma que hoy es un buen día! Avanza con tu plan.";
    }
    return base;
  }

  // --- ¡¡ARREGLO #1 AQUÍ!! ---
  // Se quita el guion bajo '_' para hacerla pública
  String getMagicButtonSuggestion(String magicButtonText) {
    return _getRandom([
      "\n\n💡 **Botón Mágico:** Recuerda que guardaste esto: '${magicButtonText}'.",
      "\n\n💡 **Idea:** ¿Quizás sea un buen momento para tu 'Botón Mágico'? ('${magicButtonText}')",
      "\n\n💡 **As bajo la manga:** '${magicButtonText}'.",
    ]);
  }
}