# Tapper

Flutter app for rubber plantation owners in Kerala: plots, tappers, daily tapping, sales, expenses and worker payments per season.

Design system: [Tapper on claude.ai](https://claude.ai/artifact/BSE1WzqGjfqoWZ29FGsatk), ported to `lib/design_system/`.

## Layout
- `lib/design_system/` — tokens (`TapperColors` via `context.tp`, `TapperText`, `Spacing`, `TapperRadius`, `TapperSize`), components (`TpButton`, `TpChip`, `TpTextField`, `TpBadge`, `TpCard`, `MoneyRow`, `SeasonSummary`, `WorkerCard`, `TappingCalendar`), `TpTabShell`, `showTpSheet`, `TapperLogo`, `TpIcon`.
- `lib/modules/` — `home` (calendar + mark-tapping sheet), `accounts`, `employees`, `showcase`. Screens use sample data until each module gets its BLoC and repository.
- `lib/utils/services/cache_service.dart` — `cacheFirst` stream for stale-while-revalidate repositories.

## Run
```bash
flutter pub get
flutter run
flutter test
```
