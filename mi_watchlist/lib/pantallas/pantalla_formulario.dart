import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../widgets/selector_estrellas.dart';

/// Pantalla para dar de alta un nuevo [Elemento] o editar uno existente.
///
/// - Si [inicial] es `null`: modo **alta**. Al guardar crea un elemento nuevo.
/// - Si [inicial] tiene valor: modo **edición**. Los campos aparecen
///   rellenos y al guardar se devuelve una copia con `copyWith`, que
///   conserva el `id` y la `fechaAlta`.
///
/// En ambos casos el resultado se devuelve con `Navigator.pop(context, x)`.
/// Si el usuario cancela o vuelve atrás, la pantalla anterior recibe `null`
/// y no se modifica nada (R6).
class PantallaFormulario extends StatefulWidget {
  /// Elemento a editar, o `null` para crear uno nuevo.
  final Elemento? inicial;

  const PantallaFormulario({super.key, this.inicial});

  @override
  State<PantallaFormulario> createState() => _PantallaFormularioState();
}

/// Estado de [PantallaFormulario]: guarda lo que el usuario va rellenando.
class _PantallaFormularioState extends State<PantallaFormulario> {
  /// Clave para acceder al [FormState] y validar todos los campos a la vez.
  final _formKey = GlobalKey<FormState>();

  /// Controladores de los campos de texto.
  late final TextEditingController _tituloController;
  late final TextEditingController _notasController;

  /// Valores elegidos en los desplegables y en las estrellas.
  late Tipo _tipo;
  late Estado _estado;
  late int _valoracion;

  /// `true` si estamos editando un elemento existente.
  bool get _editando => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    // Si hay elemento inicial, los campos arrancan con sus datos.
    final inicial = widget.inicial;
    _tituloController = TextEditingController(text: inicial?.titulo ?? '');
    _notasController = TextEditingController(text: inicial?.notas ?? '');
    _tipo = inicial?.tipo ?? Tipo.pelicula;
    _estado = inicial?.estado ?? Estado.pendiente;
    _valoracion = inicial?.valoracion ?? 0;
  }

  @override
  void dispose() {
    // Los controladores reservan recursos: hay que liberarlos al cerrar.
    _tituloController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  /// Valida el formulario y, si todo es correcto, devuelve el elemento
  /// (nuevo o editado) a la pantalla anterior.
  void _guardar() {
    // validate() ejecuta el validator de cada campo y muestra los errores.
    if (!_formKey.currentState!.validate()) return;

    final inicial = widget.inicial;
    final Elemento resultado;

    if (inicial == null) {
      // Alta: Elemento.nuevo genera el id y asigna fechaAlta = ahora.
      resultado = Elemento.nuevo(
        titulo: _tituloController.text,
        tipo: _tipo,
        estado: _estado,
        valoracion: _valoracion,
        notas: _notasController.text,
      );
    } else {
      // Edición: copyWith conserva id y fechaAlta y cambia el resto.
      // Unas notas vacías se convierten en null dentro de copyWith.
      resultado = inicial.copyWith(
        titulo: _tituloController.text,
        tipo: _tipo,
        estado: _estado,
        valoracion: _valoracion,
        notas: _notasController.text,
      );
    }

    Navigator.pop(context, resultado);
  }

  /// Cierra sin devolver nada: la pantalla anterior recibe `null`.
  void _cancelar() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar elemento' : 'Nuevo elemento'),
      ),
      body: Form(
        key: _formKey,
        // Tras el primer intento de guardar, revalida mientras se escribe.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _campoTitulo(),
            const SizedBox(height: 16),
            _desplegableTipo(),
            const SizedBox(height: 16),
            _desplegableEstado(),
            const SizedBox(height: 24),
            _selectorValoracion(),
            const SizedBox(height: 24),
            _campoNotas(),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(_editando ? 'Guardar cambios' : 'Guardar'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _cancelar, child: const Text('Cancelar')),
          ],
        ),
      ),
    );
  }

  /// Campo obligatorio para el título (1 a 60 caracteres sin contar
  /// espacios iniciales ni finales).
  Widget _campoTitulo() {
    return TextFormField(
      controller: _tituloController,
      decoration: const InputDecoration(
        labelText: 'Título *',
        // Avisa del límite antes de que aparezca el error.
        helperText:
            'Obligatorio. Máximo ${Elemento.longitudMaximaTitulo} '
            'caracteres',
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      // La regla vive en el modelo para no repetirla en varios sitios.
      validator: Elemento.validarTitulo,
    );
  }

  /// Desplegable para elegir el [Tipo].
  Widget _desplegableTipo() {
    return DropdownButtonFormField<Tipo>(
      initialValue: _tipo,
      decoration: const InputDecoration(
        labelText: 'Tipo',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final tipo in Tipo.values)
          DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
      ],
      // setState para que el desplegable de estado cambie
      // «Viendo» por «Jugando» al elegir videojuego.
      onChanged: (nuevo) => setState(() => _tipo = nuevo!),
    );
  }

  /// Desplegable para elegir el [Estado]. Su texto depende del tipo.
  Widget _desplegableEstado() {
    return DropdownButtonFormField<Estado>(
      initialValue: _estado,
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final estado in Estado.values)
          DropdownMenuItem(
            value: estado,
            child: Text(estado.etiquetaPara(_tipo)),
          ),
      ],
      onChanged: (nuevo) => setState(() => _estado = nuevo!),
    );
  }

  /// Estrellas interactivas: cada pulsación actualiza [_valoracion].
  Widget _selectorValoracion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _valoracion == 0 ? 'Valoración: sin valorar' : 'Valoración',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        SelectorEstrellas(
          valor: _valoracion,
          tamano: 32,
          onChanged: (nuevo) => setState(() => _valoracion = nuevo),
        ),
      ],
    );
  }

  /// Campo opcional para notas. Si se deja vacío se guarda como `null`.
  Widget _campoNotas() {
    return TextFormField(
      controller: _notasController,
      decoration: const InputDecoration(
        labelText: 'Notas (opcional)',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      minLines: 3,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
