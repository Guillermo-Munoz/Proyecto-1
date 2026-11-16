import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_watchlist/modelos/elemento.dart';

/// Pruebas **unitarias** del modelo [Elemento].
///
/// No se dibuja ningún widget: solo se crean objetos y se comprueban
/// sus valores. Por eso son rápidas y no necesitan `WidgetTester`.
void main() {
  /// Elemento de ejemplo con todos los campos rellenos.
  final completo = Elemento(
    id: '1700000000000000',
    titulo: 'Breaking Bad',
    tipo: Tipo.serie,
    estado: Estado.enCurso,
    valoracion: 4,
    notas: 'Voy por la temporada 3',
    fechaAlta: DateTime(2026, 11, 12, 18, 30, 15),
  );

  group('toJson / fromJson', () {
    test('fromJson(toJson(e)) devuelve los mismos datos', () {
      final copia = Elemento.fromJson(completo.toJson());

      // Campo a campo, para que si falla se vea cuál.
      expect(copia.id, completo.id);
      expect(copia.titulo, completo.titulo);
      expect(copia.tipo, completo.tipo);
      expect(copia.estado, completo.estado);
      expect(copia.valoracion, completo.valoracion);
      expect(copia.notas, completo.notas);
      expect(copia.fechaAlta, completo.fechaAlta);
      // Y el objeto entero (usa el operator == de Elemento).
      expect(copia, completo);
    });

    test('también funciona pasando por un String JSON (como en Almacen)', () {
      final texto = jsonEncode(completo.toJson());
      final copia = Elemento.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(copia, completo);
    });

    test('las notas null se conservan como null', () {
      final sinNotas = completo.copyWith(borrarNotas: true);
      final copia = Elemento.fromJson(sinNotas.toJson());

      expect(copia.notas, isNull);
      expect(copia, sinNotas);
    });

    test('los enum se guardan por su nombre', () {
      final json = completo.toJson();

      expect(json['tipo'], 'serie');
      expect(json['estado'], 'enCurso');
    });
  });

  group('copyWith', () {
    test('solo cambia el campo indicado', () {
      final cambiado = completo.copyWith(estado: Estado.terminado);

      // Lo que se pidió cambiar, cambia…
      expect(cambiado.estado, Estado.terminado);
      // …y todo lo demás sigue igual.
      expect(cambiado.id, completo.id);
      expect(cambiado.titulo, completo.titulo);
      expect(cambiado.tipo, completo.tipo);
      expect(cambiado.valoracion, completo.valoracion);
      expect(cambiado.notas, completo.notas);
      expect(cambiado.fechaAlta, completo.fechaAlta);
    });

    test('no modifica el objeto original (inmutabilidad)', () {
      completo.copyWith(titulo: 'Otro título', valoracion: 1);

      expect(completo.titulo, 'Breaking Bad');
      expect(completo.valoracion, 4);
    });

    test('sin parámetros devuelve una copia igual', () {
      expect(completo.copyWith(), completo);
    });

    test('borrarNotas pone las notas a null', () {
      expect(completo.copyWith(borrarNotas: true).notas, isNull);
    });
  });
}
