import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../widgets/selector_estrellas.dart';
import '../widgets/tarjeta_elemento.dart';

/// Cálculos de las estadísticas (R11), separados de la parte visual.
///
/// No pinta nada: solo recibe la lista y calcula. Así los cálculos se
/// pueden leer (y probar) sin pensar en widgets.
class Estadisticas {
  /// Lista sobre la que se calcula.
  final List<Elemento> elementos;

  const Estadisticas(this.elementos);

  /// Número total de elementos.
  int get total => elementos.length;

  /// Cuántos elementos hay en cada estado. Incluye los estados con 0.
  Map<Estado, int> get recuentoPorEstado => {
    for (final estado in Estado.values)
      estado: elementos.where((e) => e.estado == estado).length,
  };

  /// Cuántos elementos hay de cada tipo. Incluye los tipos con 0.
  Map<Tipo, int> get recuentoPorTipo => {
    for (final tipo in Tipo.values)
      tipo: elementos.where((e) => e.tipo == tipo).length,
  };

  /// Elementos con valoración (mayor que 0). Los «sin valorar» (0) no
  /// cuentan para la media: si contaran, bajarían la nota sin motivo.
  List<Elemento> get valorados =>
      elementos.where((e) => e.valoracion > 0).toList();

  /// Media de valoración de los elementos valorados.
  ///
  /// Devuelve `null` si no hay ninguno valorado: así **nunca se divide
  /// entre cero** y la pantalla puede mostrar «Sin valoraciones».
  double? get valoracionMedia {
    final lista = valorados;
    if (lista.isEmpty) return null; // protección contra la división entre 0

    final suma = lista.fold<int>(0, (acumulado, e) => acumulado + e.valoracion);
    return suma / lista.length;
  }

  /// Tipo o tipos que más se repiten.
  ///
  /// - Lista vacía → `[]` (no hay tipo más frecuente).
  /// - Un ganador → `[ese tipo]`.
  /// - Empate → todos los empatados, para no elegir uno al azar.
  List<Tipo> get tiposMasFrecuentes {
    if (elementos.isEmpty) return [];

    final recuento = recuentoPorTipo;
    // El mayor de los recuentos.
    final maximo = recuento.values.reduce((a, b) => a > b ? a : b);
    return [
      for (final entrada in recuento.entries)
        if (entrada.value == maximo) entrada.key,
    ];
  }
}

/// Pantalla de estadísticas de la watchlist (R11).
///
/// Es un [StatelessWidget]: recibe la lista y solo la muestra; no cambia
/// nada. Si la lista cambia, al volver a abrirla se recalcula todo.
class PantallaEstadisticas extends StatelessWidget {
  /// Lista completa de elementos (sin filtrar).
  final List<Elemento> elementos;

  const PantallaEstadisticas({super.key, required this.elementos});

  /// Texto de cada estado en esta pantalla. «En curso» agrupa películas,
  /// series y videojuegos, por eso se muestran las dos palabras.
  static String _textoEstado(Estado estado) {
    switch (estado) {
      case Estado.pendiente:
        return 'Pendiente';
      case Estado.enCurso:
        return 'Viendo / Jugando';
      case Estado.terminado:
        return 'Terminado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = Estadisticas(elementos);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: stats.total == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no hay elementos. Añade alguno para ver tus '
                  'estadísticas.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _tarjetaTotal(context, stats),
                _tarjetaPorEstado(context, stats),
                _tarjetaMedia(context, stats),
                _tarjetaTipoFrecuente(context, stats),
              ],
            ),
    );
  }

  /// Tarjeta con un título y un contenido. Da el mismo aspecto a todas.
  Widget _tarjeta(BuildContext context, String titulo, Widget contenido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            contenido,
          ],
        ),
      ),
    );
  }

  /// Número total de elementos, en grande.
  Widget _tarjetaTotal(BuildContext context, Estadisticas stats) {
    final tema = Theme.of(context);
    return _tarjeta(
      context,
      'Total',
      Text(
        '${stats.total} ${stats.total == 1 ? 'elemento' : 'elementos'}',
        style: tema.textTheme.headlineMedium?.copyWith(
          color: tema.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Una barra por estado, proporcional al total, con su número al lado.
  Widget _tarjetaPorEstado(BuildContext context, Estadisticas stats) {
    final recuento = stats.recuentoPorEstado;

    return _tarjeta(
      context,
      'Por estado',
      Column(
        children: [
          for (final estado in Estado.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 130, child: Text(_textoEstado(estado))),
                  Expanded(
                    child: LinearProgressIndicator(
                      // Proporción de 0 a 1. Aquí total > 0 siempre (la
                      // lista vacía tiene su propio mensaje), pero se
                      // protege igualmente la división.
                      value: stats.total == 0
                          ? 0
                          : recuento[estado]! / stats.total,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${recuento[estado]}',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Valoración media de los elementos valorados.
  Widget _tarjetaMedia(BuildContext context, Estadisticas stats) {
    final media = stats.valoracionMedia;
    final tema = Theme.of(context);

    if (media == null) {
      return _tarjeta(
        context,
        'Valoración media',
        const Text('Sin valoraciones todavía'),
      );
    }

    final cantidad = stats.valorados.length;
    return _tarjeta(
      context,
      'Valoración media',
      Row(
        children: [
          Text(
            media.toStringAsFixed(1),
            style: tema.textTheme.headlineMedium?.copyWith(
              color: tema.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estrellas redondeadas al entero más cercano.
              SelectorEstrellas(valor: media.round()),
              Text(
                'de $cantidad ${cantidad == 1 ? 'valorado' : 'valorados'}',
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tipo que más se repite (o los empatados).
  Widget _tarjetaTipoFrecuente(BuildContext context, Estadisticas stats) {
    final tipos = stats.tiposMasFrecuentes;
    final veces = stats.recuentoPorTipo[tipos.first]!;
    final nombres = tipos.map((t) => t.etiqueta).join(' y ');

    return _tarjeta(
      context,
      'Tipo más frecuente',
      Row(
        children: [
          for (final tipo in tipos)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(child: Icon(TarjetaElemento.iconoPara(tipo))),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              tipos.length == 1
                  ? '$nombres ($veces)'
                  : 'Empate: $nombres ($veces cada uno)',
            ),
          ),
        ],
      ),
    );
  }
}
