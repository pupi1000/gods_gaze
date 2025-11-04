// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Importaciones relativas
import './models/app_settings.dart';
import './models/log_entry.dart';
import './models/user_profile.dart';
import './services/storage_service.dart';
import './screens/home_screen.dart';


void main() async {
  // 1. Aseguramos que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializamos Hive
  await Hive.initFlutter();

  // 3. Registramos TODOS nuestros Adaptadores
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(LoveLanguageAdapter());
  Hive.registerAdapter(StressResponseAdapter());
  Hive.registerAdapter(LogEntryAdapter());
  Hive.registerAdapter(DailyMoodAdapter());
  Hive.registerAdapter(LogCauseAdapter());
  
  // --- ¡¡AQUÍ ESTÁ EL ARREGLO!! ---
  // Se nos olvidó registrar estos dos
  Hive.registerAdapter(DailyEnergyAdapter());
  Hive.registerAdapter(SleepQualityAdapter());
  // ---------------------------------

  // 4. Inicializamos el formateo de fechas
  await initializeDateFormatting('es', null);
  
  // 5. Creamos nuestro servicio
  final storageService = StorageService();
  // 6. Cargamos los datos de Hive
  await storageService.loadAllDataFromHive();

  runApp(
    ChangeNotifierProvider(
      create: (context) => storageService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'God\'s Gaze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}