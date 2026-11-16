import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import 'selector_estrellas.dart';

/// Tarjeta que resume un [Elemento] dentro de la lista.
///
/// Muestra un icono según el [Tipo], el título en negrita, el estado
/// legible y la valoración con [SelectorEstrellas]. Al pulsarla llama
/// a [onTap]; qué hacer (abrir el detalle, etc.) lo decide quien la usa.
class TarjetaElemento extends StatelessWidget {
  /// Elemento que se representa.
  final Elemento elemento;

  /// Se ejecuta al pulsar la tarjeta.
  final VoidCallback onTap;

  const TarjetaElemento({
    super.key,
    required this.elemento,
    required this.onTap,
  });

  /// Devuelve el icono que representa cada [Tipo].
  static IconData iconoPara(Tipo tipo) {
    switch (tipo) {
      case Tipo.pelicula:
        return Icons.movie_outlined;
      case Tipo.serie:
        return Icons.tv;
      case Tipo.videojuego:
        return Icons.sports_esports_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // Recorta el efecto de pulsación a los bordes redondeados de la Card.
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(iconoPara(elemento.tipo))),
        title: Text(
          elemento.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${elemento.tipo.etiqueta} · '
          '${elemento.estado.etiquetaPara(elemento.tipo)}',
          style: tema.textTheme.bodySmall,
        ),
        trailing: SelectorEstrellas(valor: elemento.valoracion, tamano: 18),
      ),
    );
  }
}
