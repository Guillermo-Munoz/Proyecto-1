import 'package:flutter/foundation.dart';

/// Tipo de contenido de la watchlist.
enum Tipo {
  pelicula('Película'),
  serie('Serie'),
  videojuego('Videojuego');

  const Tipo(this.etiqueta);

  /// Texto que se muestra en pantalla.
  final String etiqueta;
}

/// Estado de progreso de un elemento.
enum Estado {
  pendiente,
  enCurso,
  terminado;

  /// Texto que se muestra en pantalla. «En curso» depende del tipo:
  /// para un videojuego es «Jugando» y para el resto «Viendo».
  String etiquetaPara(Tipo tipo) {
    switch (this) {
      case Estado.pendiente:
        return 'Pendiente';
      case Estado.enCurso:
        return tipo == Tipo.videojuego ? 'Jugando' : 'Viendo';
      case Estado.terminado:
        return 'Terminado';
    }
  }
}

/// Un elemento (película, serie o videojuego) de la watchlist.
///
/// Es inmutable: todos los campos son `final`. Para "modificarlo" se crea
/// una copia con [copyWith].
@immutable
class Elemento {
  static const int longitudMaximaTitulo = 60;
  static const int valoracionMaxima = 5;

  final String id;
  final String titulo;
  final Tipo tipo;
  final Estado estado;

  /// De 0 a 5. 0 significa «sin valorar».
  final int valoracion;

  /// Opcional.
  final String? notas;

  /// Fecha en la que se dio de alta el elemento.
  final DateTime fechaAlta;

  const Elemento({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.estado = Estado.pendiente,
    this.valoracion = 0,
    this.notas,
    required this.fechaAlta,
  }) : assert(valoracion >= 0 && valoracion <= valoracionMaxima);

  /// Crea un elemento nuevo: genera el [id], asigna [fechaAlta] a ahora,
  /// recorta el título y valida los datos.
  factory Elemento.nuevo({
    required String titulo,
    required Tipo tipo,
    Estado estado = Estado.pendiente,
    int valoracion = 0,
    String? notas,
  }) {
    final error = validarTitulo(titulo);
    if (error != null) throw ArgumentError.value(titulo, 'titulo', error);
    if (valoracion < 0 || valoracion > valoracionMaxima) {
      throw RangeError.range(valoracion, 0, valoracionMaxima, 'valoracion');
    }
    final ahora = DateTime.now();
    return Elemento(
      id: ahora.microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      tipo: tipo,
      estado: estado,
      valoracion: valoracion,
      notas: _limpiarNotas(notas),
      fechaAlta: ahora,
    );
  }

  /// Devuelve un mensaje de error, o `null` si el título es válido.
  /// Útil también como `validator` de un `TextFormField`.
  static String? validarTitulo(String? titulo) {
    final t = titulo?.trim() ?? '';
    if (t.isEmpty) return 'El título es obligatorio';
    if (t.length > longitudMaximaTitulo) {
      return 'El título no puede superar los $longitudMaximaTitulo '
          'caracteres (ahora tiene ${t.length})';
    }
    return null;
  }

  /// Convierte notas vacías o solo con espacios en `null`.
  static String? _limpiarNotas(String? notas) {
    final n = notas?.trim();
    return (n == null || n.isEmpty) ? null : n;
  }

  /// Devuelve una copia con los campos indicados cambiados.
  ///
  /// Como `notas` admite `null`, no basta con `notas ?? this.notas` para
  /// poder borrarlas: por eso existe [borrarNotas].
  Elemento copyWith({
    String? id,
    String? titulo,
    Tipo? tipo,
    Estado? estado,
    int? valoracion,
    String? notas,
    bool borrarNotas = false,
    DateTime? fechaAlta,
  }) {
    return Elemento(
      id: id ?? this.id,
      titulo: titulo?.trim() ?? this.titulo,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      valoracion: valoracion ?? this.valoracion,
      notas: borrarNotas
          ? null
          : (notas != null ? _limpiarNotas(notas) : this.notas),
      fechaAlta: fechaAlta ?? this.fechaAlta,
    );
  }

  /// Convierte el elemento a un mapa listo para `jsonEncode`.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'tipo': tipo.name, // enum -> String: "pelicula"
    'estado': estado.name, // enum -> String: "enCurso"
    'valoracion': valoracion,
    'notas': notas, // puede ser null
    'fechaAlta': fechaAlta.toIso8601String(),
  };

  /// Crea un elemento a partir de un mapa obtenido con `jsonDecode`.
  factory Elemento.fromJson(Map<String, dynamic> json) {
    return Elemento(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      tipo: Tipo.values.byName(json['tipo'] as String), // String -> enum
      estado: Estado.values.byName(json['estado'] as String),
      valoracion: ((json['valoracion'] as num?)?.toInt() ?? 0).clamp(
        0,
        valoracionMaxima,
      ),
      notas: json['notas'] as String?, // si falta la clave -> null
      fechaAlta: DateTime.parse(json['fechaAlta'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Elemento &&
          other.id == id &&
          other.titulo == titulo &&
          other.tipo == tipo &&
          other.estado == estado &&
          other.valoracion == valoracion &&
          other.notas == notas &&
          other.fechaAlta == fechaAlta;

  @override
  int get hashCode =>
      Object.hash(id, titulo, tipo, estado, valoracion, notas, fechaAlta);

  @override
  String toString() =>
      'Elemento(id: $id, titulo: $titulo, tipo: ${tipo.name}, '
      'estado: ${estado.name}, valoracion: $valoracion, notas: $notas, '
      'fechaAlta: $fechaAlta)';
}
