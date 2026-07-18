# Recorrido de demostracion

## Preparacion

1. Instalar `app-debug.apk` en un dispositivo Android ARM64 con API 24 o mayor.
2. Abrir CutZero con el dispositivo en vertical.
3. Usar el agente de demostracion si no se descargo Gemma 4 E2B.
4. Mantener disponible la captura fixture incluida en la app.

## Flujo principal

1. En Trabajo, mostrar el pedido, material EVA y diez piezas.
2. Pulsar Analizar captura para detectar tres contornos con revision obligatoria.
3. Ajustar una cantidad o la separacion y confirmar la revision.
4. Pulsar Optimizar y comparar Aprovechamiento con Retal reutilizable.
5. Mostrar que las diez piezas evitan la zona defectuosa.
6. Exportar SVG o PDF y compartir el ultimo archivo.
7. Guardar el retal mayor y abrir Inventario para verlo con medidas y ubicacion.
8. Abrir Agente, elegir Demostracion y ejecutar el flujo.
9. Mostrar las cinco herramientas iniciadas y completadas y el registro local.

## Flujo Gemma local

1. En Agente, instalar Gemma 4 E2B. La descarga aproximada es 2.4 GB.
2. Seleccionar Gemma 4 local cuando el estado sea listo.
3. Ejecutar la misma instruccion de trabajo.
4. Verificar que cada llamada coincide con la lista blanca.
5. Desconectar internet despues de instalar el modelo y repetir.

## Contingencias

- Si no hay red o espacio para el modelo, usar Demostracion. Usa los mismos casos
  de uso, repositorios y solver que el agente real.
- Si la camara no tiene permiso, usar galeria o la captura incluida.
- Si una pieza no cabe, la app conserva el trabajo revisado y muestra el error;
  no exporta un layout parcial.
- iPhone requiere una compilacion firmada desde macOS; no se puede firmar desde
  Windows.
