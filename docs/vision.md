# Vision y revision de contornos

## Decision

CutZero usa `opencv_dart` 1.4.5 detras de `VisionPort`. Es la ultima version de
la rama 1.x compatible con la resolucion actual del proyecto. La rama 2.2.x no
puede adoptarse todavia porque depende de `hooks` 1.x y
`flutter_gemma_litertlm` 1.1.0 exige `hooks` 2.x. No se usa un override forzado:
una compilacion reproducible es mas importante que aparentar una actualizacion.

El adaptador se puede reemplazar cuando ambas dependencias converjan sin tocar
el dominio, el controlador ni las vistas.

Las dependencias AndroidX transitivas exigen `compileSdk 34` o posterior,
mientras la rama 1.x de OpenCV declara 33. El Gradle raiz eleva de forma
reproducible los subproyectos Android a `compileSdk 36`; no se modifica la cache
de paquetes.

## Pipeline local

1. Decodificar JPEG o PNG en memoria.
2. Convertir a escala de grises y aplicar desenfoque gaussiano.
3. Detectar bordes con Canny.
4. Extraer contornos y simplificarlos con Douglas-Peucker.
5. Identificar el limite de la lamina para obtener escala X/Y.
6. Rechazar fragmentos, objetos demasiado pequenos y candidatos fuera del
   material.
7. Eliminar bordes duplicados del mismo objeto.
8. Alinear candidatos con las plantillas esperadas por dimensiones y area.
9. Devolver contornos normalizados, confianza y advertencias.

El procesamiento es local y no sube fotografias. Una captura que no entregue
todos los moldes esperados se rechaza con un mensaje recuperable.

## Revision humana

La salida de vision siempre requiere revision. El editor permite seleccionar un
molde, desplazar vertices y restaurar la deteccion original. Un poligono sin
area o autocruzado no puede confirmarse.

Al confirmar, los contornos revisados reemplazan los poligonos de
`PartTemplate`. Por tanto, el solver, el validador, los costos y la exportacion
consumen la geometria aceptada, no una representacion decorativa.

## Calibracion y limites

- La lamina del trabajo define el ancho y alto fisico usados para escalar.
- La foto debe ser cenital, con el borde completo y contraste suficiente.
- La perspectiva fuerte se comunica como advertencia y requiere correccion.
- El MVP no aplica homografia automatica; una toma oblicua debe repetirse o
  corregirse en la revision.
- La confianza no elimina la revision obligatoria.
- OpenCV reduce trabajo manual, pero no sustituye una medicion fisica cuando la
  tolerancia del corte sea critica.

La prueba Android en `integration_test/android_workflow_test.dart` se ejecuto en
un emulador Android 11 x86_64 con la biblioteca nativa. Confirmo tres moldes,
persistio la revision en SQLite, calculo dos layouts y exporto SVG. El mismo
recorrido se repitio manualmente desde la interfaz hasta el plan optimizado.
