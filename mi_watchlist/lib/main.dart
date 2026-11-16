import 'package:flutter/material.dart';

import 'pantallas/pantalla_lista.dart';
import 'servicios/almacen.dart';

void main() {
  runApp(const MainApp());
}

/// Raíz de la aplicación: tema y pantalla inicial.
/// Es un [StatefulWidget] para permitir cambios dinámicos de tema (R15).
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /// `true` si el modo oscuro está activado.
  bool _oscuro = false;

  /// Servicio de almacenamiento para guardar la preferencia.
  final _almacen = const Almacen();

  /// Color del que se genera toda la paleta (R13).
  static const Color colorSemilla = Colors.indigo;

  @override
  void initState() {
    super.initState();
    // Cargar la preferencia de tema guardada al iniciar.
    _cargarTema();
  }

  /// Lee la preferencia de modo oscuro del dispositivo.
  Future<void> _cargarTema() async {
    final oscuro = await _almacen.cargarModoOscuro();
    if (mounted) {
      setState(() => _oscuro = oscuro);
    }
  }

  /// Cambia el modo oscuro y lo guarda.
  Future<void> _cambiarTema(bool oscuro) async {
    setState(() => _oscuro = oscuro);
    await _almacen.guardarModoOscuro(oscuro);
  }

  /// Tema propio aplicado a toda la app (R13, R15).
  ///
  /// `ColorScheme.fromSeed` calcula, a partir de un solo color, una paleta
  /// completa y coherente (primary, secondary, surface, error…). Los widgets
  /// la leen con `Theme.of(context).colorScheme`, así que si cambias la
  /// semilla, cambia el color de toda la app.
  ///
  /// Se genera para el modo claro y para el oscuro de forma independiente.
  static ThemeData construirTema({bool oscuro = false}) {
    final esquema = ColorScheme.fromSeed(
      seedColor: colorSemilla,
      brightness: oscuro ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: esquema,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primaryContainer,
        foregroundColor: esquema.onPrimaryContainer,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(elevation: 1),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Watchlist',
      debugShowCheckedModeBanner: false,
      theme: construirTema(oscuro: false),
      darkTheme: construirTema(oscuro: true),
      // Aplica el tema según la preferencia guardada.
      themeMode: _oscuro ? ThemeMode.dark : ThemeMode.light,
      home: PantallaLista(alCambiarTema: _cambiarTema),
    );
  }
}
