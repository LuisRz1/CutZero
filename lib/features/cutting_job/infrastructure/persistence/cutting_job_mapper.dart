import 'dart:convert';

import '../../../../core/domain/geometry.dart';
import '../../domain/models.dart';

final class CuttingJobMapper {
  const CuttingJobMapper();

  String encodeJob(CuttingJob job) => jsonEncode({
    'id': job.id,
    'name': job.name,
    'gapMm': job.gapMm,
    'stage': job.stage.name,
    'instruction': job.instruction,
    'createdAt': job.createdAt.toIso8601String(),
    'material': _encodeMaterial(job.material),
    'parts': job.parts.map(_encodePart).toList(growable: false),
    'layouts': job.layouts.map(_encodeLayout).toList(growable: false),
  });

  CuttingJob decodeJob(String value) {
    final json = jsonDecode(value) as Map<String, Object?>;
    return CuttingJob(
      id: json['id']! as String,
      name: json['name']! as String,
      gapMm: (json['gapMm']! as num).toDouble(),
      stage: CuttingJobStage.values.byName(json['stage']! as String),
      instruction: json['instruction']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
      material: _decodeMaterial(_objectMap(json['material'])),
      parts: _objectList(
        json['parts'],
      ).map((item) => _decodePart(_objectMap(item))).toList(growable: false),
      layouts: _objectList(
        json['layouts'],
      ).map((item) => _decodeLayout(_objectMap(item))).toList(growable: false),
    );
  }

  String encodeRemnantPolygon(Remnant remnant) =>
      jsonEncode(remnant.polygon.toJson());

  Polygon2D decodePolygon(String value) =>
      Polygon2D.fromJson(jsonDecode(value) as List<Object?>);

  String encodeArguments(Map<String, Object?> arguments) =>
      jsonEncode(arguments);

  Map<String, Object?> decodeArguments(String value) =>
      _objectMap(jsonDecode(value));

  Map<String, Object?> _encodeMaterial(MaterialSheet material) => {
    'id': material.id,
    'name': material.name,
    'kind': material.kind.name,
    'widthMm': material.widthMm,
    'heightMm': material.heightMm,
    'costPerSquareMeter': material.costPerSquareMeter,
    'color': material.color,
    'thicknessMm': material.thicknessMm,
    'defects': material.defects
        .map(
          (defect) => {
            'id': defect.id,
            'name': defect.name,
            'polygon': defect.polygon.toJson(),
          },
        )
        .toList(growable: false),
  };

  MaterialSheet _decodeMaterial(Map<String, Object?> json) => MaterialSheet(
    id: json['id']! as String,
    name: json['name']! as String,
    kind: MaterialKind.values.byName(json['kind']! as String),
    widthMm: (json['widthMm']! as num).toDouble(),
    heightMm: (json['heightMm']! as num).toDouble(),
    costPerSquareMeter: (json['costPerSquareMeter']! as num).toDouble(),
    color: json['color']! as String,
    thicknessMm: (json['thicknessMm']! as num).toDouble(),
    defects: _objectList(json['defects'])
        .map((item) {
          final defect = _objectMap(item);
          return DefectZone(
            id: defect['id']! as String,
            name: defect['name']! as String,
            polygon: Polygon2D.fromJson(_objectList(defect['polygon'])),
          );
        })
        .toList(growable: false),
  );

  Map<String, Object?> _encodePart(PartTemplate part) => {
    'id': part.id,
    'name': part.name,
    'polygon': part.polygon.toJson(),
    'quantity': part.quantity,
    'allowedRotations': part.allowedRotations,
    'grainLocked': part.grainLocked,
  };

  PartTemplate _decodePart(Map<String, Object?> json) => PartTemplate(
    id: json['id']! as String,
    name: json['name']! as String,
    polygon: Polygon2D.fromJson(_objectList(json['polygon'])),
    quantity: json['quantity']! as int,
    allowedRotations: _objectList(
      json['allowedRotations'],
    ).map((value) => value! as int).toList(growable: false),
    grainLocked: json['grainLocked']! as bool,
  );

  Map<String, Object?> _encodeLayout(NestingLayout layout) => {
    'id': layout.id,
    'objective': layout.objective.name,
    'elapsedMicroseconds': layout.elapsed.inMicroseconds,
    'seed': layout.seed,
    'metrics': {
      'partsAreaMm2': layout.metrics.partsAreaMm2,
      'sheetAreaMm2': layout.metrics.sheetAreaMm2,
      'usedEnvelopeAreaMm2': layout.metrics.usedEnvelopeAreaMm2,
      'largestReusableRemnantMm2': layout.metrics.largestReusableRemnantMm2,
      'estimatedWasteCost': layout.metrics.estimatedWasteCost,
    },
    'placements': layout.placements
        .map(
          (placement) => {
            'instanceId': placement.instanceId,
            'templateId': placement.templateId,
            'name': placement.name,
            'polygon': placement.polygon.toJson(),
            'rotationDegrees': placement.rotationDegrees,
          },
        )
        .toList(growable: false),
  };

  NestingLayout _decodeLayout(Map<String, Object?> json) {
    final metrics = _objectMap(json['metrics']);
    return NestingLayout(
      id: json['id']! as String,
      objective: OptimizationObjective.values.byName(
        json['objective']! as String,
      ),
      elapsed: Duration(microseconds: json['elapsedMicroseconds']! as int),
      seed: json['seed']! as int,
      metrics: LayoutMetrics(
        partsAreaMm2: (metrics['partsAreaMm2']! as num).toDouble(),
        sheetAreaMm2: (metrics['sheetAreaMm2']! as num).toDouble(),
        usedEnvelopeAreaMm2: (metrics['usedEnvelopeAreaMm2']! as num)
            .toDouble(),
        largestReusableRemnantMm2:
            (metrics['largestReusableRemnantMm2']! as num).toDouble(),
        estimatedWasteCost: (metrics['estimatedWasteCost']! as num).toDouble(),
      ),
      placements: _objectList(json['placements'])
          .map((item) {
            final placement = _objectMap(item);
            return Placement(
              instanceId: placement['instanceId']! as String,
              templateId: placement['templateId']! as String,
              name: placement['name']! as String,
              polygon: Polygon2D.fromJson(_objectList(placement['polygon'])),
              rotationDegrees: placement['rotationDegrees']! as int,
            );
          })
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _objectMap(Object? value) =>
      (value! as Map<Object?, Object?>).map(
        (key, item) => MapEntry(key! as String, item),
      );

  static List<Object?> _objectList(Object? value) => value! as List<Object?>;
}
