import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class JobRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get stage => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RemnantRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get color => text()();
  TextColumn get colorKey => text()();
  RealColumn get thicknessMm => real()();
  RealColumn get areaMm2 => real()();
  RealColumn get minX => real()();
  RealColumn get minY => real()();
  RealColumn get maxX => real()();
  RealColumn get maxY => real()();
  TextColumn get polygonJson => text()();
  TextColumn get location => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ToolInvocationRecords extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text()();
  TextColumn get toolName => text()();
  TextColumn get argumentsJson => text()();
  TextColumn get status => text()();
  TextColumn get summary => text()();
  IntColumn get elapsedMilliseconds => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [JobRecords, RemnantRecords, ToolInvocationRecords])
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'cutzero',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (!details.wasCreated) {
        await customStatement('PRAGMA optimize');
      }
    },
  );
}
