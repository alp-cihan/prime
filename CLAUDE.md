# Prime Project Instructions

## Product

Prime is a premium, dark-first, offline-first Flutter personal development application with a restrained RPG progression system.

The product name is **Prime**. Do not use "Life OS" in user-facing text, application titles, package descriptions, documentation headings, or UI copy unless referring to an old source document.

The approved architecture is located at:

- `docs/architecture.md`

Always read the relevant architecture sections before planning or implementing work.

## Technology

- Flutter
- Dart
- Riverpod with code generation
- GoRouter
- Hive CE for local-first storage
- Supabase for remote synchronization
- Clean Architecture
- Material 3

## Architecture Rules

- Domain code must remain pure Dart.
- Domain must never import Flutter, Hive, Supabase, or Riverpod.
- Dependency direction is `presentation → domain ← data`.
- Use feature-first organization with clear data, domain, and presentation boundaries.
- Do not create one global application state provider.
- XP transactions are immutable and append-only.
- XP transactions must use idempotency keys.
- Editable entities may use last-write-wins synchronization.
- Cached XP totals are projections, not the source of truth.
- Daily Score and Lifetime XP must remain separate concepts.

## UI Rules

- Dark-first.
- Use one accent color with grayscale-dominant surfaces.
- Premium, calm, restrained, and minimal.
- RPG elements must not look like a fantasy mobile game.
- No cartoon avatars, weapons, loot, coins, or gacha mechanics.
- No excessive confetti, gradients, shadows, or visual clutter.
- Show no more than three attributes at once on the Today screen.
- Focus Mode must remain outside the main navigation shell.
- Prefer the visual restraint of Linear and Apple Fitness.

## Development Rules

- Implement only the explicitly requested phase.
- Never silently continue into the next phase.
- Inspect existing code before changing it.
- Explain significant architectural conflicts before editing.
- Use complete, compilable implementations.
- Do not leave pseudocode.
- Avoid unnecessary TODO comments.
- Keep files focused and reasonably sized.
- Prefer composition over oversized widgets and controllers.
- Run `dart format .` after code changes.
- Run `flutter analyze` after code changes.
- Run relevant tests after code changes.
- Fix all errors caused by the implementation.
- Report remaining warnings honestly.

## Safety Rules

- Never modify files outside this repository.
- Never delete files without explicit approval.
- Never run destructive Git commands.
- Never reset or rewrite Git history.
- Never use `git push --force`.
- Never expose or commit secrets.
- Never place private API keys directly in source code.
- Ask before introducing a major dependency not required by the approved architecture.