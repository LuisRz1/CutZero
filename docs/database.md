# Decision de base de datos

## Eleccion

CutZero usa SQLite con Drift como base de datos principal del dispositivo.

Esta combinacion es optima para el MVP porque:

- El taller debe trabajar sin internet.
- Trabajos, retales y trazas requieren transacciones locales.
- Las consultas por material, color y area deben ser rapidas.
- La geometria puede persistirse como JSON sin perder una estructura consultable.
- Drift aporta SQL tipado, streams reactivos y migraciones versionadas.
- Los datos de produccion y las fotos no necesitan salir del dispositivo.

## Esquema actual

### job_records

Guarda identificador, nombre, etapa, fechas y un payload JSON del agregado
`CuttingJob`. El payload conserva material, defectos, plantillas y layouts como
una unidad consistente. Los campos duplicados de nombre y etapa permiten listar
sin decodificar toda la geometria.

### remnant_records

Normaliza material, clave de color, espesor, area, bounding box, poligono y
ubicacion. Esto permite filtrar retales compatibles por SQL antes de reconstruir
la entidad de dominio.

### tool_invocation_records

Registra trabajo, herramienta, argumentos JSON, estado, resumen, duracion y
fecha. Proporciona auditoria del agente y permite explicar una recomendacion.

## Alternativas descartadas como fuente primaria

- Firebase o Supabase: agregan conectividad, autenticacion y costo operativo a
  un flujo que debe funcionar offline. Pueden ser sincronizacion opcional futura.
- Hive o almacenamiento clave-valor: simplifica objetos, pero dificulta consultas
  por compatibilidad, migraciones relacionales y auditoria ordenada.
- Base vectorial: no aporta valor para transacciones de inventario o geometria.
  Solo seria complementaria para busqueda semantica futura.

## Evolucion

1. Migraciones Drift incrementales al cambiar el esquema.
2. Cifrado de base de datos si se almacenan datos comerciales sensibles.
3. Sincronizacion opcional por eventos, nunca requisito para optimizar.
4. Respaldo exportable con consentimiento del usuario.
5. Indices adicionales cuando el inventario real permita medir consultas.

La version actual del esquema es 1 y activa claves foraneas y `PRAGMA optimize`.
