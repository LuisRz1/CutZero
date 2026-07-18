import 'package:cutzero/core/domain/geometry.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
import 'package:cutzero/features/cutting_job/domain/models.dart';
import 'package:cutzero/features/cutting_job/infrastructure/demo_fixture.dart';
import 'package:cutzero/features/cutting_job/infrastructure/persistence/cutting_job_mapper.dart';
import 'package:cutzero/features/cutting_job/infrastructure/persistence/drift_repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  const mapper = CuttingJobMapper();

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('persists and restores a complete cutting job', () async {
    final repository = DriftCuttingJobRepository(database, mapper);
    final job = DemoFixture.createJob();

    await repository.save(job);
    final restored = await repository.findById(job.id);

    expect(restored, isNotNull);
    expect(restored!.name, job.name);
    expect(restored.parts, hasLength(3));
    expect(restored.instances, hasLength(10));
    expect(restored.material.defects, hasLength(1));
    expect(restored.material.widthMm, 1100);
  });

  test('finds the smallest compatible remnant first', () async {
    final repository = DriftRemnantRepository(database, mapper);
    final small = Remnant(
      id: 'small',
      name: 'Retazo pequeno',
      kind: MaterialKind.eva,
      color: 'Celeste',
      thicknessMm: 2,
      polygon: Polygon2D.rectangle(width: 200, height: 200),
      location: 'A-01',
    );
    final large = Remnant(
      id: 'large',
      name: 'Retazo grande',
      kind: MaterialKind.eva,
      color: 'Celeste',
      thicknessMm: 2,
      polygon: Polygon2D.rectangle(width: 400, height: 300),
      location: 'A-02',
    );
    await repository.save(large);
    await repository.save(small);

    final compatible = await repository.findCompatible(
      kind: MaterialKind.eva,
      color: 'CELESTE',
      minAreaMm2: 30000,
    );

    expect(compatible.map((item) => item.id), ['small', 'large']);
  });

  test('stores tool invocations in chronological order', () async {
    final repository = DriftToolInvocationRepository(database, mapper);
    final first = ToolInvocation(
      id: 'tool-1',
      jobId: 'job-1',
      toolName: 'search_remnants',
      arguments: const {'material': 'eva'},
      status: ToolInvocationStatus.success,
      createdAt: DateTime.utc(2026, 7, 18, 1),
    );
    final second = ToolInvocation(
      id: 'tool-2',
      jobId: 'job-1',
      toolName: 'run_nesting',
      arguments: const {'objective': 'materialEfficiency'},
      status: ToolInvocationStatus.success,
      createdAt: DateTime.utc(2026, 7, 18, 2),
    );
    await repository.append(second);
    await repository.append(first);

    final records = await repository.watchForJob('job-1').first;

    expect(records.map((item) => item.id), ['tool-1', 'tool-2']);
  });
}
