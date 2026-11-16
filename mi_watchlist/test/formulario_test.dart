import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_watchlist/pantallas/pantalla_formulario.dart';

/// Pruebas **de widget** de [PantallaFormulario].
///
/// A diferencia de las unitarias, aquí se dibuja la pantalla en un
/// entorno de prueba y se simula al usuario (escribir, pulsar…) con
/// `WidgetTester`.
void main() {
  /// Monta el formulario dentro de un [MaterialApp], que es lo que
  /// necesitan sus widgets (tema, Navigator, textos de Material…).
  Future<void> abrirFormulario(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaFormulario()));
  }

  /// Pulsa el botón Guardar. Primero hace scroll hasta él por si queda
  /// fuera de la pantalla de prueba.
  Future<void> pulsarGuardar(WidgetTester tester) async {
    final boton = find.text('Guardar');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    // tap solo simula la pulsación: pump redibuja la pantalla para que
    // aparezcan los mensajes de error.
    await tester.pump();
  }

  group('Validación del título', () {
    testWidgets('con el título vacío muestra el mensaje de error', (
      tester,
    ) async {
      await abrirFormulario(tester);

      // Antes de pulsar no hay error.
      expect(find.text('El título es obligatorio'), findsNothing);

      await pulsarGuardar(tester);

      expect(find.text('El título es obligatorio'), findsOneWidget);
    });

    testWidgets('un título solo con espacios cuenta como vacío', (
      tester,
    ) async {
      await abrirFormulario(tester);

      // El primer TextFormField es el del título.
      await tester.enterText(find.byType(TextFormField).first, '    ');
      await pulsarGuardar(tester);

      expect(find.text('El título es obligatorio'), findsOneWidget);
    });

    testWidgets('con un título válido no muestra el error', (tester) async {
      await abrirFormulario(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Dune');
      await pulsarGuardar(tester);

      expect(find.text('El título es obligatorio'), findsNothing);
    });
  });
}
