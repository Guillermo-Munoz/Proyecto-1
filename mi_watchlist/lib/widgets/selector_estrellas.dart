import 'package:flutter/material.dart';

/// Muestra una valoración de 0 a 5 como una fila de 5 estrellas.
///
/// - Si [onChanged] es `null`, es de **solo lectura** (como en la lista).
/// - Si se pasa [onChanged], es **interactivo**: al pulsar una estrella
///   avisa del nuevo valor. Pulsar la estrella que ya marca el valor actual
///   lo pone a 0 («sin valorar»).
///
/// Es un [StatelessWidget]: no guarda el valor, lo recibe en [valor] y
/// comunica los cambios hacia fuera. Quien lo usa guarda el valor en su
/// estado y lo vuelve a pasar tras `setState`.
class SelectorEstrellas extends StatelessWidget {
  /// Número total de estrellas que se dibujan.
  static const int maximo = 5;

  /// Valoración a mostrar, de 0 a 5. 0 significa «sin valorar».
  final int valor;

  /// Tamaño de cada estrella.
  final double tamano;

  /// Se llama con el nuevo valor al pulsar una estrella.
  /// Si es `null`, el widget es de solo lectura.
  final ValueChanged<int>? onChanged;

  const SelectorEstrellas({
    super.key,
    required this.valor,
    this.tamano = 20,
    this.onChanged,
  }) : assert(valor >= 0 && valor <= maximo);

  /// Calcula el valor resultante de pulsar la estrella en la posición
  /// [posicion] (de 1 a 5).
  int _valorAlPulsar(int posicion) => posicion == valor ? 0 : posicion;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final interactivo = onChanged != null;

    final estrellas = List.generate(maximo, (i) {
      final posicion = i + 1;
      final icono = Icon(
        posicion <= valor ? Icons.star : Icons.star_border,
        size: tamano,
        color: color,
      );

      if (!interactivo) return icono;

      return IconButton(
        icon: icono,
        tooltip: '$posicion ${posicion == 1 ? 'estrella' : 'estrellas'}',
        onPressed: () => onChanged!(_valorAlPulsar(posicion)),
      );
    });

    final fila = Row(mainAxisSize: MainAxisSize.min, children: estrellas);

    // En modo lectura, el lector de pantalla lee una frase en lugar de
    // 5 iconos sueltos. En modo interactivo cada botón ya tiene su tooltip.
    if (interactivo) return fila;
    return Semantics(
      label: valor == 0 ? 'Sin valorar' : '$valor de $maximo estrellas',
      child: ExcludeSemantics(child: fila),
    );
  }
}
