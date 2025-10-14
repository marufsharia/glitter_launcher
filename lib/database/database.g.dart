// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppsTable extends Apps with TableInfo<$AppsTable, App> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customIconPathMeta = const VerificationMeta(
    'customIconPath',
  );
  @override
  late final GeneratedColumn<String> customIconPath = GeneratedColumn<String>(
    'custom_icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedMeta = const VerificationMeta(
    'lastUsed',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
    'last_used',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<Uint8List> icon = GeneratedColumn<Uint8List>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    appName,
    category,
    isHidden,
    customIconPath,
    usageCount,
    lastUsed,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<App> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('custom_icon_path')) {
      context.handle(
        _customIconPathMeta,
        customIconPath.isAcceptableOrUnknown(
          data['custom_icon_path']!,
          _customIconPathMeta,
        ),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('last_used')) {
      context.handle(
        _lastUsedMeta,
        lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  App map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return App(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      customIconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_icon_path'],
      ),
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      lastUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $AppsTable createAlias(String alias) {
    return $AppsTable(attachedDatabase, alias);
  }
}

class App extends DataClass implements Insertable<App> {
  final int id;
  final String packageName;
  final String appName;
  final String? category;
  final bool isHidden;
  final String? customIconPath;
  final int usageCount;
  final DateTime? lastUsed;
  final Uint8List? icon;
  const App({
    required this.id,
    required this.packageName,
    required this.appName,
    this.category,
    required this.isHidden,
    this.customIconPath,
    required this.usageCount,
    this.lastUsed,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || customIconPath != null) {
      map['custom_icon_path'] = Variable<String>(customIconPath);
    }
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime>(lastUsed);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<Uint8List>(icon);
    }
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      appName: Value(appName),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isHidden: Value(isHidden),
      customIconPath: customIconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customIconPath),
      usageCount: Value(usageCount),
      lastUsed: lastUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsed),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory App.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return App(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      category: serializer.fromJson<String?>(json['category']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      customIconPath: serializer.fromJson<String?>(json['customIconPath']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
      icon: serializer.fromJson<Uint8List?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'category': serializer.toJson<String?>(category),
      'isHidden': serializer.toJson<bool>(isHidden),
      'customIconPath': serializer.toJson<String?>(customIconPath),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
      'icon': serializer.toJson<Uint8List?>(icon),
    };
  }

  App copyWith({
    int? id,
    String? packageName,
    String? appName,
    Value<String?> category = const Value.absent(),
    bool? isHidden,
    Value<String?> customIconPath = const Value.absent(),
    int? usageCount,
    Value<DateTime?> lastUsed = const Value.absent(),
    Value<Uint8List?> icon = const Value.absent(),
  }) => App(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    category: category.present ? category.value : this.category,
    isHidden: isHidden ?? this.isHidden,
    customIconPath: customIconPath.present
        ? customIconPath.value
        : this.customIconPath,
    usageCount: usageCount ?? this.usageCount,
    lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
    icon: icon.present ? icon.value : this.icon,
  );
  App copyWithCompanion(AppsCompanion data) {
    return App(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      category: data.category.present ? data.category.value : this.category,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      customIconPath: data.customIconPath.present
          ? data.customIconPath.value
          : this.customIconPath,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('App(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('category: $category, ')
          ..write('isHidden: $isHidden, ')
          ..write('customIconPath: $customIconPath, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    appName,
    category,
    isHidden,
    customIconPath,
    usageCount,
    lastUsed,
    $driftBlobEquality.hash(icon),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is App &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.category == this.category &&
          other.isHidden == this.isHidden &&
          other.customIconPath == this.customIconPath &&
          other.usageCount == this.usageCount &&
          other.lastUsed == this.lastUsed &&
          $driftBlobEquality.equals(other.icon, this.icon));
}

class AppsCompanion extends UpdateCompanion<App> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String?> category;
  final Value<bool> isHidden;
  final Value<String?> customIconPath;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsed;
  final Value<Uint8List?> icon;
  const AppsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.category = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.customIconPath = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.icon = const Value.absent(),
  });
  AppsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String appName,
    this.category = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.customIconPath = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.icon = const Value.absent(),
  }) : packageName = Value(packageName),
       appName = Value(appName);
  static Insertable<App> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? category,
    Expression<bool>? isHidden,
    Expression<String>? customIconPath,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsed,
    Expression<Uint8List>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (category != null) 'category': category,
      if (isHidden != null) 'is_hidden': isHidden,
      if (customIconPath != null) 'custom_icon_path': customIconPath,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsed != null) 'last_used': lastUsed,
      if (icon != null) 'icon': icon,
    });
  }

  AppsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? appName,
    Value<String?>? category,
    Value<bool>? isHidden,
    Value<String?>? customIconPath,
    Value<int>? usageCount,
    Value<DateTime?>? lastUsed,
    Value<Uint8List?>? icon,
  }) {
    return AppsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      category: category ?? this.category,
      isHidden: isHidden ?? this.isHidden,
      customIconPath: customIconPath ?? this.customIconPath,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (customIconPath.present) {
      map['custom_icon_path'] = Variable<String>(customIconPath.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    if (icon.present) {
      map['icon'] = Variable<Uint8List>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('category: $category, ')
          ..write('isHidden: $isHidden, ')
          ..write('customIconPath: $customIconPath, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppsTable apps = $AppsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [apps];
}

typedef $$AppsTableCreateCompanionBuilder =
    AppsCompanion Function({
      Value<int> id,
      required String packageName,
      required String appName,
      Value<String?> category,
      Value<bool> isHidden,
      Value<String?> customIconPath,
      Value<int> usageCount,
      Value<DateTime?> lastUsed,
      Value<Uint8List?> icon,
    });
typedef $$AppsTableUpdateCompanionBuilder =
    AppsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> appName,
      Value<String?> category,
      Value<bool> isHidden,
      Value<String?> customIconPath,
      Value<int> usageCount,
      Value<DateTime?> lastUsed,
      Value<Uint8List?> icon,
    });

class $$AppsTableFilterComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customIconPath => $composableBuilder(
    column: $table.customIconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppsTableOrderingComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customIconPath => $composableBuilder(
    column: $table.customIconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<String> get customIconPath => $composableBuilder(
    column: $table.customIconPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);

  GeneratedColumn<Uint8List> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$AppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppsTable,
          App,
          $$AppsTableFilterComposer,
          $$AppsTableOrderingComposer,
          $$AppsTableAnnotationComposer,
          $$AppsTableCreateCompanionBuilder,
          $$AppsTableUpdateCompanionBuilder,
          (App, BaseReferences<_$AppDatabase, $AppsTable, App>),
          App,
          PrefetchHooks Function()
        > {
  $$AppsTableTableManager(_$AppDatabase db, $AppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String?> customIconPath = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime?> lastUsed = const Value.absent(),
                Value<Uint8List?> icon = const Value.absent(),
              }) => AppsCompanion(
                id: id,
                packageName: packageName,
                appName: appName,
                category: category,
                isHidden: isHidden,
                customIconPath: customIconPath,
                usageCount: usageCount,
                lastUsed: lastUsed,
                icon: icon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String appName,
                Value<String?> category = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String?> customIconPath = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime?> lastUsed = const Value.absent(),
                Value<Uint8List?> icon = const Value.absent(),
              }) => AppsCompanion.insert(
                id: id,
                packageName: packageName,
                appName: appName,
                category: category,
                isHidden: isHidden,
                customIconPath: customIconPath,
                usageCount: usageCount,
                lastUsed: lastUsed,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppsTable,
      App,
      $$AppsTableFilterComposer,
      $$AppsTableOrderingComposer,
      $$AppsTableAnnotationComposer,
      $$AppsTableCreateCompanionBuilder,
      $$AppsTableUpdateCompanionBuilder,
      (App, BaseReferences<_$AppDatabase, $AppsTable, App>),
      App,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppsTableTableManager get apps => $$AppsTableTableManager(_db, _db.apps);
}
