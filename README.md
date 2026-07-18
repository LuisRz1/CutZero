# CutZero

CutZero es una aplicacion movil local-first para digitalizar moldes, validar
medidas, optimizar cortes y conservar retales reutilizables. El MVP funciona en
Android y mantiene compatibilidad de proyecto con iOS. La inferencia con Gemma 4
E2B se instala bajo demanda y se ejecuta en el dispositivo.

## Estado

- Captura desde camara, galeria o fixture de demostracion.
- Revision de cantidades, veta y separacion.
- Dos planes deterministas: aprovechamiento y retal reutilizable.
- Validacion geometrica de limites, defectos, separacion y piezas completas.
- Exportacion SVG y PDF con tipografia Unicode local.
- Inventario local de retales compatibles.
- Agente con cinco herramientas permitidas y traza persistente.
- Interfaz responsive, animada y sin emojis.
- Pruebas de dominio, persistencia, agente, controlador, exportacion y widgets.

## Arquitectura

El codigo aplica Clean Architecture por funcionalidad y usa MVC como capa de
intermediacion en presentacion:

- `domain`: entidades y reglas puras de Dart.
- `application`: casos de uso y puertos.
- `infrastructure`: Drift, Clipper2, image_picker, archivos y Gemma.
- `presentation`: vistas Flutter y `CuttingWorkspaceController`.
- `app`: composicion de dependencias Riverpod, tema y GoRouter.

El modelo contiene `CuttingJob`, `MaterialSheet`, `NestingLayout` y `Remnant`.
Las vistas solo renderizan estado. El controlador recibe intenciones y coordina
puertos. Los adaptadores dependen de contratos de aplicacion, no de widgets.

La explicacion completa esta en [docs/architecture.md](docs/architecture.md).

## Base de datos

El MVP usa SQLite mediante Drift. Es la opcion principal porque el flujo debe
funcionar sin conexion, conservar geometria de forma transaccional y mantener
una auditoria consultable del agente. No se necesita un backend para la demo.

Las tablas son:

- `job_records`: trabajo completo versionable y metadatos de consulta.
- `remnant_records`: inventario normalizado por material, color, area y limites.
- `tool_invocation_records`: herramientas, argumentos, resultado y duracion.

La decision y la evolucion prevista estan en
[docs/database.md](docs/database.md).

## Entorno en D

Entorno validado en Windows:

- Flutter `3.44.6` en `D:\flutter-sdk\flutter`.
- Android SDK en `D:\Android\Sdk`.
- Pub cache en `D:\Caches\Pub`.
- Gradle cache en `D:\Caches\Gradle`.
- NDK `28.2.13676358` y CMake `3.22.1`.
- Java 21 de Android Studio.

```powershell
$env:PATH = 'C:\Windows\System32\WindowsPowerShell\v1.0;' + $env:PATH
$env:ANDROID_HOME = 'D:\Android\Sdk'
$env:ANDROID_SDK_ROOT = 'D:\Android\Sdk'
$env:PUB_CACHE = 'D:\Caches\Pub'
$env:GRADLE_USER_HOME = 'D:\Caches\Gradle'

& D:\flutter-sdk\flutter\bin\flutter.bat pub get
& D:\flutter-sdk\flutter\bin\flutter.bat analyze
& D:\flutter-sdk\flutter\bin\flutter.bat test
& D:\flutter-sdk\flutter\bin\flutter.bat build apk --debug `
  --target-platform android-arm64 --split-per-abi
```

El APK queda en
`build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk`. Android requiere
API 24 o posterior y un dispositivo ARM64. El filtro ARM64 evita empaquetar
bibliotecas que Gemma 4 E2B no puede ejecutar en el MVP.

## Gemma 4 local

El modelo `gemma-4-E2B-it.litertlm` ocupa aproximadamente 2.4 GB. No forma parte
del APK: se descarga desde la vista Agente y despues opera sin conexion. Si el
repositorio de modelos exige autenticacion, el token se entrega al compilar y
nunca se guarda en Git:

```powershell
& D:\flutter-sdk\flutter\bin\flutter.bat run `
  --dart-define=HF_TOKEN=$env:HF_TOKEN
```

El agente no ejecuta texto libre como codigo. Solo puede invocar
`search_remnants`, `vectorize_capture`, `validate_geometry`, `run_nesting` y
`calculate_cost`; cada intento queda registrado en SQLite.

## iOS

El proyecto fija iOS 16 y usa frameworks estaticos. La compilacion y firma final
requieren macOS, Xcode, CocoaPods y una identidad de Apple Developer. CI valida
`flutter build ios --no-codesign`; la instalacion en iPhone exige configurar el
equipo de firma en Xcode.

## Validacion visual

Las referencias aprobadas estan en `test/goldens`. En Windows pueden regenerarse
con una fuente real del sistema:

```powershell
& D:\flutter-sdk\flutter\bin\flutter.bat test test/visual_review_test.dart `
  --update-goldens --dart-define=UPDATE_VISUALS=true
```

El recorrido de presentacion esta en [docs/demo.md](docs/demo.md).
