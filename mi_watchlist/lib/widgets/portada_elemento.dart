import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../servicios/portadas.dart';
import 'tarjeta_elemento.dart';

/// Portada de un [Elemento] con el tamaño indicado.
///
/// Si el elemento no tiene portada (ver [Portadas.para]) o el asset no se
/// puede cargar, muestra un [CircleAvatar] con el icono de su [Tipo].
class PortadaElemento extends StatelessWidget {
  final Elemento elemento;
  final double ancho;
  final double alto;

  /// Radio de las esquinas de la imagen.
  final double radio;

  const PortadaElemento({
    super.key,
    required this.elemento,
    required this.ancho,
    required this.alto,
    this.radio = 6,
  });

  @override
  Widget build(BuildContext context) {
    // Círculo del ancho del lado menor; icono al 60 % (40 -> 24, el
    // tamaño por defecto de un CircleAvatar en la lista).
    final lado = ancho < alto ? ancho : alto;
    final icono = CircleAvatar(
      radius: lado / 2,
      child: Icon(TarjetaElemento.iconoPara(elemento.tipo), size: lado * 0.6),
    );

    final ruta = Portadas.para(elemento);
    if (ruta == null) return icono;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: Image.asset(
        ruta,
        width: ancho,
        height: alto,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => icono,
      ),
    );
  }
}
