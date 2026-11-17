import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_watchlist/modelos/elemento.dart';
import 'package:mi_watchlist/pantallas/pantalla_detalle.dart';

/// Pruebas de la portada en [PantallaDetalle].
void main() {
  Future<void> abrirDetalle(WidgetTester tester, String titulo) {
    final elemento = Elemento(
      id: '1',
      titulo: titulo,
      tipo: Tipo.pelicula,
      fechaAlta: DateTime(2026, 11, 17),
    );
    return tester.pumpWidget(
      MaterialApp(home: PantallaDetalle(elemento: elemento)),
    );
  }

  testWidgets('muestra la portada si el título tiene una', (tester) async {
    await abrirDetalle(tester, 'Interstellar');

    final imagen = tester.widget<Image>(find.byType(Image));
    expect(
      (imagen.image as AssetImage).assetName,
      'assets/imagenes/interstellar.jpg',
    );
  });

  testWidgets('sin portada muestra el icono del tipo', (tester) async {
    await abrirDetalle(tester, 'Matrix');

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });
}
