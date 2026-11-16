## Fase 1 · Modelo de datos

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
1. Escribe en Dart una clase inmutable `Elemento` con estos campos, esta es la tabla : Clase `Elemento` con:

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | `String` | Único. Puede generarse con `DateTime.now().microsecondsSinceEpoch.toString()` |
| `titulo` | `String` | Obligatorio, entre 1 y 60 caracteres sin contar espacios iniciales o finales |
| `tipo` | `enum Tipo { pelicula, serie, videojuego }` | |
| `estado` | `enum Estado { pendiente, enCurso, terminado }` | En pantalla: Pendiente, Viendo/Jugando, Terminado |
| `valoracion` | `int` | De 0 a 5. 0 significa «sin valorar» |
| `notas` | `String?` | Opcional |
| `fechaAlta` | `DateTime` | Se asigna al crear |

Debe tener los métodos `toJson()`, `fromJson()` y `copyWith()`.. Añade `toJson`, `fromJson` y `copyWith`. 
Explica qué es `copyWith` y por qué lo necesito si los campos son `final`.
¿Cómo se guarda un `enum` en JSON y cómo se recupera?
¿Qué pasaría en `fromJson` si el JSON no trae el campo `notas`?


**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: ...

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):

He aprendido a  guardad enum en Json y por que no es recomendable usar un index numerico, si algun dia se añaden valores en el enum los datos que estaban guardados pasaran a ser otra cosa.

**Preguntas de comprensión** (respondidas sin IA):
1. Los campos son finales para evitar que se cambien despues de crear el objeto. Para cambiar un campo final usamos copyWrith, que crea una copia con los campos a modificafr distintos. EJ: final actualizado = elemento.copyWith(estado: Estado.terminado, valoracion: 4);
2. JSON no tiene enum pero se guarda com texto usando su nombre
3. Si la clave existe devuelve null, es valido porque el tipo admite null.

## Fase 2 · Lista y tarjeta (R1, R2, R12 parcial)

**Herramienta usada:** (ChatGPT, Claude, Gemini, Copilot, ninguna…)

**Prompts principales** (cópialos tal cual):
1. Estoy desarrollando una app en Flutter (nivel educativo) siguiendo una arquitectura modular estricta. Necesito implementar la Fase 2 de mi proyecto "Mi Watchlist".

CONTEXTO ACTUAL:
- Tengo una clase modelo `Elemento` (con id, titulo, tipo, estado, valoracion, notas, fechaAlta) y los enums `Tipo` (pelicula, serie, videojuego) y `Estado` (pendiente, enCurso, terminado).
- Estoy trabajando únicamente con StatefulWidget y setState, sin paquetes externos de gestión de estado.

OBJETIVO DE ESTA PETICIÓN:
1. Crear el widget reutilizable `SelectorEstrellas` en `lib/widgets/selector_estrellas.dart`:
   - Debe recibir un parámetro `int valor` (de 0 a 5) y ser de solo lectura por ahora.
   - Debe pintar 5 iconos de estrella (llenas o vacías según el valor).
2. Crear el widget reutilizable `TarjetaElemento` en `lib/widgets/tarjeta_elemento.dart`:
   - Debe recibir un objeto `Elemento` y un callback `VoidCallback onTap`.
   - Debe mostrar un icono representativo según el `Tipo`, el `titulo` en negrita, el `estado` formateado para pantalla y el `SelectorEstrellas`.
3. Implementar `PantallaLista` en `lib/pantallas/pantalla_lista.dart`:
   - Debe recibir o inicializar una lista temporal de elementos de prueba.
   - Si la lista está vacía, debe mostrar un "estado vacío" (mensaje amable + botón).
   - Si tiene elementos, debe renderizarlos usando `ListView.builder` y aplicando `TarjetaElemento`.

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos (nada de provider, flutter_slidable, etc.).
- Comenta adecuadamente cada clase y método principal con comentarios explicativos (`///`).
- Separa cada componente exactamente en el archivo y ruta indicados.

Por favor, proporcióname el código limpio de estos tres archivos y explícame brevemente por qué usamos `ListView.builder` en lugar de un `ListView` normal.

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios:

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):

He aprendido que con ListView.builder crea solo las tarjtas que se van a mostrar en pantalla sin necesidad de crear todas de golpe perjudicando el rendimiento de la app

**Preguntas de comprensión** (respondidas sin IA):
1. ¿Qué diferencia hay entre `ListView` y `ListView.builder`? ¿Cuándo conviene cada uno?

La diferencia es que sin el builder creamos todos los elementos de golpe, eso puede servir para un elemento con pocos hijos que no proviene de de datos, com oun menu

2. ¿Por qué `TarjetaElemento` recibe una función en lugar de navegar ella misma?

Se vuelve reutilizable, asi la pantalla que lo usa decide que pasara al pulsarla

3. ¿`TarjetaElemento` es `StatelessWidget` o `StatefulWidget`? ¿Por qué?

TarjetaElemento es un StatelessWidget porque solo representa visualmente un Elemento que recibe ya creado: pinta el icono, el título, el estado y las estrellas, sin almacenar estado interno ni modificar datos. Todos sus campos son final y le llegan por el constructor. Cualquier acción sobre ella (como tocarla) se delega hacia fuera mediante el callback onTap.

Si el elemento cambia, la tarjeta no se modifica a sí misma: PantallaLista, que es quien guarda la lista, llama a setState y Flutter vuelve a construir una tarjeta nueva con el Elemento actualizado. Solo tendría sentido que fuera StatefulWidget si necesitara un estado visual propio que no afecta al resto de la app, como un panel desplegable al tocarla.

## Fase 3 · Formulario de alta (R3, R4)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
1. 
Estoy desarrollando una app en Flutter (nivel educativo) siguiendo una arquitectura modular estricta. Necesito implementar la Fase 3 de mi proyecto "Mi Watchlist".

CONTEXTO ACTUAL:
- Tengo una clase modelo `Elemento` (con id, titulo, tipo, estado, valoracion, notas, fechaAlta) y los enums `Tipo` (pelicula, serie, videojuego) y `Estado` (pendiente, enCurso, terminado).
- Estoy trabajando únicamente con StatefulWidget y setState, sin paquetes externos de gestión de estado.

OBJETIVO DE ESTA PETICIÓN:
Implementar la `PantallaFormulario` en `lib/pantallas/pantalla_formulario.dart`:
1. Utilizar un widget `Form` con una `GlobalKey<FormState>` para gestionar la validación.
2. Añadir un `TextEditingController` para el campo `titulo`: el campo debe ser obligatorio y validar que no esté vacío ni contenga solo espacios en blanco.
3. Añadir desplegables (`DropdownButtonFormField`) para seleccionar el `Tipo` y el `Estado`.
4. Integrar el componente `SelectorEstrellas` haciéndolo **interactivo** mediante un callback `onChanged` para actualizar la valoración en el estado local.
5. Añadir un campo de texto opcional para las `notas`.
6. Al pulsar el botón "Guardar": validar el formulario, instanciar un nuevo objeto `Elemento` (generando su `id` con milisegundos y la `fechaAlta` actual) y devolverlo usando `Navigator.pop(context, elementoNuevo)`.

2.Explicame: Explica el viaje del dato: desde que pulsas Guardar hasta que aparece en la lista. no lo entiendo, pero no me lo des mascado, dame la explicacion como senior

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos (nada de provider, flutter_slidable, etc.).
- Comenta adecuadamente cada clase y método principal con comentarios explicativos (`///`).
- Separa cada componente exactamente en el archivo y ruta indicados.


**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: 

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- Detecte que la ia decidio usar para el id microsegundos en vez de miliseguncdos porque en la peticion dice milisegundos pero en la Fase 1 dice microsegundos, aumio que es menos problable una colision

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):

Aprendi que con Form: la GlobalKey<FormState> revisa todos los campos a la vez antes de guardar. Cada validator devuelve null si el campo está bien o un texto con el error.
TextEditingController lee lo que escribe el usuario y hay que liberarlo en dispose().
SelectorEstrellas pasa a ser interactivo con onChanged. No guarda la valoración: avisa al formulario y es el formulario quien hace setState.

**Preguntas de comprensión** (respondidas sin IA):
1. ¿Qué hace `_formKey.currentState!.validate()` y qué significa el `!`?

Recorre todos los campos del formulario asociados a esa clave y ejecuta sus validaciones individuales (comprobando si cumplen las reglas, como que el título no esté vacío). Si todo es correcto, devuelve true; si hay errores, los muestra en pantalla y devuelve false.

El ! (operador de aserción de no nulidad): Le indica a Dart que estamos seguros de que _formKey.currentState no es null en ese instante, forzándolo a tratarlo como un objeto válido para poder invocar el método validate(). 

2. ¿Por qué hay que llamar a `dispose()` de los controladores?

Para liberar los recursos que reservan los controladores. Flutter llama a dispose() cuando se cierra la pantalla del formulario; si no los liberáramos, se quedarían ocupando memoria cada vez que se abre y cierra el formulario (fuga de memoria).

3. Explica el viaje del dato: desde que pulsas Guardar hasta que aparece en la lista.

 Al pulsar el botn + la lista ejecuta _abrirFormnulario, que abre formulario con awai Navigator,push<Element>(...). Este metodo queda en pausa esperando al formulario.
 Al pulsar guardar se jecuta _guardad. Primero se llama a `_formKey.currentState!.validate()`, que ejecuta el validator de cada campo. Si alguno no es valido agrega los mensajes de error bajo lso campor y return sale sin crear nada.
 Si todo sale bien se crea el elemento, usando el texto de los campos.
 `Navigator.pop(context, elementoNuevo)` cierra el formulario y pasa el elemento a quien lo llamo, como la pantalla de formulario desapareca, se llama a `dispouse()` y se liberan los controladores.
 En la lista el await la variable nuevo ahora contiene el Elemento si fuese null significa que el usuario cerro sin rellenar los campos.
 setState(() => _elementos = [nuevo, ..._elementos]) añade el elemento al principio de la lista y avisa a Flutte que cambio el estado. Flutter ejecuta el metodo bild() de la pantalla ListView.builder y recibe la lista con un elemento más y su itemBuilder crea una nueva TarjetaElemento para el.

 ## Fase 4 · Detalle, edición y borrado (R5, R6, R7)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
1. Estoy desarrollando una app en Flutter (nivel educativo) siguiendo una arquitectura modular estricta. Necesito implementar la Fase 4 de mi proyecto "Mi Watchlist" (Detalle, edición y borrado).

CONTEXTO ACTUAL:
- Tengo la clase modelo `Elemento`, los enums, el `SelectorEstrellas` y la `PantallaFormulario` (que debe admitir un parámetro opcional `Elemento? inicial` para reutilizarse en la edición).
- Trabajo únicamente con StatefulWidget y setState, sin paquetes externos.

OBJETIVO DE ESTA PETICIÓN:
1. Crear la `PantallaDetalle` en `lib/pantallas/pantalla_detalle.dart`:
   - Mostrar todos los datos del elemento recibido (icono según tipo, título, estado, valoración con estrellas, notas y fecha de alta).
   - Añadir botones en la AppBar o cuerpo para **Editar** (que navegue a `PantallaFormulario` pasando el elemento actual y espere el resultado para actualizarlo) y **Borrar**.
2. Implementar la lógica de borrado con confirmación:
   - Al pulsar Borrar, mostrar un `AlertDialog` pidiendo confirmación.
   - Si el usuario confirma, hacer un `Navigator.pop` y mostrar un `SnackBar` confirmando la acción.
3. Actualizar la lista principal (`PantallaLista`) para gestionar correctamente el reemplazo de elementos editados (buscando por id) y la eliminación de elementos borrados.

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos.
- Comenta el código adecuadamente con comentarios explicativos (`///`).

Por favor, proporcióname el código clave para manejar la navegación de vuelta desde la edición y el diálogo de confirmación de borrado.

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: 

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...
Mi prompt anterior pedía hacer Navigator.pop y mostrar el SnackBar desde el detalle. La IA detectó que eso no funcionaría: al cerrarse la pantalla de detalle, el SnackBar desaparecería con ella. Por eso el detalle devuelve el elemento borrado a la lista, y es la lista (que sigue abierta) la que muestra el SnackBar.

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):

He aprendido que en Dart tienes que declarar una variable siemrpe con un tipo o en su derefto
declararla con late, con late puedes cambiarlo despues, con late final no, cuando declaras el tipo queda fijo.

**Preguntas de comprensión** (respondidas sin IA):
1. ¿Cómo sabe el formulario si está creando o editando?

El formulario lo sabe por el parámetro inicial, que depende de qué pantalla lo abre. La lista lo abre sin pasarle nada (PantallaFormulario()), así que inicial vale null y el formulario sabe que está creando. El detalle lo abre pasándole el elemento (PantallaFormulario(inicial: _elemento)), así que inicial tiene valor y sabe que está editando.

Para no repetir la comprobación, hay un getter bool get _editando => widget.inicial != null;
que calcula si estamos editando cada vez que se consulta.

Según el caso cambian tres cosas:

en initState, si estamos editando, los campos se rellenan con los datos del elemento; si no, empiezan vacíos;
en _guardar, al crear se usa Elemento.nuevo (que genera un id nuevo) y al editar se usa copyWith,
para conservar el mismo id y que la lista pueda encontrar el elemento y sustituirlo;
con ternarias se cambian los textos: "Nuevo elemento" o "Editar elemento", y "Guardar" o "Guardar cambios".

2. ¿Cómo encuentra la lista qué elemento debe reemplazar al volver de la edición?
Cuando llama a initial _state()

La lista lo encuentra por el id, en el método _abrirElemento de pantalla_lista.dart. Al volver de la edición recorre todos sus elementos con e.id == afectado.id ? afectado : e: si el id coincide pone el elemento editado y, si no, deja el que estaba.

Esto funciona porque el formulario edita con copyWith, que crea una copia nueva (el elemento es inmutable) pero conserva el mismo id. No se puede buscar por otro campo, como el título, porque el usuario puede cambiarlo y entonces no lo encontraría. El id es lo único que nunca cambia.

3. ¿Qué devuelve `showDialog` y cómo lo usas para saber si el usuario confirmó?
showDialog devuelve un future y hay que esperarlo con await igual que con push. Puede devolver: 
true -> el usuario pulso borrar
false -> pulso cancelar
null -> cuando el usuario pulsa fuera del dialogo
Para saber si confirmó se usa la condición if (confirmado != true) return;: solo se borra si la respuesta es exactamente true; con false o null se sale sin borrar. Si se usara == false, el caso null (pulsar fuera del diálogo) no haría return y el elemento se borraría sin querer.

## Fase 9 · Ordenamiento (R14)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
1. Estoy desarrollando una app educativa en Flutter con arquitectura modular estricta y necesito implementar una ampliación del proyecto.

CONTEXTO ACTUAL:
- Tengo la lista completa de elementos con sus estados, tipos y valoraciones funcionando correctamente.
- El objetivo es modificar o añadir elementos visuales directamente en el `AppBar` de la pantalla principal.

OBJETIVO DE ESTA PETICIÓN:
1. Implementar un menú desplegable (`PopupMenuButton`) en el `AppBar` para ordenar la lista de elementos según diferentes criterios (por ejemplo: título alfabéticamente, valoración de estrellas de mayor a menor, o fecha más reciente).
2. Aplicar un algoritmo de ordenamiento seguro (`sort`) sobre una copia de la lista visible para no alterar la fuente de datos original.

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos adicionales.
- Asegúrate de proteger cualquier operación lógica o matemática que intervenga en el ordenamiento.
- Comenta el código adecuadamente con docstrings (`///`).

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: Enum para los criterios, método `_aplicarOrdenamiento()` con lógica de ordenamiento, `PopupMenuButton` en el AppBar con `CheckedPopupMenuItem` para mostrar el criterio seleccionado.

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- Ninguno. El código compila y pasa todos los tests.

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):

Que usar una copia con el operador spread (`[...lista]`) y aplicar `sort()` a esa copia es seguro porque no modifica la lista original. El `PopupMenuButton` con `CheckedPopupMenuItem` permite mostrar cuál es el criterio activo. Al ordenar por valoración, hay que proteger contra divisiones y comparaciones con null: si hay dos elementos sin valorar (0), se mantiene su orden relativo.

**Preguntas de comprensión** (respondidas sin IA):

1. ¿Por qué hay que hacer una copia de la lista antes de ordenarla?

Para no modificar la lista original (`_visibles`), que se genera nuevamente cada vez que cambia el filtro o la búsqueda. Si usara `sort()` directamente sobre `_visibles`, estaría modificando esa lista calculada, y aunque en este caso no rompe nada, es una mala práctica. Es más limpio crear una copia con `[...lista]` y ordenar eso.

2. ¿Qué hace `CheckedPopupMenuItem` y por qué se usa aquí?

Es como `PopupMenuItem`, pero muestra un checkmark (✓) al lado de la opción seleccionada. Al cambiar de criterio, el check se mueve. Da retroalimentación visual al usuario sobre qué criterio está activo.

3. ¿Cómo protege el ordenamiento por valoración contra valores nulos?

Primero comprueba si ambos elementos tienen valoración > 0: si es así, los compara de mayor a menor. Si solo uno tiene, va primero. Si ninguno tiene, devuelve 0 para mantener su orden relativo (estabilidad del sort).

## Fase 10 · Modo Oscuro (R15)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
1. Estoy desarrollando una app educativa en Flutter con arquitectura modular estricta y necesito implementar una ampliación opcional: el Modo Oscuro.

CONTEXTO ACTUAL:
- La app ya cuenta con un tema global configurado mediante `ThemeData` y `ColorScheme.fromSeed` en `main.dart`.
- Ya utilizamos el paquete `shared_preferences` para la persistencia de la watchlist.

OBJETIVO DE ESTA PETICIÓN:
1. Añadir la capacidad de alternar entre modo claro y modo oscuro en la aplicación mediante un interruptor (Switch) ubicado en el lugar adecuado (por ejemplo, en la pantalla de estadísticas o en la AppBar de la lista).
2. Guardar la preferencia del usuario (activado/desactivado) utilizando `shared_preferences` para que la app recuerde el tema elegido al reiniciarse.
3. Actualizar el estado global de la app para que el cambio de tema se aplique de forma dinámica e inmediata en toda la interfaz (`ThemeMode.light` o `ThemeMode.dark`).

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos adicionales (aprovecha `shared_preferences` que ya está instalado).
- Mantén el código limpio, estructurado y debidamente comentado con docstrings (`///`).

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: Métodos `cargarModoOscuro()` y `guardarModoOscuro()` en `Almacen`, conversión de `MainApp` a `StatefulWidget`, generación de temas separados para claro y oscuro con `brightness` en `ColorScheme.fromSeed()`, uso de `themeMode` para aplicar dinámicamente, IconButton en AppBar con icono que cambia según el modo (🌙 si es claro, ☀️ si es oscuro).

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- Ninguno. El código compila, pasa todos los tests y sin warnings de análisis.

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):

Para cambiar el tema dinámicamente de toda la app, `MainApp` tiene que ser `StatefulWidget` (no puede ser `StatelessWidget`). Al cambiar `themeMode` y hacer `setState()`, Flutter reconstruye el árbol de widgets con el nuevo tema. El modo oscuro se detecta con `Theme.of(context).brightness == Brightness.dark`. El cambio se guarda en `shared_preferences` para persistir la preferencia del usuario.

**Preguntas de comprensión** (respondidas sin IA):

1. ¿Por qué `MainApp` tiene que ser `StatefulWidget` y no `StatelessWidget`?

Porque necesita cambiar el `themeMode` del `MaterialApp` cuando el usuario alterna el tema. Para cambiar algo que afecta a todo el árbol de widgets (el tema), necesito un estado que pueda cambiar y disparar `setState()`. Un `StatelessWidget` es inmutable: una vez que se construye, no cambia.

2. ¿Cómo se genera el tema oscuro a partir de la misma semilla de color?

Usando `ColorScheme.fromSeed()` con el parámetro `brightness`. Si `brightness` es `Brightness.dark`, genera una paleta oscura coherente con el mismo color semilla. Si es `Brightness.light`, genera la paleta clara.

3. ¿Por qué el IconButton del tema está en el AppBar y no en un menú separado?

Porque el cambio de tema es algo que el usuario puede querer hacer rápidamente desde cualquier pantalla. Tenerlo en la AppBar (que está siempre visible) lo hace accesible. El icono cambia según el modo (`Icons.dark_mode` si es claro, `Icons.light_mode` si es oscuro) para que el usuario entienda qué pasará al hacer clic.

## Fase N · Nombre de la fase

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
1. ...
2. ...

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: ...

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):
...

## Fase 6 · Persistencia (R10)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
Estoy desarrollando una app en Flutter (nivel educativo) siguiendo una arquitectura modular estricta. Necesito implementar la Fase 6 de mi proyecto "Mi Watchlist" (Persistencia con shared_preferences, R10).

CONTEXTO ACTUAL:
- Ya tengo instalada y configurada la dependencia `shared_preferences` (`flutter pub add shared_preferences`).
- Tengo la clase `Elemento` con sus métodos `toJson()` y `fromJson()`.
- Trabajo con StatefulWidget y setState, sin paquetes externos de gestión de estado.

OBJETIVO DE ESTA PETICIÓN:
1. Crear el servicio de almacenamiento en `lib/servicios/almacen.dart`:
   - Una clase `Almacen` con un método estático o de instancia `Future<List<Elemento>> cargar()`. Debe leer de `SharedPreferences` con la clave `watchlist`, decodificar la cadena JSON a una lista y manejar posibles errores o datos dañados devolviendo una lista vacía en lugar de romperse.
   - Un método `Future<void> guardar(List<Elemento> elementos)` que serialice la lista completa a una cadena JSON y la guarde en `SharedPreferences`.
2. Integrar la persistencia en `PantallaLista`:
   - Mostrar un indicador de carga (`CircularProgressIndicator`) mientras se recuperan los datos al arrancar la app.
   - Cargar los datos al iniciar la pantalla (llamando al servicio desde un método auxiliar asíncrono en `initState`).
   - Invocar el guardado automáticamente después de realizar cualquier alta, edición o borrado.

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos adicionales.
- Asegúrate de controlar excepciones por si el JSON almacenado está corrupto.
- Comenta el código adecuadamente (`///`).

Por favor, proporcióname el código del servicio `Almacen` y cómo gestionar el estado de carga inicial en `PantallaLista`.

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: 

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):
...

**Preguntas de comprensión** (respondidas sin IA):

1. ¿Por qué cargar() devuelve un Future? ¿Qué pasaría si la pantalla intentara pintar la lista antes de que termine?

Porque leer los datos guardados tarda un poco, y si la app se quedara esperando, la pantalla se congelaría. Con el Future la app sigue funcionando y los datos llegan cuando están listos.

Si la pantalla pintara la lista antes de que termine, _elementos todavía estaría vacía y saldría el mensaje de "Tu watchlist está vacía", aunque tuvieras elementos guardados. Por eso uso _cargando: mientras es true se muestra un CircularProgressIndicator, y cuando termina la carga se pone a false con setState y ya se ve la lista.

2. ¿Por qué no se puede usar await directamente dentro de initState? ¿Cómo lo has resuelto?

Porque initState no puede ser async: Flutter lo ejecuta y sigue sin esperar. Lo he resuelto creando el método _cargarDatos(), que sí es async. Lo llamo desde initState, dentro espera los datos con await y después hace setState para mostrarlos. Mientras tanto se ve el indicador de carga.

3. ¿Dónde están físicamente los datos? ¿Se pierden si desinstalas la app?

Se guardan en el propio dispositivo, en una zona privada de la app. En Android es un archivo de preferencias, y se pierde si desinstalas la app o borras sus datos.

## Fase 7 · Estadísticas y tema (R11, R13)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
Estoy desarrollando una app en Flutter (nivel educativo) siguiendo una arquitectura modular estricta. Necesito implementar la Fase 7 de mi proyecto "Mi Watchlist" (Estadísticas y Tema, R11 y R13).

CONTEXTO ACTUAL:
- Tengo la lista completa de elementos con sus estados, tipos y valoraciones.
- Trabajo únicamente con StatefulWidget y setState, sin paquetes externos de gestión de estado.

OBJETIVO DE ESTA PETICIÓN:
1. Configurar el tema global de la app en `lib/main.dart`:
   - Implementar un `ThemeData` utilizando `ColorScheme.fromSeed(seedColor: ...)` para definir una paleta de colores propia y coherente en toda la aplicación.
2. Crear la `PantallaEstadisticas` en `lib/pantallas/pantalla_estadisticas.dart` (accesible desde un icono en la AppBar de la lista principal):
   - **Total:** Mostrar el número total de elementos guardados.
   - **Recuento por estado:** Calcular y mostrar cuántos elementos hay en cada estado (Pendiente, Viendo, Terminado) representados visualmente con barras proporcionales (`LinearProgressIndicator` o contenedores con ancho adaptado) y su respectivo número al lado.
   - **Valoración media:** Calcular la media aritmética exclusivamente de los elementos que tengan una valoración mayor a 0 (evitando estrictamente la división entre cero si no hay ninguno valorado).
   - **Tipo más frecuente:** Determinar cuál de los tres tipos (`Tipo.pelicula`, `Tipo.serie`, `Tipo.videojuego`) es el que más se repite en la lista.

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos adicionales.
- Asegúrate de proteger las operaciones matemáticas (división por cero).
- Comenta el código adecuadamente (`///`).

Por favor, proporcióname el código para los cálculos lógicos de las estadísticas y la estructura visual de la pantalla.

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: 
Además añadio una funcionalidad extra que no se pedia, si tenemos empate entre peliculas y series mas frecuentes, muestra las dos.
**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):
...

**Preguntas de comprensión** (respondidas sin IA):

1. ¿Cómo has evitado dividir entre cero en la valoración media?

Antes de dividir compruebo si hay algún elemento valorado con if (lista.isEmpty) return null;. Si no hay ninguno, devuelvo null y no se llega a hacer la división. En la pantalla, si la media es null, se muestra "Sin valoraciones todavía".

2. ¿Por qué los elementos con 0 estrellas no cuentan para la media?

Porque el 0 significa "sin valorar", no que sea malo. Si los contara, la media bajaría aunque el usuario no les haya puesto nota. Por ejemplo, con un 5 y un sin valorar, la media saldría 2,5 en vez de 5.

3. ¿Qué ventaja tiene definir los colores en el tema en lugar de en cada widget?

Que los colores están en un solo sitio, en el ThemeData de main.dart, y toda la app usa los mismos. Si quiero cambiarlos, solo cambio el color semilla de ColorScheme.fromSeed y cambia todo, sin tener que ir widget por widget.

### Fase 8 · Pruebas y documentación

- `test/elemento_test.dart`: comprueba que `fromJson(toJson(e))` devuelve los mismos datos y que `copyWith` solo cambia lo indicado.
- `test/formulario_test.dart`: prueba de widget que pulsa Guardar con el título vacío y comprueba que aparece el mensaje de error.
- `README.md` del proyecto: qué hace la app, cómo ejecutarla, capturas y paquetes usados.
- Ejecuta y deja sin errores:

```bash
dart format lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

**Preguntas de comprensión:**
1. ¿Qué diferencia hay entre una prueba unitaria y una de widget?
Prueba unitaria (Unit Test): Evalúa una función, método o clase de forma completamente aislada (como la lógica pura del modelo Elemento o la serialización JSON) sin necesidad de levantar ningún motor gráfico ni renderizar interfaz de usuario. Son pruebas muy rápidas.

Prueba de widget (Widget Test): Permite probar componentes o pantallas completas de la interfaz de usuario en un entorno virtual simulado. Comprueba cómo se comportan los widgets, si responden a las interacciones (como hacer clic) y si validan o muestran los elementos visuales correctamente.

2. ¿Qué hace `tester.pump()` y por qué hace falta después de pulsar un botón?

tester.pump() le indica a Flutter que procese los eventos pendientes y redibuje el árbol de widgets avanzando un fotograma virtual (frame).

Es necesario después de una acción interactiva (como pulsar un botón, navegar o cambiar un campo) porque dicha acción provoca un cambio de estado. Sin tester.pump(), la pantalla virtual de pruebas se quedaría congelada en el fotograma anterior y no reflejaría el resultado visual del cambio (como la aparición de un mensaje de error).

## Ampliaciones opcionales (Ordenar)

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
Estoy desarrollando una app educativa en Flutter con arquitectura modular estricta y necesito implementar una ampliación del proyecto.

CONTEXTO ACTUAL:
- Tengo la lista completa de elementos con sus estados, tipos y valoraciones funcionando correctamente.
- El objetivo es modificar o añadir elementos visuales directamente en el `AppBar` de la pantalla principal.

OBJETIVO DE ESTA PETICIÓN:
1. Implementar un menú desplegable (`PopupMenuButton`) en el `AppBar` para ordenar la lista de elementos según diferentes criterios (por ejemplo: título alfabéticamente, valoración de estrellas de mayor a menor, o fecha más reciente).
2. Aplicar un algoritmo de ordenamiento seguro (`sort`) sobre una copia de la lista visible para no alterar la fuente de datos original.

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos adicionales.
- Asegúrate de proteger cualquier operación lógica o matemática que intervenga en el ordenamiento.
- Comenta el código adecuadamente con docstrings (`///`).

Por favor, proporcióname el código necesario para integrar el `PopupMenuButton` en el `AppBar` y la lógica de ordenamiento con `.sort()` aplicada a la lista.
**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: 
La IA me proporcionó un enum CriterioOrden para definir las opciones, la estructura de un PopupMenuButton listo para integrar en las acciones de la AppBar, y el método lógico basado en .sort() para ordenar los elementos.

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):
He aprendido a integrar menús interactivos en la barra superior mediante PopupMenuButton y a manipular colecciones en Dart aplicando algoritmos de ordenamiento personalizados con .sort() y compareTo de forma limpia y segura.

## Ampliaciones opcionales (Modo oscuro) 

**Herramienta usada:** (Claude)

**Prompts principales** (cópialos tal cual):
Estoy desarrollando una app educativa en Flutter con arquitectura modular estricta y necesito implementar una ampliación opcional: el Modo Oscuro.

CONTEXTO ACTUAL:
- La app ya cuenta con un tema global configurado mediante `ThemeData` y `ColorScheme.fromSeed` en `main.dart`.
- Ya utilizamos el paquete `shared_preferences` para la persistencia de la watchlist.

OBJETIVO DE ESTA PETICIÓN:
1. Añadir la capacidad de alternar entre modo claro y modo oscuro en la aplicación mediante un interruptor (Switch) ubicado en el lugar adecuado (por ejemplo, en la pantalla de estadísticas o en la AppBar de la lista).
2. Guardar la preferencia del usuario (activado/desactivado) utilizando `shared_preferences` para que la app recuerde el tema elegido al reiniciarse.
3. Actualizar el estado global de la app para que el cambio de tema se aplique de forma dinámica e inmediata en toda la interfaz (`ThemeMode.light` o `ThemeMode.dark`).

RESTRICCIONES TÉCNICAS:
- No utilices paquetes externos adicionales (aprovecha `shared_preferences` que ya está instalado).
- Mantén el código limpio, estructurado y debidamente comentado con docstrings (`///`).

Por favor, proporcióname los cambios necesarios para gestionar el estado del tema, guardarlo localmente y aplicarlo en el `MaterialApp` principal.

**Qué me dio la IA y qué hice con ello:**
- Acepté sin cambios: 
La IA me proporcionó la lógica para leer y escribir el estado del tema usando SharedPreferences, cómo elevar el estado del ThemeMode en la raíz (main.dart), y cómo añadir un control interactivo para alternarlo.

**Errores de la IA que detecté** (métodos inventados, código que no compilaba, paquetes no permitidos…):
- ...

**Lo que he aprendido en esta fase** (2-3 líneas con mis palabras):
He aprendido a gestionar el estado global del tema en Flutter y a persistir preferencias de usuario utilizando shared_preferences para que la configuración visual elegida se mantenga al reiniciar la aplicación.
