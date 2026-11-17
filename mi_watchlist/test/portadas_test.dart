import 'package:flutter_test/flutter_test.dart';
import 'package:mi_watchlist/modelos/elemento.dart';
import 'package:mi_watchlist/pantallas/pantalla_lista.dart';
import 'package:mi_watchlist/servicios/portadas.dart';

/// Pruebas unitarias de [Portadas]: qué portada le toca a cada elemento.
void main() {
  Elemento elemento(String titulo, {String? imagen}) => Elemento(
    id: '1',
    titulo: titulo,
    tipo: Tipo.pelicula,
    fechaAlta: DateTime(2026, 11, 17),
    imagen: imagen,
  );

  test('enlaza cada dato de prueba con su imagen por el título', () {
    expect(
      Portadas.para(elemento('Interstellar')),
      'assets/imagenes/interstellar.jpg',
    );
    expect(
      Portadas.para(elemento('Breaking Bad')),
      'assets/imagenes/breaking_bad.jpg',
    );
    expect(
      Portadas.para(elemento('Hollow Knight')),
      'assets/imagenes/hollow_knight.jpg',
    );
    expect(
      Portadas.para(elemento('Dune: Parte dos')),
      'assets/imagenes/dune.jpg',
    );
  });

  test('ignora mayúsculas y espacios de sobra en el título', () {
    expect(
      Portadas.para(elemento('  breaking   BAD ')),
      'assets/imagenes/breaking_bad.jpg',
    );
  });

  test('un título sin portada conocida devuelve null', () {
    expect(Portadas.para(elemento('Matrix')), isNull);
  });

  test('si el elemento ya tiene imagen, se usa esa', () {
    expect(
      Portadas.para(elemento('Interstellar', imagen: 'assets/otra.jpg')),
      'assets/otra.jpg',
    );
  });

  test('todos los datos de prueba de la app tienen portada', () {
    for (final e in PantallaLista.elementosDePrueba()) {
      expect(Portadas.para(e), isNotNull, reason: e.titulo);
    }
  });
}
