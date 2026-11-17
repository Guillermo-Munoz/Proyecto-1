import '../modelos/elemento.dart';

/// Decide qué portada (asset) le corresponde a un [Elemento].
///
/// Si el elemento trae su propia [Elemento.imagen], se usa esa. Si no, se
/// busca por el título en [_porTitulo]. Así los datos guardados antes de
/// que existiera el campo `imagen` también muestran su portada.
class Portadas {
  const Portadas._();

  static const String _carpeta = 'assets/imagenes';

  /// Portadas incluidas en la app, indexadas por título normalizado
  /// (ver [_normalizar]).
  static const Map<String, String> _porTitulo = {
    'interstellar': '$_carpeta/interstellar.jpg',
    'breaking bad': '$_carpeta/breaking_bad.jpg',
    'hollow knight': '$_carpeta/hollow_knight.jpg',
    'dune: parte dos': '$_carpeta/dune.jpg',
    'dune': '$_carpeta/dune.jpg',
  };

  /// Ruta del asset con la portada de [elemento], o `null` si no tiene.
  static String? para(Elemento elemento) =>
      elemento.imagen ?? _porTitulo[_normalizar(elemento.titulo)];

  /// Minúsculas, sin espacios al principio/final y con los espacios
  /// interiores reducidos a uno: «  Breaking   BAD » -> «breaking bad».
  static String _normalizar(String titulo) =>
      titulo.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
