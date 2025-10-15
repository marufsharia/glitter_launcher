// ... (previous imports and table definition) ...

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// -----------------------------
// TABLE DEFINITION
// -----------------------------
class Apps extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get packageName => text()();

  TextColumn get appName => text()();

  TextColumn get category => text().nullable()(); // Nullable category
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  TextColumn get customIconPath => text().nullable()();

  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastUsed => dateTime().nullable()();

  BlobColumn get icon => blob().nullable()(); // Store app icon bytes
}

// -----------------------------
// DATABASE DEFINITION
// -----------------------------
@DriftDatabase(tables: [Apps])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  // -----------------------------
  // MIGRATION STRATEGY
  // -----------------------------
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(apps, apps.icon);
      }
      if (from < 3) {
        // Safely make category nullable (instead of dropping table)
        await migrator.alterTable(TableMigration(apps));
      }
    },
  );

  // -----------------------------
  // DATABASE CONNECTION
  // -----------------------------
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'glitter.db'));
      return NativeDatabase(file);
    });
  }

  // -----------------------------
  // BATCH OPERATIONS (NEW)
  // -----------------------------

  /// Batch insert multiple apps efficiently
  Future<void> batchInsertApps(List<AppsCompanion> appsList) async {
    await batch((batch) {
      for (final app in appsList) {
        batch.insert(apps, app, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Get single app by package name
  Future<App?> getApp(String packageName) async {
    return await (select(
      apps,
    )..where((a) => a.packageName.equals(packageName))).getSingleOrNull();
  }

  // -----------------------------
  // INSERT OR UPDATE
  // -----------------------------
  Future<void> insertOrUpdateApp(App app) =>
      into(apps).insertOnConflictUpdate(app);

  // -----------------------------
  // SELECT QUERIES
  // -----------------------------

  // Stream of all apps for reactive UI updates
  Stream<List<App>> getAllAppsStream() => select(apps).watch();

  Future<List<App>> getAllApps() => select(apps).get();

  Future<List<App>> getAppsByCategory(String? category) {
    if (category == null) {
      return (select(apps)..where((a) => a.category.isNull())).get();
    } else {
      return (select(apps)..where((a) => a.category.equals(category))).get();
    }
  }

  Future<List<App>> getFrequentApps(int limit) {
    final query = select(apps)
      ..orderBy([
        (t) => OrderingTerm.desc(t.usageCount),
        (t) => OrderingTerm.desc(t.lastUsed),
      ])
      ..where((a) => a.isHidden.equals(false))
      ..limit(limit);
    return query.get();
  }

  // -----------------------------
  // UPDATE QUERIES
  // -----------------------------
  Future<void> updateUsage(String packageName) async {
    final currentApp = await (select(
      apps,
    )..where((a) => a.packageName.equals(packageName))).getSingleOrNull();

    if (currentApp != null) {
      await (update(
        apps,
      )..where((a) => a.packageName.equals(packageName))).write(
        AppsCompanion(
          usageCount: Value(currentApp.usageCount + 1),
          lastUsed: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> hideApp(String packageName, bool hidden) async {
    await (update(apps)..where((a) => a.packageName.equals(packageName))).write(
      AppsCompanion(isHidden: Value(hidden)),
    );
  }

  Future<void> updateCategory(String packageName, String? category) async {
    await (update(apps)..where((a) => a.packageName.equals(packageName))).write(
      AppsCompanion(category: Value(category)),
    );
  }

  Future<void> updateCustomIcon(String packageName, String? path) async {
    await (update(apps)..where((a) => a.packageName.equals(packageName))).write(
      AppsCompanion(customIconPath: Value(path)),
    );
  }

  // -----------------------------
  // DELETE QUERIES
  // -----------------------------
  Future<void> deleteAppByPackage(String packageName) async {
    await (delete(apps)..where((a) => a.packageName.equals(packageName))).go();
  }

  Future<void> deleteAppById(int id) async {
    await (delete(apps)..where((a) => a.id.equals(id))).go();
  }

  Future<void> deleteAllApps() async {
    await delete(apps).go();
  }
}
