# Pickle Rally 3D Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans inline. Steps use checkbox syntax.

**Goal:** A playable Windows singles pickleball prototype against AI.
**Architecture:** Pure Rules and Flight objects, procedural Court and Actor nodes, HUD, Match orchestration.
**Tech Stack:** Godot 4.7.2, GDScript, Compatibility renderer, no dependencies.
**Spec:** docs/superpowers/specs/2026-10-22-pickle-rally-design.md

## Global Constraints
- Windows-first, bright low-poly; 6.096 × 13.4112 m court, kitchen 2.1336 m.
- WASD movement and coarse aim, left click swing, R restart, Esc pause.
- Traditional side-out singles scoring to 11, win by 2.
- Separate project; preserve MyFirstGame.

## Review Focus
- A held direction on serve must not produce a wrong service court.
- Early swing must buffer without hitting twice; kitchen movement after volley must fault.
- Fast balls cannot skip net/ground collisions.
- Match-over/pause must freeze simulation and restart must fully clear state.
- AI must return after required bounces without teleporting.

### Task 1: Court, movement and flight
Files: project.godot, scenes/main.tscn, scripts/court.gd, scripts/actor.gd, scripts/flight.gd, scripts/match.gd; tests/test_flight.gd.
Interfaces: Flight.launch(origin: Vector3, target: Vector3, duration: float), step(delta: float) -> Array[Dictionary], landing() -> Vector3. Actor.move_toward_point(target: Vector3, delta: float), swing().
- [x] Write tests for arc landing, bounce, swept net impact and clear net; run and observe missing feature failure.
- [x] Implement physics/court/actors and basic launchable match.
- [x] Run flight tests and headless scene import/start.

### Task 2: AI and sustained rally
Files: scripts/match.gd, tests/test_match.gd.
Interfaces: Match.try_hit(side: int, aim: Vector2) -> bool; Match.simulate(delta: float). AI uses same hit path as player.
- [x] Write integration tests for moving/chasing AI and sustained rallies using real simulation.
- [x] Run failing tests; implement AI pursuit, recovery, service and hit feedback.
- [x] Run physics and integration tests; launch current playable stage.

### Task 3: Rules, HUD and delivery
Files: scripts/rules.gd, scripts/hud.gd, scripts/match.gd, tests/test_rules.gd, tests/test_match.gd, tools/check_project.ps1, README.md, launch.cmd.
Interfaces: Rules.begin_rally(), hit(side: int, feet: Vector3) -> String, bounce(point: Vector3) -> String, fault(loser: int, reason: String); scoring state exposed to HUD.
- [x] Write rules tests for service parity/diagonal/lines, two-bounce rule, kitchen/foot/momentum, out/double bounce, side-out, deuce, terminal win and reset; observe failure.
- [x] Implement rules and integrate HUD including points, server, rally feedback, aim/landing markers, pause and restart.
- [x] Run complete headless suite and Windows render/input QA; fix material defects.
- [x] Document controls, stage results, limitations and launch commands; record final review.
