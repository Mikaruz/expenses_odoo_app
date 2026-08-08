// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_database.dart';

// ignore_for_file: type=lint
class $LocalExpensesTable extends LocalExpenses
    with TableInfo<$LocalExpensesTable, LocalExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountScopeMeta = const VerificationMeta(
    'accountScope',
  );
  @override
  late final GeneratedColumn<String> accountScope = GeneratedColumn<String>(
    'account_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rucMeta = const VerificationMeta('ruc');
  @override
  late final GeneratedColumn<String> ruc = GeneratedColumn<String>(
    'ruc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _documentNumberMeta = const VerificationMeta(
    'documentNumber',
  );
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
    'document_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<String> expenseDate = GeneratedColumn<String>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subtotalCentsMeta = const VerificationMeta(
    'subtotalCents',
  );
  @override
  late final GeneratedColumn<int> subtotalCents = GeneratedColumn<int>(
    'subtotal_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _igvCentsMeta = const VerificationMeta(
    'igvCents',
  );
  @override
  late final GeneratedColumn<int> igvCents = GeneratedColumn<int>(
    'igv_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxTreatmentMeta = const VerificationMeta(
    'taxTreatment',
  );
  @override
  late final GeneratedColumn<String> taxTreatment = GeneratedColumn<String>(
    'tax_treatment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxIdMeta = const VerificationMeta('taxId');
  @override
  late final GeneratedColumn<int> taxId = GeneratedColumn<int>(
    'tax_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxNameMeta = const VerificationMeta(
    'taxName',
  );
  @override
  late final GeneratedColumn<String> taxName = GeneratedColumn<String>(
    'tax_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxRatePercentageMeta = const VerificationMeta(
    'taxRatePercentage',
  );
  @override
  late final GeneratedColumn<double> taxRatePercentage =
      GeneratedColumn<double>(
        'tax_rate_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receiptRelativePathMeta =
      const VerificationMeta('receiptRelativePath');
  @override
  late final GeneratedColumn<String> receiptRelativePath =
      GeneratedColumn<String>(
        'receipt_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountScope,
    remoteId,
    ruc,
    businessName,
    documentType,
    documentNumber,
    expenseDate,
    subtotalCents,
    igvCents,
    totalCents,
    taxTreatment,
    taxId,
    taxName,
    taxRatePercentage,
    receiptRelativePath,
    syncStatus,
    lastSyncError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_scope')) {
      context.handle(
        _accountScopeMeta,
        accountScope.isAcceptableOrUnknown(
          data['account_scope']!,
          _accountScopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountScopeMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('ruc')) {
      context.handle(
        _rucMeta,
        ruc.isAcceptableOrUnknown(data['ruc']!, _rucMeta),
      );
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    }
    if (data.containsKey('document_number')) {
      context.handle(
        _documentNumberMeta,
        documentNumber.isAcceptableOrUnknown(
          data['document_number']!,
          _documentNumberMeta,
        ),
      );
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    }
    if (data.containsKey('subtotal_cents')) {
      context.handle(
        _subtotalCentsMeta,
        subtotalCents.isAcceptableOrUnknown(
          data['subtotal_cents']!,
          _subtotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalCentsMeta);
    }
    if (data.containsKey('igv_cents')) {
      context.handle(
        _igvCentsMeta,
        igvCents.isAcceptableOrUnknown(data['igv_cents']!, _igvCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_igvCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('tax_treatment')) {
      context.handle(
        _taxTreatmentMeta,
        taxTreatment.isAcceptableOrUnknown(
          data['tax_treatment']!,
          _taxTreatmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taxTreatmentMeta);
    }
    if (data.containsKey('tax_id')) {
      context.handle(
        _taxIdMeta,
        taxId.isAcceptableOrUnknown(data['tax_id']!, _taxIdMeta),
      );
    }
    if (data.containsKey('tax_name')) {
      context.handle(
        _taxNameMeta,
        taxName.isAcceptableOrUnknown(data['tax_name']!, _taxNameMeta),
      );
    }
    if (data.containsKey('tax_rate_percentage')) {
      context.handle(
        _taxRatePercentageMeta,
        taxRatePercentage.isAcceptableOrUnknown(
          data['tax_rate_percentage']!,
          _taxRatePercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taxRatePercentageMeta);
    }
    if (data.containsKey('receipt_relative_path')) {
      context.handle(
        _receiptRelativePathMeta,
        receiptRelativePath.isAcceptableOrUnknown(
          data['receipt_relative_path']!,
          _receiptRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receiptRelativePathMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_scope'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      ruc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruc'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      documentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_number'],
      )!,
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_date'],
      )!,
      subtotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_cents'],
      )!,
      igvCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}igv_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      taxTreatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_treatment'],
      )!,
      taxId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_id'],
      ),
      taxName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_name'],
      ),
      taxRatePercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_rate_percentage'],
      )!,
      receiptRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_relative_path'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalExpensesTable createAlias(String alias) {
    return $LocalExpensesTable(attachedDatabase, alias);
  }
}

class LocalExpenseRow extends DataClass implements Insertable<LocalExpenseRow> {
  final String id;
  final String accountScope;
  final int? remoteId;
  final String ruc;
  final String businessName;
  final String documentType;
  final String documentNumber;
  final String expenseDate;
  final int subtotalCents;
  final int igvCents;
  final int totalCents;
  final String taxTreatment;
  final int? taxId;
  final String? taxName;
  final double taxRatePercentage;
  final String receiptRelativePath;
  final String syncStatus;
  final String? lastSyncError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalExpenseRow({
    required this.id,
    required this.accountScope,
    this.remoteId,
    required this.ruc,
    required this.businessName,
    required this.documentType,
    required this.documentNumber,
    required this.expenseDate,
    required this.subtotalCents,
    required this.igvCents,
    required this.totalCents,
    required this.taxTreatment,
    this.taxId,
    this.taxName,
    required this.taxRatePercentage,
    required this.receiptRelativePath,
    required this.syncStatus,
    this.lastSyncError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_scope'] = Variable<String>(accountScope);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['ruc'] = Variable<String>(ruc);
    map['business_name'] = Variable<String>(businessName);
    map['document_type'] = Variable<String>(documentType);
    map['document_number'] = Variable<String>(documentNumber);
    map['expense_date'] = Variable<String>(expenseDate);
    map['subtotal_cents'] = Variable<int>(subtotalCents);
    map['igv_cents'] = Variable<int>(igvCents);
    map['total_cents'] = Variable<int>(totalCents);
    map['tax_treatment'] = Variable<String>(taxTreatment);
    if (!nullToAbsent || taxId != null) {
      map['tax_id'] = Variable<int>(taxId);
    }
    if (!nullToAbsent || taxName != null) {
      map['tax_name'] = Variable<String>(taxName);
    }
    map['tax_rate_percentage'] = Variable<double>(taxRatePercentage);
    map['receipt_relative_path'] = Variable<String>(receiptRelativePath);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalExpensesCompanion toCompanion(bool nullToAbsent) {
    return LocalExpensesCompanion(
      id: Value(id),
      accountScope: Value(accountScope),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      ruc: Value(ruc),
      businessName: Value(businessName),
      documentType: Value(documentType),
      documentNumber: Value(documentNumber),
      expenseDate: Value(expenseDate),
      subtotalCents: Value(subtotalCents),
      igvCents: Value(igvCents),
      totalCents: Value(totalCents),
      taxTreatment: Value(taxTreatment),
      taxId: taxId == null && nullToAbsent
          ? const Value.absent()
          : Value(taxId),
      taxName: taxName == null && nullToAbsent
          ? const Value.absent()
          : Value(taxName),
      taxRatePercentage: Value(taxRatePercentage),
      receiptRelativePath: Value(receiptRelativePath),
      syncStatus: Value(syncStatus),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      accountScope: serializer.fromJson<String>(json['accountScope']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      ruc: serializer.fromJson<String>(json['ruc']),
      businessName: serializer.fromJson<String>(json['businessName']),
      documentType: serializer.fromJson<String>(json['documentType']),
      documentNumber: serializer.fromJson<String>(json['documentNumber']),
      expenseDate: serializer.fromJson<String>(json['expenseDate']),
      subtotalCents: serializer.fromJson<int>(json['subtotalCents']),
      igvCents: serializer.fromJson<int>(json['igvCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      taxTreatment: serializer.fromJson<String>(json['taxTreatment']),
      taxId: serializer.fromJson<int?>(json['taxId']),
      taxName: serializer.fromJson<String?>(json['taxName']),
      taxRatePercentage: serializer.fromJson<double>(json['taxRatePercentage']),
      receiptRelativePath: serializer.fromJson<String>(
        json['receiptRelativePath'],
      ),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountScope': serializer.toJson<String>(accountScope),
      'remoteId': serializer.toJson<int?>(remoteId),
      'ruc': serializer.toJson<String>(ruc),
      'businessName': serializer.toJson<String>(businessName),
      'documentType': serializer.toJson<String>(documentType),
      'documentNumber': serializer.toJson<String>(documentNumber),
      'expenseDate': serializer.toJson<String>(expenseDate),
      'subtotalCents': serializer.toJson<int>(subtotalCents),
      'igvCents': serializer.toJson<int>(igvCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'taxTreatment': serializer.toJson<String>(taxTreatment),
      'taxId': serializer.toJson<int?>(taxId),
      'taxName': serializer.toJson<String?>(taxName),
      'taxRatePercentage': serializer.toJson<double>(taxRatePercentage),
      'receiptRelativePath': serializer.toJson<String>(receiptRelativePath),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalExpenseRow copyWith({
    String? id,
    String? accountScope,
    Value<int?> remoteId = const Value.absent(),
    String? ruc,
    String? businessName,
    String? documentType,
    String? documentNumber,
    String? expenseDate,
    int? subtotalCents,
    int? igvCents,
    int? totalCents,
    String? taxTreatment,
    Value<int?> taxId = const Value.absent(),
    Value<String?> taxName = const Value.absent(),
    double? taxRatePercentage,
    String? receiptRelativePath,
    String? syncStatus,
    Value<String?> lastSyncError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalExpenseRow(
    id: id ?? this.id,
    accountScope: accountScope ?? this.accountScope,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    ruc: ruc ?? this.ruc,
    businessName: businessName ?? this.businessName,
    documentType: documentType ?? this.documentType,
    documentNumber: documentNumber ?? this.documentNumber,
    expenseDate: expenseDate ?? this.expenseDate,
    subtotalCents: subtotalCents ?? this.subtotalCents,
    igvCents: igvCents ?? this.igvCents,
    totalCents: totalCents ?? this.totalCents,
    taxTreatment: taxTreatment ?? this.taxTreatment,
    taxId: taxId.present ? taxId.value : this.taxId,
    taxName: taxName.present ? taxName.value : this.taxName,
    taxRatePercentage: taxRatePercentage ?? this.taxRatePercentage,
    receiptRelativePath: receiptRelativePath ?? this.receiptRelativePath,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalExpenseRow copyWithCompanion(LocalExpensesCompanion data) {
    return LocalExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      accountScope: data.accountScope.present
          ? data.accountScope.value
          : this.accountScope,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ruc: data.ruc.present ? data.ruc.value : this.ruc,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      subtotalCents: data.subtotalCents.present
          ? data.subtotalCents.value
          : this.subtotalCents,
      igvCents: data.igvCents.present ? data.igvCents.value : this.igvCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      taxTreatment: data.taxTreatment.present
          ? data.taxTreatment.value
          : this.taxTreatment,
      taxId: data.taxId.present ? data.taxId.value : this.taxId,
      taxName: data.taxName.present ? data.taxName.value : this.taxName,
      taxRatePercentage: data.taxRatePercentage.present
          ? data.taxRatePercentage.value
          : this.taxRatePercentage,
      receiptRelativePath: data.receiptRelativePath.present
          ? data.receiptRelativePath.value
          : this.receiptRelativePath,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpenseRow(')
          ..write('id: $id, ')
          ..write('accountScope: $accountScope, ')
          ..write('remoteId: $remoteId, ')
          ..write('ruc: $ruc, ')
          ..write('businessName: $businessName, ')
          ..write('documentType: $documentType, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('igvCents: $igvCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('taxTreatment: $taxTreatment, ')
          ..write('taxId: $taxId, ')
          ..write('taxName: $taxName, ')
          ..write('taxRatePercentage: $taxRatePercentage, ')
          ..write('receiptRelativePath: $receiptRelativePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountScope,
    remoteId,
    ruc,
    businessName,
    documentType,
    documentNumber,
    expenseDate,
    subtotalCents,
    igvCents,
    totalCents,
    taxTreatment,
    taxId,
    taxName,
    taxRatePercentage,
    receiptRelativePath,
    syncStatus,
    lastSyncError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExpenseRow &&
          other.id == this.id &&
          other.accountScope == this.accountScope &&
          other.remoteId == this.remoteId &&
          other.ruc == this.ruc &&
          other.businessName == this.businessName &&
          other.documentType == this.documentType &&
          other.documentNumber == this.documentNumber &&
          other.expenseDate == this.expenseDate &&
          other.subtotalCents == this.subtotalCents &&
          other.igvCents == this.igvCents &&
          other.totalCents == this.totalCents &&
          other.taxTreatment == this.taxTreatment &&
          other.taxId == this.taxId &&
          other.taxName == this.taxName &&
          other.taxRatePercentage == this.taxRatePercentage &&
          other.receiptRelativePath == this.receiptRelativePath &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncError == this.lastSyncError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalExpensesCompanion extends UpdateCompanion<LocalExpenseRow> {
  final Value<String> id;
  final Value<String> accountScope;
  final Value<int?> remoteId;
  final Value<String> ruc;
  final Value<String> businessName;
  final Value<String> documentType;
  final Value<String> documentNumber;
  final Value<String> expenseDate;
  final Value<int> subtotalCents;
  final Value<int> igvCents;
  final Value<int> totalCents;
  final Value<String> taxTreatment;
  final Value<int?> taxId;
  final Value<String?> taxName;
  final Value<double> taxRatePercentage;
  final Value<String> receiptRelativePath;
  final Value<String> syncStatus;
  final Value<String?> lastSyncError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalExpensesCompanion({
    this.id = const Value.absent(),
    this.accountScope = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.ruc = const Value.absent(),
    this.businessName = const Value.absent(),
    this.documentType = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.subtotalCents = const Value.absent(),
    this.igvCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.taxTreatment = const Value.absent(),
    this.taxId = const Value.absent(),
    this.taxName = const Value.absent(),
    this.taxRatePercentage = const Value.absent(),
    this.receiptRelativePath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpensesCompanion.insert({
    required String id,
    required String accountScope,
    this.remoteId = const Value.absent(),
    this.ruc = const Value.absent(),
    this.businessName = const Value.absent(),
    this.documentType = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.expenseDate = const Value.absent(),
    required int subtotalCents,
    required int igvCents,
    required int totalCents,
    required String taxTreatment,
    this.taxId = const Value.absent(),
    this.taxName = const Value.absent(),
    required double taxRatePercentage,
    required String receiptRelativePath,
    required String syncStatus,
    this.lastSyncError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountScope = Value(accountScope),
       subtotalCents = Value(subtotalCents),
       igvCents = Value(igvCents),
       totalCents = Value(totalCents),
       taxTreatment = Value(taxTreatment),
       taxRatePercentage = Value(taxRatePercentage),
       receiptRelativePath = Value(receiptRelativePath),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? accountScope,
    Expression<int>? remoteId,
    Expression<String>? ruc,
    Expression<String>? businessName,
    Expression<String>? documentType,
    Expression<String>? documentNumber,
    Expression<String>? expenseDate,
    Expression<int>? subtotalCents,
    Expression<int>? igvCents,
    Expression<int>? totalCents,
    Expression<String>? taxTreatment,
    Expression<int>? taxId,
    Expression<String>? taxName,
    Expression<double>? taxRatePercentage,
    Expression<String>? receiptRelativePath,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountScope != null) 'account_scope': accountScope,
      if (remoteId != null) 'remote_id': remoteId,
      if (ruc != null) 'ruc': ruc,
      if (businessName != null) 'business_name': businessName,
      if (documentType != null) 'document_type': documentType,
      if (documentNumber != null) 'document_number': documentNumber,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (subtotalCents != null) 'subtotal_cents': subtotalCents,
      if (igvCents != null) 'igv_cents': igvCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (taxTreatment != null) 'tax_treatment': taxTreatment,
      if (taxId != null) 'tax_id': taxId,
      if (taxName != null) 'tax_name': taxName,
      if (taxRatePercentage != null) 'tax_rate_percentage': taxRatePercentage,
      if (receiptRelativePath != null)
        'receipt_relative_path': receiptRelativePath,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? accountScope,
    Value<int?>? remoteId,
    Value<String>? ruc,
    Value<String>? businessName,
    Value<String>? documentType,
    Value<String>? documentNumber,
    Value<String>? expenseDate,
    Value<int>? subtotalCents,
    Value<int>? igvCents,
    Value<int>? totalCents,
    Value<String>? taxTreatment,
    Value<int?>? taxId,
    Value<String?>? taxName,
    Value<double>? taxRatePercentage,
    Value<String>? receiptRelativePath,
    Value<String>? syncStatus,
    Value<String?>? lastSyncError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalExpensesCompanion(
      id: id ?? this.id,
      accountScope: accountScope ?? this.accountScope,
      remoteId: remoteId ?? this.remoteId,
      ruc: ruc ?? this.ruc,
      businessName: businessName ?? this.businessName,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      expenseDate: expenseDate ?? this.expenseDate,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      igvCents: igvCents ?? this.igvCents,
      totalCents: totalCents ?? this.totalCents,
      taxTreatment: taxTreatment ?? this.taxTreatment,
      taxId: taxId ?? this.taxId,
      taxName: taxName ?? this.taxName,
      taxRatePercentage: taxRatePercentage ?? this.taxRatePercentage,
      receiptRelativePath: receiptRelativePath ?? this.receiptRelativePath,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountScope.present) {
      map['account_scope'] = Variable<String>(accountScope.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (ruc.present) {
      map['ruc'] = Variable<String>(ruc.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<String>(expenseDate.value);
    }
    if (subtotalCents.present) {
      map['subtotal_cents'] = Variable<int>(subtotalCents.value);
    }
    if (igvCents.present) {
      map['igv_cents'] = Variable<int>(igvCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (taxTreatment.present) {
      map['tax_treatment'] = Variable<String>(taxTreatment.value);
    }
    if (taxId.present) {
      map['tax_id'] = Variable<int>(taxId.value);
    }
    if (taxName.present) {
      map['tax_name'] = Variable<String>(taxName.value);
    }
    if (taxRatePercentage.present) {
      map['tax_rate_percentage'] = Variable<double>(taxRatePercentage.value);
    }
    if (receiptRelativePath.present) {
      map['receipt_relative_path'] = Variable<String>(
        receiptRelativePath.value,
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpensesCompanion(')
          ..write('id: $id, ')
          ..write('accountScope: $accountScope, ')
          ..write('remoteId: $remoteId, ')
          ..write('ruc: $ruc, ')
          ..write('businessName: $businessName, ')
          ..write('documentType: $documentType, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('igvCents: $igvCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('taxTreatment: $taxTreatment, ')
          ..write('taxId: $taxId, ')
          ..write('taxName: $taxName, ')
          ..write('taxRatePercentage: $taxRatePercentage, ')
          ..write('receiptRelativePath: $receiptRelativePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ExpensesDatabase extends GeneratedDatabase {
  _$ExpensesDatabase(QueryExecutor e) : super(e);
  $ExpensesDatabaseManager get managers => $ExpensesDatabaseManager(this);
  late final $LocalExpensesTable localExpenses = $LocalExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localExpenses];
}

typedef $$LocalExpensesTableCreateCompanionBuilder =
    LocalExpensesCompanion Function({
      required String id,
      required String accountScope,
      Value<int?> remoteId,
      Value<String> ruc,
      Value<String> businessName,
      Value<String> documentType,
      Value<String> documentNumber,
      Value<String> expenseDate,
      required int subtotalCents,
      required int igvCents,
      required int totalCents,
      required String taxTreatment,
      Value<int?> taxId,
      Value<String?> taxName,
      required double taxRatePercentage,
      required String receiptRelativePath,
      required String syncStatus,
      Value<String?> lastSyncError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalExpensesTableUpdateCompanionBuilder =
    LocalExpensesCompanion Function({
      Value<String> id,
      Value<String> accountScope,
      Value<int?> remoteId,
      Value<String> ruc,
      Value<String> businessName,
      Value<String> documentType,
      Value<String> documentNumber,
      Value<String> expenseDate,
      Value<int> subtotalCents,
      Value<int> igvCents,
      Value<int> totalCents,
      Value<String> taxTreatment,
      Value<int?> taxId,
      Value<String?> taxName,
      Value<double> taxRatePercentage,
      Value<String> receiptRelativePath,
      Value<String> syncStatus,
      Value<String?> lastSyncError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalExpensesTableFilterComposer
    extends Composer<_$ExpensesDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountScope => $composableBuilder(
    column: $table.accountScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get igvCents => $composableBuilder(
    column: $table.igvCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxTreatment => $composableBuilder(
    column: $table.taxTreatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxName => $composableBuilder(
    column: $table.taxName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxRatePercentage => $composableBuilder(
    column: $table.taxRatePercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptRelativePath => $composableBuilder(
    column: $table.receiptRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpensesTableOrderingComposer
    extends Composer<_$ExpensesDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountScope => $composableBuilder(
    column: $table.accountScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get igvCents => $composableBuilder(
    column: $table.igvCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxTreatment => $composableBuilder(
    column: $table.taxTreatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxName => $composableBuilder(
    column: $table.taxName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxRatePercentage => $composableBuilder(
    column: $table.taxRatePercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptRelativePath => $composableBuilder(
    column: $table.receiptRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpensesTableAnnotationComposer
    extends Composer<_$ExpensesDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountScope => $composableBuilder(
    column: $table.accountScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ruc =>
      $composableBuilder(column: $table.ruc, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get igvCents =>
      $composableBuilder(column: $table.igvCents, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxTreatment => $composableBuilder(
    column: $table.taxTreatment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxId =>
      $composableBuilder(column: $table.taxId, builder: (column) => column);

  GeneratedColumn<String> get taxName =>
      $composableBuilder(column: $table.taxName, builder: (column) => column);

  GeneratedColumn<double> get taxRatePercentage => $composableBuilder(
    column: $table.taxRatePercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptRelativePath => $composableBuilder(
    column: $table.receiptRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalExpensesTableTableManager
    extends
        RootTableManager<
          _$ExpensesDatabase,
          $LocalExpensesTable,
          LocalExpenseRow,
          $$LocalExpensesTableFilterComposer,
          $$LocalExpensesTableOrderingComposer,
          $$LocalExpensesTableAnnotationComposer,
          $$LocalExpensesTableCreateCompanionBuilder,
          $$LocalExpensesTableUpdateCompanionBuilder,
          (
            LocalExpenseRow,
            BaseReferences<
              _$ExpensesDatabase,
              $LocalExpensesTable,
              LocalExpenseRow
            >,
          ),
          LocalExpenseRow,
          PrefetchHooks Function()
        > {
  $$LocalExpensesTableTableManager(
    _$ExpensesDatabase db,
    $LocalExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountScope = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<String> ruc = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String> documentNumber = const Value.absent(),
                Value<String> expenseDate = const Value.absent(),
                Value<int> subtotalCents = const Value.absent(),
                Value<int> igvCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String> taxTreatment = const Value.absent(),
                Value<int?> taxId = const Value.absent(),
                Value<String?> taxName = const Value.absent(),
                Value<double> taxRatePercentage = const Value.absent(),
                Value<String> receiptRelativePath = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion(
                id: id,
                accountScope: accountScope,
                remoteId: remoteId,
                ruc: ruc,
                businessName: businessName,
                documentType: documentType,
                documentNumber: documentNumber,
                expenseDate: expenseDate,
                subtotalCents: subtotalCents,
                igvCents: igvCents,
                totalCents: totalCents,
                taxTreatment: taxTreatment,
                taxId: taxId,
                taxName: taxName,
                taxRatePercentage: taxRatePercentage,
                receiptRelativePath: receiptRelativePath,
                syncStatus: syncStatus,
                lastSyncError: lastSyncError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountScope,
                Value<int?> remoteId = const Value.absent(),
                Value<String> ruc = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String> documentNumber = const Value.absent(),
                Value<String> expenseDate = const Value.absent(),
                required int subtotalCents,
                required int igvCents,
                required int totalCents,
                required String taxTreatment,
                Value<int?> taxId = const Value.absent(),
                Value<String?> taxName = const Value.absent(),
                required double taxRatePercentage,
                required String receiptRelativePath,
                required String syncStatus,
                Value<String?> lastSyncError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion.insert(
                id: id,
                accountScope: accountScope,
                remoteId: remoteId,
                ruc: ruc,
                businessName: businessName,
                documentType: documentType,
                documentNumber: documentNumber,
                expenseDate: expenseDate,
                subtotalCents: subtotalCents,
                igvCents: igvCents,
                totalCents: totalCents,
                taxTreatment: taxTreatment,
                taxId: taxId,
                taxName: taxName,
                taxRatePercentage: taxRatePercentage,
                receiptRelativePath: receiptRelativePath,
                syncStatus: syncStatus,
                lastSyncError: lastSyncError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$ExpensesDatabase,
      $LocalExpensesTable,
      LocalExpenseRow,
      $$LocalExpensesTableFilterComposer,
      $$LocalExpensesTableOrderingComposer,
      $$LocalExpensesTableAnnotationComposer,
      $$LocalExpensesTableCreateCompanionBuilder,
      $$LocalExpensesTableUpdateCompanionBuilder,
      (
        LocalExpenseRow,
        BaseReferences<
          _$ExpensesDatabase,
          $LocalExpensesTable,
          LocalExpenseRow
        >,
      ),
      LocalExpenseRow,
      PrefetchHooks Function()
    >;

class $ExpensesDatabaseManager {
  final _$ExpensesDatabase _db;
  $ExpensesDatabaseManager(this._db);
  $$LocalExpensesTableTableManager get localExpenses =>
      $$LocalExpensesTableTableManager(_db, _db.localExpenses);
}
