// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para el input de números
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  LoveLanguage _loveLanguage = LoveLanguage.none;
  StressResponse _stressResponse = StressResponse.none;
  
  // --- ¡CAMBIO AQUÍ! ---
  final _ageController = TextEditingController();
  final _magicButtonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = context.read<StorageService>().profile;
    if (profile != null) {
      _loveLanguage = profile.primaryLoveLanguage;
      _stressResponse = profile.stressResponse;
      _magicButtonController.text = profile.magicButtonText;
      // --- ¡CAMBIO AQUÍ! ---
      if (profile.age != null) {
        _ageController.text = profile.age.toString();
      }
    }
  }

  void _saveProfile() {
    final newProfile = UserProfile(
      primaryLoveLanguage: _loveLanguage,
      stressResponse: _stressResponse,
      magicButtonText: _magicButtonController.text,
      // --- ¡CAMBIO AQUÍ! ---
      age: int.tryParse(_ageController.text), // int.tryParse es seguro
    );

    context.read<StorageService>().saveProfile(newProfile);
    
    // (Tu petición de vaciar campos)
    // setState(() {
    //   _loveLanguage = LoveLanguage.none;
    //   _stressResponse = StressResponse.none;
    //   _ageController.clear();
    //   _magicButtonController.clear();
    // });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- ¡CAMBIO AQUÍ! (Pregunta 1: EDAD) ---
              Text('1. Edad',
                  style: Theme.of(context).textTheme.titleMedium),
              const Text(
                  'Ayuda a ajustar la precisión de las predicciones (ej. SPM en 40s+).',
                  style: TextStyle(color: Colors.grey)),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Edad (ej. 28)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // ... (Preguntas 2, 3, 4 y el botón son iguales que antes) ...
              
              Text('2. ¿Cómo se siente más amada?',
                  style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<LoveLanguage>(
                value: _loveLanguage,
                // ... (items de Dropdown igual que antes) ...
                 items: const [
                  DropdownMenuItem(
                      value: LoveLanguage.none, child: Text('No definido')),
                  DropdownMenuItem(
                      value: LoveLanguage.words,
                      child: Text('Palabras de Afirmación')),
                  DropdownMenuItem(
                      value: LoveLanguage.time,
                      child: Text('Tiempo de Calidad')),
                  DropdownMenuItem(
                      value: LoveLanguage.gifts,
                      child: Text('Recibir Regalos')),
                  DropdownMenuItem(
                      value: LoveLanguage.service,
                      child: Text('Actos de Servicio')),
                  DropdownMenuItem(
                      value: LoveLanguage.touch,
                      child: Text('Contacto Físico')),
                ],
                onChanged: (value) {
                  setState(() {
                    _loveLanguage = value ?? LoveLanguage.none;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Text('3. Cuando está estresada, ¿qué prefiere?',
                  style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<StressResponse>(
                value: _stressResponse,
                // ... (items de Dropdown igual que antes) ...
                items: const [
                  DropdownMenuItem(
                      value: StressResponse.none, child: Text('No definido')),
                  DropdownMenuItem(
                      value: StressResponse.talk,
                      child: Text('Hablarlo/Desahorgarse')),
                  DropdownMenuItem(
                      value: StressResponse.solutions,
                      child: Text('Buscar soluciones')),
                  DropdownMenuItem(
                      value: StressResponse.distraction,
                      child: Text('Una distracción (bromas)')),
                  DropdownMenuItem(
                      value: StressResponse.space,
                      child: Text('Su espacio/Estar sola')),
                ],
                 onChanged: (value) {
                  setState(() {
                    _stressResponse = value ?? StressResponse.none;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Text('4. "Botones Mágicos" (Opcional)',
                  style: Theme.of(context).textTheme.titleMedium),
              const Text(
                  'Cosas que casi siempre la animan. Ej: "Su chocolate favorito"',
                  style: TextStyle(color: Colors.grey)),
              TextField(
                controller: _magicButtonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Separados por coma...',
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
                onPressed: _saveProfile,
                child: const Text('Guardar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}