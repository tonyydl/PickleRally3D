# Repository Guidelines

## Project Structure & Module Organization

This repository contains Pickle Rally 3D, a Windows-first pickleball prototype verified with Godot 4.7.2 and the Compatibility renderer. Run commands from this repository root. The sibling `../MyFirstGame/` is unrelated; keep its files untouched.

- `project.godot` configures the game; `scenes/main.tscn` is the entry scene.
- `scripts/rules.gd` owns scoring and rally legality; `flight.gd` owns deterministic ballistics; `match.gd` coordinates input and AI. `actor.gd`, `court.gd`, and `hud.gd` handle presentation.
- Models and sounds are generated procedurally; no downloaded asset library is required.
- `tests/` contains headless suites; `tools/` contains validation and rendering utilities.
- Specifications and implementation plans live in `docs/superpowers/specs/` and `docs/superpowers/plans/`; progress notes and preview images are in `docs/`.

## Build, Test, and Development Commands

Run these PowerShell commands from this repository root:

```powershell
godot --path .
powershell -ExecutionPolicy Bypass -File tools/check_project.ps1
godot --headless --path . --script tests/test_rules.gd
godot --path . --script tools/capture.gd
```

These launch the game, run import/tests/startup validation, execute one suite, and capture rendered screenshots respectively. Logs and captures go into ignored `.tools/`. Open `project.godot` and press F5 for editor-based development, or double-click `launch.cmd`.

## Coding Style & Naming Conventions

Use GDScript with tabs, `snake_case` filenames/functions/variables, and `UPPER_SNAKE_CASE` constants. Prefer explicit types where inference is ambiguous. Keep rules and physics independent of rendering. Preserve `.gd.uid` files; exclude `.godot/`, `.tools/`, and build output. No dedicated formatter or linter is configured; Godot parsing and validation are the current checks.

## Testing Guidelines

Tests are standalone `SceneTree` scripts named `tests/test_<behavior>.gd`, using explicit checks, `PASS:` output, and nonzero failure exits. Add meaningful regressions for physics, rules, controls, and match transitions. Register new suites in `tools/check_project.ps1` and run the full script before submitting; it rejects errors and warnings. Inspect rendered captures for camera or HUD changes; report automated checks separately from manual playtesting.

## Commit & Pull Request Guidelines

History uses descriptive imperative subjects such as `feat: complete singles AI rules` and `fix: preserve kitchen restrictions`. Keep commits focused. Pull requests should explain behavior changes, reference relevant issues/specs, list validation results, and include screenshots for visual changes. Update control documentation and specifications when gameplay changes.
