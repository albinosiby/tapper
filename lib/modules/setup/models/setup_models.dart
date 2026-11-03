import 'package:equatable/equatable.dart';

import '../../../utils/helpers/money_format.dart';

/// A plot in the current season, with its default trees and per-tree wage.
class Plot extends Equatable {
  const Plot({
    required this.id,
    required this.name,
    required this.trees,
    required this.ratePerTree,
  });

  final String id;
  final String name;

  /// Trees normally tapped; pre-fills the mark-tapping sheet.
  final int trees;

  /// Tapper's wage per tree in rupees.
  final double ratePerTree;

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
    id: json['id'] as String,
    name: json['name'] as String,
    trees: (json['trees'] as num).toInt(),
    ratePerTree: (json['ratePerTree'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trees': trees,
    'ratePerTree': ratePerTree,
  };

  @override
  List<Object?> get props => [id, name, trees, ratePerTree];
}

/// Someone who taps: a hired tapper, or the owner ("Self").
class Worker extends Equatable {
  const Worker({required this.id, required this.name});

  /// The owner, when they tap too.
  static const Worker self = Worker(id: 'self', name: 'Self');

  final String id;
  final String name;

  bool get isSelf => id == self.id;

  factory Worker.fromJson(Map<String, dynamic> json) =>
      Worker(id: json['id'] as String, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

/// The estate for the season: plots, who taps them, and when it started.
class TappingSetup extends Equatable {
  const TappingSetup({
    required this.plots,
    required this.workers,
    required this.seasonStartYear,
    this.seasonStartMonth = defaultSeasonStartMonth,
  });

  /// Tapping seasons are counted from June, after the summer break.
  static const int defaultSeasonStartMonth = 6;

  /// Nothing entered yet, for a season around [today].
  factory TappingSetup.empty(DateTime today) => TappingSetup(
    plots: const [],
    workers: const [],
    seasonStartYear: today.month >= defaultSeasonStartMonth
        ? today.year
        : today.year - 1,
  );

  /// A filled-in estate for tests and the design showcase.
  static const TappingSetup sample = TappingSetup(
    plots: [
      Plot(id: 'plot-a', name: 'Plot A', trees: 450, ratePerTree: 1.75),
      Plot(id: 'plot-b', name: 'Plot B', trees: 380, ratePerTree: 1.80),
    ],
    workers: [
      Worker(id: 'raju', name: 'Raju'),
      Worker.self,
    ],
    seasonStartYear: 2026,
  );

  final List<Plot> plots;
  final List<Worker> workers;
  final int seasonStartYear;
  final int seasonStartMonth;

  /// Enough to start marking days: at least one plot and one tapper.
  bool get isComplete => plots.isNotEmpty && workers.isNotEmpty;

  /// `2026–27`.
  String get seasonLabel => TapperDates.season(seasonStartYear);

  DateTime get seasonStart => DateTime(seasonStartYear, seasonStartMonth);

  int get totalTrees => plots.fold(0, (sum, p) => sum + p.trees);

  bool get selfTaps => workers.any((w) => w.isSelf);

  Plot? plot(String id) => plots.where((p) => p.id == id).firstOrNull;
  Worker? worker(String id) => workers.where((w) => w.id == id).firstOrNull;

  /// Adds [plot], or replaces the plot with the same id.
  TappingSetup withPlot(Plot plot) =>
      copyWith(plots: _upsert(plots, plot, (p) => p.id));

  TappingSetup withoutPlot(String id) => copyWith(
    plots: [
      for (final p in plots)
        if (p.id != id) p,
    ],
  );

  /// Adds [worker], or replaces the worker with the same id.
  TappingSetup withWorker(Worker worker) =>
      copyWith(workers: _upsert(workers, worker, (w) => w.id));

  TappingSetup withoutWorker(String id) => copyWith(
    workers: [
      for (final w in workers)
        if (w.id != id) w,
    ],
  );

  TappingSetup copyWith({
    List<Plot>? plots,
    List<Worker>? workers,
    int? seasonStartYear,
    int? seasonStartMonth,
  }) => TappingSetup(
    plots: plots ?? this.plots,
    workers: workers ?? this.workers,
    seasonStartYear: seasonStartYear ?? this.seasonStartYear,
    seasonStartMonth: seasonStartMonth ?? this.seasonStartMonth,
  );

  static List<T> _upsert<T>(List<T> items, T item, String Function(T) id) {
    final i = items.indexWhere((e) => id(e) == id(item));
    return i < 0 ? [...items, item] : ([...items]..[i] = item);
  }

  factory TappingSetup.fromJson(Map<String, dynamic> json) => TappingSetup(
    plots: [
      for (final p in json['plots'] as List)
        Plot.fromJson(p as Map<String, dynamic>),
    ],
    workers: [
      for (final w in json['workers'] as List)
        Worker.fromJson(w as Map<String, dynamic>),
    ],
    seasonStartYear:
        (json['seasonStartYear'] as num?)?.toInt() ?? DateTime.now().year,
    seasonStartMonth:
        (json['seasonStartMonth'] as num?)?.toInt() ?? defaultSeasonStartMonth,
  );

  Map<String, dynamic> toJson() => {
    'plots': [for (final p in plots) p.toJson()],
    'workers': [for (final w in workers) w.toJson()],
    'seasonStartYear': seasonStartYear,
    'seasonStartMonth': seasonStartMonth,
  };

  @override
  List<Object?> get props => [
    plots,
    workers,
    seasonStartYear,
    seasonStartMonth,
  ];
}

/// Field checks for the setup forms. Each returns an error message, or null
/// when the value is fine.
class SetupValidation {
  SetupValidation._();

  static const int maxTrees = 100000;
  static const double maxRate = 100;

  /// Plot or tapper name: required, and not already used by another
  /// (ignoring case and extra spaces).
  static String? name(
    String? value,
    Iterable<String> taken, {
    String what = 'Name',
  }) {
    final name = _clean(value);
    if (name.isEmpty) return '$what is needed';
    if (name.length > 30) return 'Keep it under 30 letters';
    final lower = name.toLowerCase();
    if (taken.any((t) => _clean(t).toLowerCase() == lower)) {
      return '"$name" is already added';
    }
    return null;
  }

  static String? trees(String? value) {
    final trees = int.tryParse(_clean(value));
    if (trees == null) return 'Enter the number of trees';
    if (trees < 1) return 'At least 1 tree';
    if (trees > maxTrees) return 'That is more than $maxTrees trees';
    return null;
  }

  static String? rate(String? value) {
    final rate = double.tryParse(_clean(value));
    if (rate == null || !rate.isFinite) {
      return 'Enter the wage per tree, e.g. 1.75';
    }
    if (rate <= 0) return 'Wage must be more than ₹0';
    if (rate > maxRate) {
      return 'That is more than ${Money.format(maxRate)} a tree';
    }
    if (RegExp(r'\.\d{3,}$').hasMatch(_clean(value))) {
      return 'Use at most 2 decimal places (paise)';
    }
    return null;
  }

  /// Trims and collapses runs of spaces: "  Plot   A " → "Plot A".
  static String clean(String? value) => _clean(value);

  static String _clean(String? value) =>
      (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Stable id from a name, unique among [taken]: "Plot A" → `plot-a`,
/// then `plot-a-2`. Ids never change once given, so old days keep pointing
/// at the right plot or tapper after a rename.
String newSetupId(String name, Iterable<String> taken) {
  final base = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final stem = base.isEmpty ? 'item' : base;
  final used = taken.toSet();
  var id = stem;
  for (var n = 2; used.contains(id); n++) {
    id = '$stem-$n';
  }
  return id;
}
