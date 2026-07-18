import 'package:drift/drift.dart';

import '../../../../core/infrastructure/database/app_database.dart';
import '../../application/ports.dart';
import '../../domain/models.dart';
import 'cutting_job_mapper.dart';

final class DriftCuttingJobRepository implements CuttingJobRepository {
  const DriftCuttingJobRepository(this.database, this.mapper);

  final AppDatabase database;
  final CuttingJobMapper mapper;

  @override
  Future<CuttingJob?> findById(String id) async {
    final query = database.select(database.jobRecords)
      ..where((table) => table.id.equals(id));
    final record = await query.getSingleOrNull();
    return record == null ? null : mapper.decodeJob(record.payloadJson);
  }

  @override
  Future<void> save(CuttingJob job) => database
      .into(database.jobRecords)
      .insertOnConflictUpdate(
        JobRecordsCompanion.insert(
          id: job.id,
          name: job.name,
          stage: job.stage.name,
          payloadJson: mapper.encodeJob(job),
          createdAt: job.createdAt,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

  @override
  Stream<List<CuttingJob>> watchAll() {
    final query = database.select(database.jobRecords)
      ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]);
    return query.watch().map(
      (records) => records
          .map((record) => mapper.decodeJob(record.payloadJson))
          .toList(growable: false),
    );
  }
}

final class DriftRemnantRepository implements RemnantRepository {
  const DriftRemnantRepository(this.database, this.mapper);

  final AppDatabase database;
  final CuttingJobMapper mapper;

  @override
  Future<List<Remnant>> findCompatible({
    required MaterialKind kind,
    required String color,
    required double minAreaMm2,
  }) async {
    final query = database.select(database.remnantRecords)
      ..where(
        (table) =>
            table.kind.equals(kind.name) &
            table.colorKey.equals(color.trim().toLowerCase()) &
            table.areaMm2.isBiggerOrEqualValue(minAreaMm2),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.areaMm2)]);
    return (await query.get()).map(_toRemnant).toList(growable: false);
  }

  @override
  Future<void> save(Remnant remnant) {
    final bounds = remnant.polygon.bounds;
    return database
        .into(database.remnantRecords)
        .insertOnConflictUpdate(
          RemnantRecordsCompanion.insert(
            id: remnant.id,
            name: remnant.name,
            kind: remnant.kind.name,
            color: remnant.color,
            colorKey: remnant.color.trim().toLowerCase(),
            thicknessMm: remnant.thicknessMm,
            areaMm2: remnant.polygon.area,
            minX: bounds.minX,
            minY: bounds.minY,
            maxX: bounds.maxX,
            maxY: bounds.maxY,
            polygonJson: mapper.encodeRemnantPolygon(remnant),
            location: remnant.location,
            createdAt: remnant.createdAt,
          ),
        );
  }

  @override
  Stream<List<Remnant>> watchAll() {
    final query = database.select(database.remnantRecords)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    return query.watch().map(
      (records) => records.map(_toRemnant).toList(growable: false),
    );
  }

  Remnant _toRemnant(RemnantRecord record) => Remnant(
    id: record.id,
    name: record.name,
    kind: MaterialKind.values.byName(record.kind),
    color: record.color,
    thicknessMm: record.thicknessMm,
    polygon: mapper.decodePolygon(record.polygonJson),
    location: record.location,
    createdAt: record.createdAt,
  );
}

final class DriftToolInvocationRepository implements ToolInvocationRepository {
  const DriftToolInvocationRepository(this.database, this.mapper);

  final AppDatabase database;
  final CuttingJobMapper mapper;

  @override
  Future<void> append(ToolInvocation invocation) => database
      .into(database.toolInvocationRecords)
      .insertOnConflictUpdate(
        ToolInvocationRecordsCompanion.insert(
          id: invocation.id,
          jobId: invocation.jobId,
          toolName: invocation.toolName,
          argumentsJson: mapper.encodeArguments(invocation.arguments),
          status: invocation.status.name,
          summary: invocation.summary,
          elapsedMilliseconds: invocation.elapsed.inMilliseconds,
          createdAt: invocation.createdAt,
        ),
      );

  @override
  Stream<List<ToolInvocation>> watchForJob(String jobId) {
    final query = database.select(database.toolInvocationRecords)
      ..where((table) => table.jobId.equals(jobId))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    return query.watch().map(
      (records) => records
          .map(
            (record) => ToolInvocation(
              id: record.id,
              jobId: record.jobId,
              toolName: record.toolName,
              arguments: mapper.decodeArguments(record.argumentsJson),
              status: ToolInvocationStatus.values.byName(record.status),
              summary: record.summary,
              elapsed: Duration(milliseconds: record.elapsedMilliseconds),
              createdAt: record.createdAt,
            ),
          )
          .toList(growable: false),
    );
  }
}
