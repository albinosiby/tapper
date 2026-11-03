import 'package:equatable/equatable.dart';

import '../../../utils/helpers/money_format.dart';
import '../../setup/models/setup_models.dart';

export '../../setup/models/setup_models.dart';

enum NotTappedReason {
  rain('Rain'),
  rest('Rest'),
  holiday('Holiday'),
  workerAbsent('Worker absent'),
  other('Other');

  const NotTappedReason(this.label);

  final String label;
}

/// Trees tapped on one plot that day, with the rate in force at the time so
/// later rate changes don't rewrite old wages.
class PlotTapping extends Equatable {
  const PlotTapping({
    required this.plotId,
    required this.trees,
    required this.ratePerTree,
  });

  final String plotId;
  final int trees;
  final double ratePerTree;

  double get wage => trees * ratePerTree;

  factory PlotTapping.fromJson(Map<String, dynamic> json) => PlotTapping(
    plotId: json['plotId'] as String,
    trees: (json['trees'] as num).toInt(),
    ratePerTree: (json['ratePerTree'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'plotId': plotId,
    'trees': trees,
    'ratePerTree': ratePerTree,
  };

  @override
  List<Object?> get props => [plotId, trees, ratePerTree];
}

/// One line of an entry's edit history ("Edited 28 Oct · 450 → 460 trees").
class EntryEdit extends Equatable {
  const EntryEdit({required this.at, required this.note});

  final DateTime at;
  final String note;

  String get caption => 'Edited ${TapperDates.list(at)} · $note';

  factory EntryEdit.fromJson(Map<String, dynamic> json) => EntryEdit(
    at: DateTime.parse(json['at'] as String),
    note: json['note'] as String,
  );

  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'note': note};

  @override
  List<Object?> get props => [at, note];
}

enum TappingCoverage {
  /// Every season plot tapped.
  all,

  /// Some plots tapped.
  some,

  /// Marked as not tapped.
  none,
}

/// One day's record: tapped plots and who tapped them, or why not.
class TappingEntry extends Equatable {
  TappingEntry({
    required DateTime date,
    required this.tapped,
    this.plots = const [],
    this.workerId,
    this.reason,
    this.remark = '',
    this.edits = const [],
    this.pendingSync = false,
  }) : date = DateTime(date.year, date.month, date.day);

  factory TappingEntry.tapped({
    required DateTime date,
    required List<PlotTapping> plots,
    required String workerId,
    String remark = '',
  }) => TappingEntry(
    date: date,
    tapped: true,
    plots: plots,
    workerId: workerId,
    remark: remark,
  );

  factory TappingEntry.notTapped({
    required DateTime date,
    required NotTappedReason reason,
    String remark = '',
  }) => TappingEntry(date: date, tapped: false, reason: reason, remark: remark);

  final DateTime date;
  final bool tapped;
  final List<PlotTapping> plots;
  final String? workerId;
  final NotTappedReason? reason;
  final String remark;

  /// Every change to this day, oldest first. Nothing is ever lost.
  final List<EntryEdit> edits;

  /// Saved on the phone but not yet confirmed by the server.
  final bool pendingSync;

  int get totalTrees => plots.fold(0, (sum, p) => sum + p.trees);
  double get wage => plots.fold(0, (sum, p) => sum + p.wage);

  TappingCoverage coverage(TappingSetup setup) {
    if (!tapped) return TappingCoverage.none;
    final tappedIds = plots.map((p) => p.plotId).toSet();
    return setup.plots.every((p) => tappedIds.contains(p.id))
        ? TappingCoverage.all
        : TappingCoverage.some;
  }

  TappingEntry copyWith({List<EntryEdit>? edits, bool? pendingSync}) =>
      TappingEntry(
        date: date,
        tapped: tapped,
        plots: plots,
        workerId: workerId,
        reason: reason,
        remark: remark,
        edits: edits ?? this.edits,
        pendingSync: pendingSync ?? this.pendingSync,
      );

  /// [next] replacing this entry, carrying the history forward plus a note
  /// on what changed. Returns this entry unchanged if nothing differs.
  TappingEntry revisedBy(TappingEntry next, DateTime now) {
    final note = _changeNote(next);
    if (note == null) return this;
    return next.copyWith(
      edits: [
        ...edits,
        EntryEdit(at: now, note: note),
      ],
    );
  }

  String? _changeNote(TappingEntry next) {
    String status(TappingEntry e) =>
        e.tapped ? 'Tapped' : 'Not tapped — ${e.reason?.label.toLowerCase()}';
    if (tapped != next.tapped || reason != next.reason) {
      return '${status(this)} → ${status(next)}';
    }
    if (totalTrees != next.totalTrees) {
      return '$totalTrees → ${next.totalTrees} trees';
    }
    if (_samePlots(next) && workerId == next.workerId) {
      return remark == next.remark ? null : 'Remark changed';
    }
    return 'Plots or tapper changed';
  }

  bool _samePlots(TappingEntry next) =>
      plots.length == next.plots.length && plots.every(next.plots.contains);

  factory TappingEntry.fromJson(Map<String, dynamic> json) => TappingEntry(
    date: DateTime.parse(json['date'] as String),
    tapped: json['tapped'] as bool,
    plots: [
      for (final p in (json['plots'] as List? ?? const []))
        PlotTapping.fromJson(p as Map<String, dynamic>),
    ],
    workerId: json['workerId'] as String?,
    reason: switch (json['reason']) {
      final String name => NotTappedReason.values.byName(name),
      _ => null,
    },
    remark: json['remark'] as String? ?? '',
    edits: [
      for (final e in (json['edits'] as List? ?? const []))
        EntryEdit.fromJson(e as Map<String, dynamic>),
    ],
    pendingSync: json['pendingSync'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'date': dateKey,
    'tapped': tapped,
    'plots': [for (final p in plots) p.toJson()],
    'workerId': workerId,
    'reason': reason?.name,
    'remark': remark,
    'edits': [for (final e in edits) e.toJson()],
    'pendingSync': pendingSync,
  };

  /// `2026-10-27`.
  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    date,
    tapped,
    plots,
    workerId,
    reason,
    remark,
    edits,
    pendingSync,
  ];
}

/// All entries for one calendar month, keyed by day of month.
class TappingMonth extends Equatable {
  const TappingMonth({
    required this.year,
    required this.month,
    this.entries = const {},
  });

  final int year;
  final int month;
  final Map<int, TappingEntry> entries;

  /// `2026-10`.
  String get key => '$year-${month.toString().padLeft(2, '0')}';

  bool contains(DateTime date) => date.year == year && date.month == month;

  TappingMonth withEntry(TappingEntry entry) => TappingMonth(
    year: year,
    month: month,
    entries: {...entries, entry.date.day: entry},
  );

  /// This (server) month, keeping any of [local]'s entries that have not
  /// reached the server yet.
  TappingMonth mergePending(TappingMonth? local) {
    if (local == null) return this;
    final pending = {
      for (final e in local.entries.entries)
        if (e.value.pendingSync) e.key: e.value,
    };
    if (pending.isEmpty) return this;
    return TappingMonth(
      year: year,
      month: month,
      entries: {...entries, ...pending},
    );
  }

  factory TappingMonth.fromJson(Map<String, dynamic> json) {
    final entries = [
      for (final e in json['entries'] as List)
        TappingEntry.fromJson(e as Map<String, dynamic>),
    ];
    return TappingMonth(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      entries: {for (final e in entries) e.date.day: e},
    );
  }

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'entries': [for (final e in entries.values) e.toJson()],
  };

  @override
  List<Object?> get props => [year, month, entries];
}
