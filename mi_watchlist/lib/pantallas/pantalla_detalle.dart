import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../widgets/selector_estrellas.dart';
import '../widgets/tarjeta_elemento.dart';
import 'pantalla_formulario.dart';

/// Lo que [PantallaDetalle] devuelve a la lista al cerrarse.
///
/// - `null` (no se devuelve nada): no hubo cambios.
/// - [borrado] = `false`: [elemento] es la versión editada.
/// - [borrado] = `true`: [elemento] se ha borrado.
@immutable
class ResultadoDetalle {
  final Elemento elemento;
  final bool borrado;

  const ResultadoDetalle.editado(this.elemento) : borrado = false;
  const ResultadoDetalle.borrado(this.elemento) : borrado = true;
}

/// Muestra todos los datos de un [Elemento] con botones para editarlo
/// y borrarlo (R5, R6, R7).
///
/// Es un [StatefulWidget] porque, tras editar, la pantalla sigue abierta
/// y tiene que mostrar los datos nuevos.
class PantallaDetalle extends StatefulWidget {
  /// Elemento con el que se abre la pantalla.
  final Elemento elemento;

  const PantallaDetalle({super.key, required this.elemento});

  @override
  State<PantallaDetalle> createState() => _PantallaDetalleState();
}

/// Estado de [PantallaDetalle]: guarda la versión actual del elemento.
class _PantallaDetalleState extends State<PantallaDetalle> {
  /// Versión actual del elemento. Cambia si se edita.
  late Elemento _elemento;

  /// `true` si se ha editado algo y hay que avisar a la lista al salir.
  bool _modificado = false;

  @override
  void initState() {
    super.initState();
    _elemento = widget.elemento;
  }

  /// Abre el formulario en modo edición y, si devuelve cambios,
  /// los muestra en esta misma pantalla.
  Future<void> _editar() async {
    final editado = await Navigator.push<Elemento>(
      context,
      MaterialPageRoute(builder: (_) => PantallaFormulario(inicial: _elemento)),
    );

    // null = se canceló: no se modifica nada (R6).
    if (editado == null || !mounted) return;
    setState(() {
      _elemento = editado;
      _modificado = true;
    });
  }

  /// Pide confirmación con un [AlertDialog] y, si se acepta, cierra la
  /// pantalla avisando a la lista de que hay que borrar el elemento (R7).
  Future<void> _borrar() async {
    // showDialog devuelve lo que se pase a Navigator.pop dentro del diálogo.
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('¿Borrar elemento?'),
        content: Text(
          'Se borrará «${_elemento.titulo}». Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contextoDialogo, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    // Si se pulsa fuera del diálogo, confirmado es null: tampoco se borra.
    if (confirmado != true || !mounted) return;
    Navigator.pop(context, ResultadoDetalle.borrado(_elemento));
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta la salida con la flecha de atrás (o el botón
    // atrás de Android). Si se editó algo, en vez de salir con null
    // salimos devolviendo el elemento editado para que la lista lo vea.
    return PopScope<ResultadoDetalle>(
      canPop: !_modificado,
      onPopInvokedWithResult: (yaSalio, resultado) {
        if (yaSalio) return;
        Navigator.pop(context, ResultadoDetalle.editado(_elemento));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle'),
          actions: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editar,
            ),
            IconButton(
              tooltip: 'Borrar',
              icon: const Icon(Icons.delete_outline),
              onPressed: _borrar,
            ),
          ],
        ),
        body: _construirDatos(),
      ),
    );
  }

  /// Cuerpo con todos los datos del elemento.
  Widget _construirDatos() {
    final tema = Theme.of(context);
    final notas = _elemento.notas;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            child: Icon(TarjetaElemento.iconoPara(_elemento.tipo), size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _elemento.titulo,
          style: tema.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _fila('Tipo', Text(_elemento.tipo.etiqueta)),
        _fila('Estado', Text(_elemento.estado.etiquetaPara(_elemento.tipo))),
        _fila(
          'Valoración',
          _elemento.valoracion == 0
              ? const Text('Sin valorar')
              : SelectorEstrellas(valor: _elemento.valoracion),
        ),
        _fila('Fecha de alta', Text(_formatearFecha(_elemento.fechaAlta))),
        const Divider(height: 32),
        Text('Notas', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          notas ?? 'Sin notas',
          style: notas == null
              ? tema.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)
              : tema.textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Una fila «etiqueta: valor».
  Widget _fila(String etiqueta, Widget valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: valor),
          ),
        ],
      ),
    );
  }

  /// Formatea una fecha como dd/mm/aaaa sin usar paquetes externos.
  static String _formatearFecha(DateTime f) {
    String dosCifras(int n) => n.toString().padLeft(2, '0');
    return '${dosCifras(f.day)}/${dosCifras(f.month)}/${f.year}';
  }
}
