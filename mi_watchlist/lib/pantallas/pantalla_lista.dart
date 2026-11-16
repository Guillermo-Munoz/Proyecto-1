import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../servicios/almacen.dart';
import '../widgets/tarjeta_elemento.dart';
import 'pantalla_detalle.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_formulario.dart';

/// Pantalla principal: muestra la lista de elementos de la watchlist.
///
/// Es un [StatefulWidget] porque la lista puede cambiar mientras la
/// pantalla está abierta, y cada cambio se pinta con `setState`.
/// Al arrancar carga los datos guardados y, tras cada cambio, los guarda.
class PantallaLista extends StatefulWidget {
  /// Servicio de persistencia. Se puede sustituir en los tests.
  final Almacen almacen;

  /// Callback que se ejecuta al cambiar de modo oscuro/claro.
  /// Recibe `true` para modo oscuro, `false` para modo claro.
  final Future<void> Function(bool)? alCambiarTema;

  const PantallaLista({
    super.key,
    this.almacen = const Almacen(),
    this.alCambiarTema,
  });

  /// Datos de ejemplo para el botón «Cargar ejemplos» del estado vacío.
  static List<Elemento> elementosDePrueba() => [
    Elemento.nuevo(
      titulo: 'Interstellar',
      tipo: Tipo.pelicula,
      estado: Estado.terminado,
      valoracion: 5,
    ),
    Elemento.nuevo(
      titulo: 'Breaking Bad',
      tipo: Tipo.serie,
      estado: Estado.enCurso,
      valoracion: 4,
      notas: 'Voy por la temporada 3',
    ),
    Elemento.nuevo(
      titulo: 'Hollow Knight',
      tipo: Tipo.videojuego,
      estado: Estado.enCurso,
      valoracion: 3,
    ),
    Elemento.nuevo(titulo: 'Dune: Parte dos', tipo: Tipo.pelicula),
  ];

  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

/// Criterio de ordenamiento de la lista.
enum _OrdenPor { defecto, titulo, valoracion, fechaReciente }

/// Estado de [PantallaLista]: guarda la lista completa de elementos y
/// los criterios de filtro y búsqueda.
class _PantallaListaState extends State<PantallaLista> {
  /// Lista **completa**. El filtro y la búsqueda nunca la modifican:
  /// solo cambia al añadir, editar o borrar (siempre con [_actualizarLista]).
  List<Elemento> _elementos = [];

  /// `true` mientras se leen los datos guardados al arrancar.
  bool _cargando = true;

  /// Estado por el que se filtra. `null` significa «Todos».
  Estado? _filtroEstado;

  /// Texto de búsqueda actual.
  String _busqueda = '';

  /// Criterio de ordenamiento actual.
  _OrdenPor _ordenPor = _OrdenPor.defecto;

  /// Controlador del campo de búsqueda (para poder vaciarlo con la X).
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initState no puede ser async, así que lanzamos la carga en un
    // método aparte. Mientras tanto, build muestra el indicador de carga.
    _cargarDatos();
  }

  /// Lee los datos guardados y, al terminar, quita el indicador de carga.
  Future<void> _cargarDatos() async {
    final datos = await widget.almacen.cargar();
    // Tras un await la pantalla podría haberse cerrado.
    if (!mounted) return;
    setState(() {
      _elementos = datos;
      _cargando = false;
    });
  }

  /// Único punto por el que cambia la lista completa: actualiza la
  /// pantalla con `setState` y guarda en el dispositivo.
  ///
  /// Centralizarlo aquí evita olvidar el guardado en algún caso
  /// (alta, edición, borrado, ejemplos, vaciar).
  Future<void> _actualizarLista(List<Elemento> nueva) async {
    setState(() => _elementos = nueva);
    try {
      await widget.almacen.guardar(nueva);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se han podido guardar los cambios')),
      );
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  /// Lista que se **muestra**: se calcula a partir de [_elementos]
  /// aplicando a la vez el filtro de estado y la búsqueda (R8 + R9).
  ///
  /// `where` no modifica [_elementos]: crea una lista nueva con los que
  /// cumplen la condición, así que filtrar nunca borra nada.
  List<Elemento> get _visibles {
    final texto = _busqueda.trim().toLowerCase();

    return _elementos.where((e) {
      final cumpleEstado = _filtroEstado == null || e.estado == _filtroEstado;
      final cumpleBusqueda =
          texto.isEmpty || e.titulo.toLowerCase().contains(texto);
      // Las dos condiciones a la vez: por eso funcionan juntas.
      return cumpleEstado && cumpleBusqueda;
    }).toList();
  }

  /// Ordena una copia de la lista según el criterio actual sin modificar la original.
  List<Elemento> _aplicarOrdenamiento(List<Elemento> lista) {
    // Copia para no modificar la lista que recibimos.
    final copia = [...lista];

    switch (_ordenPor) {
      case _OrdenPor.titulo:
        // Alfabético (A-Z)
        copia.sort((a, b) => a.titulo.compareTo(b.titulo));

      case _OrdenPor.valoracion:
        // De mayor a menor valoración (5 estrellas primero)
        copia.sort((a, b) {
          // Si ambas tienen valoración, compara de mayor a menor.
          if (a.valoracion > 0 && b.valoracion > 0) {
            return b.valoracion.compareTo(a.valoracion);
          }
          // Si solo una tiene valoración, va primero.
          if (a.valoracion > 0) return -1;
          if (b.valoracion > 0) return 1;
          // Si ninguna tiene, mantén el orden relativo.
          return 0;
        });

      case _OrdenPor.fechaReciente:
        // Más reciente primero
        copia.sort((a, b) => b.fechaAlta.compareTo(a.fechaAlta));

      case _OrdenPor.defecto:
        // Por defecto, más reciente primero.
        copia.sort((a, b) => b.fechaAlta.compareTo(a.fechaAlta));
    }

    return copia;
  }

  /// Cambia el filtro de estado (`null` = Todos).
  void _cambiarFiltro(Estado? estado) {
    setState(() => _filtroEstado = estado);
  }

  /// Guarda el texto de búsqueda cada vez que el usuario escribe.
  void _cambiarBusqueda(String texto) {
    setState(() => _busqueda = texto);
  }

  /// Cambia el criterio de ordenamiento y redibuja la lista.
  void _cambiarOrden(_OrdenPor orden) {
    setState(() => _ordenPor = orden);
  }

  /// Alterna entre modo oscuro y claro.
  Future<void> _alternarTema() async {
    final oscuroAhora = Theme.of(context).brightness == Brightness.dark;
    // Llama al callback solo si está disponible.
    await widget.alCambiarTema?.call(!oscuroAhora);
  }

  /// Quita filtro y búsqueda (botón de «sin resultados»).
  void _limpiarFiltros() {
    _busquedaController.clear();
    setState(() {
      _filtroEstado = null;
      _busqueda = '';
    });
  }

  /// Rellena la lista con los datos de prueba (botón del estado vacío).
  void _cargarEjemplos() {
    _actualizarLista(PantallaLista.elementosDePrueba());
  }

  /// Abre [PantallaFormulario] y, si devuelve un elemento, lo añade
  /// al principio de la lista.
  Future<void> _abrirFormulario() async {
    // push devuelve un Future que se completa con lo que se pase a pop.
    final nuevo = await Navigator.push<Elemento>(
      context,
      MaterialPageRoute(builder: (_) => const PantallaFormulario()),
    );

    // null = el usuario volvió atrás sin guardar.
    // mounted = la pantalla sigue existiendo tras el await.
    if (nuevo == null || !mounted) return;
    _actualizarLista([nuevo, ..._elementos]);
  }

  /// Abre [PantallaDetalle] y aplica lo que devuelva:
  /// - `null`: no hubo cambios.
  /// - editado: reemplaza el elemento con el mismo `id`.
  /// - borrado: lo quita de la lista y muestra un [SnackBar].
  Future<void> _abrirElemento(Elemento elemento) async {
    final resultado = await Navigator.push<ResultadoDetalle>(
      context,
      MaterialPageRoute(builder: (_) => PantallaDetalle(elemento: elemento)),
    );

    if (resultado == null || !mounted) return;
    final afectado = resultado.elemento;

    if (resultado.borrado) {
      _actualizarLista(_elementos.where((e) => e.id != afectado.id).toList());
      // El SnackBar se muestra aquí porque la pantalla de detalle ya se cerró.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('«${afectado.titulo}» se ha borrado')),
        );
    } else {
      // Se busca por id porque el objeto editado es otro (inmutable):
      // comparar con == no lo encontraría si cambió algún campo.
      _actualizarLista([
        for (final e in _elementos) e.id == afectado.id ? afectado : e,
      ]);
    }
  }

  /// Abre [PantallaEstadisticas] con la lista **completa** (no la filtrada).
  /// No espera resultado: es una pantalla de solo lectura.
  void _abrirEstadisticas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaEstadisticas(elementos: _elementos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Watchlist'),
        actions: [
          /// Menú de ordenamiento con opciones de criterios distintos.
          PopupMenuButton<_OrdenPor>(
            tooltip: 'Ordenar por',
            icon: const Icon(Icons.sort),
            // Desactivado mientras carga.
            enabled: !_cargando,
            onSelected: _cambiarOrden,
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: _ordenPor == _OrdenPor.defecto,
                value: _OrdenPor.defecto,
                child: const Text('Por defecto (más reciente)'),
              ),
              CheckedPopupMenuItem(
                checked: _ordenPor == _OrdenPor.titulo,
                value: _OrdenPor.titulo,
                child: const Text('Título (A-Z)'),
              ),
              CheckedPopupMenuItem(
                checked: _ordenPor == _OrdenPor.valoracion,
                value: _OrdenPor.valoracion,
                child: const Text('Valoración (★★★★★ primero)'),
              ),
              CheckedPopupMenuItem(
                checked: _ordenPor == _OrdenPor.fechaReciente,
                value: _OrdenPor.fechaReciente,
                child: const Text('Más reciente'),
              ),
            ],
          ),

          /// Alternar entre modo oscuro y claro (R15).
          IconButton(
            tooltip: 'Cambiar tema',
            icon: Theme.of(context).brightness == Brightness.dark
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            onPressed: _cargando ? null : _alternarTema,
          ),
          IconButton(
            tooltip: 'Estadísticas',
            icon: const Icon(Icons.bar_chart),
            // Desactivado mientras se cargan los datos.
            onPressed: _cargando ? null : _abrirEstadisticas,
          ),
        ],
      ),
      body: _construirCuerpo(),
      // Sin botón de añadir mientras carga: aún no sabemos qué hay guardado.
      floatingActionButton: _cargando
          ? null
          : FloatingActionButton(
              tooltip: 'Añadir elemento',
              onPressed: _abrirFormulario,
              child: const Icon(Icons.add),
            ),
    );
  }

  /// Elige qué mostrar según la situación:
  /// 1. Cargando datos → indicador de carga.
  /// 2. Lista vacía de verdad → estado vacío.
  /// 3. Hay elementos → buscador, filtros y lista filtrada.
  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_elementos.isEmpty) return _construirVacio();
    return Column(
      children: [
        _construirBuscador(),
        _construirFiltros(),
        Expanded(child: _construirLista()),
      ],
    );
  }

  /// Campo de búsqueda por título (R9).
  Widget _construirBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _busquedaController,
        onChanged: _cambiarBusqueda,
        decoration: InputDecoration(
          hintText: 'Buscar por título',
          prefixIcon: const Icon(Icons.search),
          // La X solo aparece si hay algo escrito.
          suffixIcon: _busqueda.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Borrar búsqueda',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _busquedaController.clear();
                    _cambiarBusqueda('');
                  },
                ),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  /// Fila de [ChoiceChip] para filtrar por estado (R8).
  Widget _construirFiltros() {
    // Opciones: null = Todos, y luego cada Estado con su texto.
    const opciones = <Estado?, String>{
      null: 'Todos',
      Estado.pendiente: 'Pendiente',
      Estado.enCurso: 'Viendo',
      Estado.terminado: 'Terminado',
    };

    return SingleChildScrollView(
      // Scroll horizontal por si la pantalla es estrecha.
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          for (final opcion in opciones.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(opcion.value),
                selected: _filtroEstado == opcion.key,
                onSelected: (_) => _cambiarFiltro(opcion.key),
              ),
            ),
        ],
      ),
    );
  }

  /// Lista de tarjetas filtrada y ordenada. `ListView.builder` solo construye las
  /// visibles en pantalla.
  Widget _construirLista() {
    // Se filtra primero, luego se ordena, sin modificar la lista completa.
    final visibles = _aplicarOrdenamiento(_visibles);

    if (visibles.isEmpty) return _construirSinResultados();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 88), // 88: hueco del FAB
      itemCount: visibles.length,
      itemBuilder: (context, indice) {
        final elemento = visibles[indice];
        return TarjetaElemento(
          // La key ayuda a Flutter a no confundir tarjetas si la lista cambia.
          key: ValueKey(elemento.id),
          elemento: elemento,
          onTap: () => _abrirElemento(elemento),
        );
      },
    );
  }

  /// Se muestra cuando hay elementos, pero ninguno cumple el filtro o la
  /// búsqueda. Es distinto del estado vacío: aquí no falta nada.
  Widget _construirSinResultados() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Ningún elemento coincide con el filtro o la búsqueda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _limpiarFiltros,
              child: const Text('Quitar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mensaje amable que se muestra cuando no hay ningún elemento.
  Widget _construirVacio() {
    final tema = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add, size: 72, color: tema.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Tu watchlist está vacía',
              style: tema.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Añade películas, series o videojuegos para no olvidar '
              'qué quieres ver o jugar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _abrirFormulario,
              icon: const Icon(Icons.add),
              label: const Text('Añadir el primero'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _cargarEjemplos,
              child: const Text('Cargar ejemplos'),
            ),
          ],
        ),
      ),
    );
  }
}
