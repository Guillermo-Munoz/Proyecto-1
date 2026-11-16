import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/elemento.dart';

/// Guarda y recupera la watchlist en el dispositivo con
/// `shared_preferences` (R10).
///
/// Toda la lista se guarda como **un único `String` JSON** bajo la clave
/// [clave]. Las pantallas no saben nada de JSON ni de `SharedPreferences`:
/// solo llaman a [cargar] y [guardar].
class Almacen {
  /// Clave con la que se guarda la lista.
  static const String clave = 'watchlist';

  /// Clave con la que se guarda la preferencia de modo oscuro.
  static const String claveModoOscuro = 'modoOscuro';

  const Almacen();

  /// Lee la lista guardada.
  ///
  /// Devuelve una lista vacía si no hay nada guardado todavía (primer
  /// arranque) o si el JSON está dañado: la app nunca debe romperse
  /// por culpa de datos corruptos.
  Future<List<Elemento>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(clave);

    // Primer arranque: aún no se ha guardado nada.
    if (texto == null) return [];

    try {
      // String JSON -> List<dynamic> de mapas.
      final lista = jsonDecode(texto) as List<dynamic>;
      // Cada mapa -> Elemento.
      return lista
          .map((mapa) => Elemento.fromJson(mapa as Map<String, dynamic>))
          .toList();
    } catch (error) {
      // Cubre JSON mal formado (FormatException), estructura inesperada
      // (TypeError en los `as`) o un enum desconocido (ArgumentError).
      debugPrint('Almacen: datos dañados, se arranca vacío. $error');
      return [];
    }
  }

  /// Guarda la lista completa, sustituyendo lo que hubiera.
  Future<void> guardar(List<Elemento> elementos) async {
    final prefs = await SharedPreferences.getInstance();
    // List<Elemento> -> List<Map> -> String JSON.
    final texto = jsonEncode(elementos.map((e) => e.toJson()).toList());
    await prefs.setString(clave, texto);
  }

  /// Lee la preferencia de modo oscuro guardada.
  ///
  /// Devuelve `false` (modo claro) si no hay nada guardado todavía.
  Future<bool> cargarModoOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveModoOscuro) ?? false;
  }

  /// Guarda la preferencia de modo oscuro.
  Future<void> guardarModoOscuro(bool oscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveModoOscuro, oscuro);
  }
}
