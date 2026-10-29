# MiniNotas: inyección de dependencias en Flutter

Proyecto educativo para explicar cómo pasar de dependencias acopladas a
inyección por constructor y, después, centralizar la creación de objetos con
[`get_it`](https://pub.dev/packages/get_it).

La aplicación permite registrar, listar y eliminar notas con persistencia local.
El alcance es intencionalmente pequeño para concentrarse en las dependencias,
no en la complejidad de la interfaz.

## Estado actual

**Esta es la versión base acoplada, preparada para un refactor en vivo.**

La aplicación funciona sin configurar `get_it`:

- La pantalla construye el presenter.
- El presenter construye los casos de uso.
- Los casos de uso construyen la implementación del repositorio y su datasource.
- El repositorio delega la persistencia a `SharedPreferences`.

`get_it` ya está declarado como dependencia, pero
[`configureDependencies`](lib/di/dependencies.dart) todavía está vacío y no se
invoca en el arranque. Completar esa configuración es parte del ejercicio.

## Funcionalidades

- Guardar notas de texto, eliminando espacios al inicio y al final.
- Validar que el texto no esté vacío desde el formulario.
- Listar las notas guardadas y recuperarlas al volver a abrir la aplicación.
- Eliminar una nota por su identificador, aunque existan textos repetidos.
- Mostrar estados de carga, lista vacía y errores.
- Deshabilitar acciones mientras se procesa una operación.
- Conservar el texto del formulario cuando falla el guardado.
- Reintentar la carga después de un error.

No incluye edición, autenticación, sincronización remota ni navegación entre
pantallas.

## Requisitos

- Flutter con Dart compatible con `^3.9.2` (`>=3.9.2 <4.0.0`).
- Un dispositivo o emulador Android/iOS y las herramientas de su plataforma.

El repositorio incluye los proyectos de Android e iOS. Puedes revisar tu entorno
con:

```bash
flutter doctor
```

## Ejecutar

Desde la raíz del proyecto:

```bash
flutter pub get
flutter devices
flutter run
```

Si hay varios dispositivos disponibles, selecciona uno:

```bash
flutter run -d <device_id>
```

No requiere claves, variables de entorno ni un backend.

## Estructura

```text
lib/
  main.dart
  di/
    dependencies.dart
  features/
    notes/
      presentation/
        notes_page.dart
        notes_presenter.dart
      domain/
        entities/
          note.dart
        models/
          note_model.dart
        repositories/
          note_repository.dart
        use_cases/
          add_note_use_case.dart
          list_notes_use_case.dart
          delete_note_use_case.dart
      data/
        data_sources/
          notes_local_data_source.dart
        repositories/
          note_repository_impl.dart
```

### Flujo de la aplicación

```text
NotesPage
    |
    v
NotesPresenter
    |
    +-- ListNotesUseCase
    +-- AddNoteUseCase
    +-- DeleteNoteUseCase
            |
            v
      NoteRepository
            ^
            | implementa
      NoteRepositoryImpl
            |
            v
      NotesLocalDataSource
            |
            v
      SharedPreferences
```

| Componente | Responsabilidad actual |
|---|---|
| `NotesPage` | Renderizar la interfaz, validar el formulario y generar el identificador de la nota. |
| `NotesPresenter` | Coordinar operaciones y publicar notas, carga y errores mediante `ChangeNotifier`. |
| Casos de uso | Invocar las operaciones del repositorio. |
| `NoteRepository` | Definir el contrato de listado, registro y eliminación. |
| `NoteRepositoryImpl` | Implementar el contrato delegando al datasource. |
| `NotesLocalDataSource` | Leer, validar y escribir los datos persistidos. |
| `NoteModel` | Convertir mapas JSON y ofrecer conversiones hacia y desde `Note`. |

### Separación por capas, todavía no Clean Architecture completa

La estructura está inspirada en Clean Architecture, pero la versión inicial
conserva decisiones que se revisarán durante el ejercicio:

- Los casos de uso importan infraestructura y construyen clases de datos.
- El contrato del repositorio y los casos de uso trabajan con `NoteModel`.
- `NoteModel` vive actualmente en `domain/models`, aunque conoce JSON.
- La validación del texto y la generación del identificador están en la pantalla.

La separación en carpetas no garantiza la inversión de dependencias. El objetivo
es hacer visibles estos acoplamientos y explicar cómo eliminarlos.

## Persistencia local

Se utiliza [`shared_preferences`](https://pub.dev/packages/shared_preferences)
con una cadena JSON almacenada bajo la clave `mini_notes`:

```json
[
  {
    "id": "1793232000000000",
    "text": "Preparar la demo"
  }
]
```

- `NoteModel.fromJson` y `toJson` convierten entre mapas y modelos.
- El datasource usa `jsonDecode` y `jsonEncode` para leer y escribir la cadena.
- Si no existe la clave, se devuelve una lista vacía.
- Si el JSON está corrupto o una escritura es rechazada, se comunica un error.

Este almacenamiento se eligió por simplicidad didáctica. No es una base de datos
ni una opción para guardar información sensible o crítica.

## Ejercicio: incorporar inyección de dependencias

1. Recibir `NoteRepository` por constructor en los casos de uso, sin construir su
   implementación ni recibir `SharedPreferences`.
2. Recibir los casos de uso por constructor en `NotesPresenter`.
3. Recibir el presenter por constructor en `NotesPage`, manteniendo explícito
   quién lo libera con `dispose`.
4. Construir el grafo manualmente en el punto de composición para demostrar que
   la inyección de dependencias no necesita una librería.
5. Centralizar los registros en
   [`dependencies.dart`](lib/di/dependencies.dart) con `get_it`.
6. Esperar la configuración antes de crear la pantalla y resolver sus
   dependencias una sola vez, nunca en cada `build`.
7. Ejecutar las pruebas y verificar que el comportamiento visible no cambió.

Registros propuestos para la sesión:

| Dependencia | Registro |
|---|---|
| `SharedPreferences` inicializado | `registerSingleton` |
| Datasource y repositorio | `registerLazySingleton` |
| Casos de uso y presenter | `registerFactory` |

Mantener las llamadas a `getIt` en el punto de composición: el presenter, los
casos de uso y el repositorio deben recibir sus dependencias, no buscarlas en el
contenedor.

Como mejora complementaria, mover `NoteModel` a la capa de datos, usar `Note` en
los contratos de dominio y trasladar las reglas de negocio fuera de la pantalla.
Configurar `get_it` por sí solo no corrige esos límites arquitectónicos.

El guion y la propuesta completa están en [IDEA_PROYECTO.md](IDEA_PROYECTO.md).

## Pruebas y análisis

```bash
flutter analyze
flutter test
```

Para ejecutar únicamente las pruebas de la pantalla:

```bash
flutter test test/widget_test.dart
```

Las pruebas actuales cubren:

- **Datasource:** serialización, lectura, eliminación por identificador y
  rechazo de datos corruptos.
- **Presenter:** estado inicial, notificaciones, recarga tras cambios, errores,
  concurrencia y liberación durante operaciones.
- **Pantalla:** validación, guardado, eliminación, recuperación de notas
  persistidas y reintento después de un error.

Se utiliza `SharedPreferences.setMockInitialValues` para no depender del
almacenamiento real del dispositivo.

## Idea clave

> La inyección por constructor hace explícitas las dependencias.
> `get_it` organiza cómo se construyen y comparten los objetos.
> Clean Architecture define sus responsabilidades y la dirección de sus dependencias.
