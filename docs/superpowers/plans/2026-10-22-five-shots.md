# Five Shot Controls Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans inline, with test-driven-development and verification-before-completion. User chose direct-input scheme A; execute without another control-selection question.

**Goal:** Five visibly and physically distinct shots using direct mouse/keyboard input.
**Architecture:** New pure Shots module resolves intent and solves targets/arcs; Match integrates buffered intent and shared AI use; Flight retains physical contacts. Actor/HUD present the resulting shot.
**Tech Stack:** Godot 4.7.2, GDScript, Compatibility renderer.
**Spec:** docs/superpowers/specs/2026-10-22-five-shots-design.md

## Global Constraints
- Left Drive; right Soft (Dink within 3.4 m, otherwise Drop); Space Lob; Shift+left Smash from at least 1.65 m or clear Drive fallback.
- Preserve WASD contact-time aim, legal diagonal service, two-bounce and Kitchen rules, side-out scoring, pause/reset.
- No external dependencies or spin model. Keep physics coefficients identical across shot types.
- Keep ../MyFirstGame and the contributor guide's project scope untouched.

## Review Focus
- Buffered soft/smash input must retain intent after key release and resolve at contact time.
- Smash fallback must neither silently miss nor consume two hits.
- High lobs must remain visible and returnable by ordinary movement/AI.
- Right/Space/Shift must not bypass serve or Kitchen/two-bounce constraints.
- New input and animation state must clear on pause, match end and restart.

### Task 1: Shot profiles and trajectories
Files: scripts/shots.gd, tests/test_shots.gd.
Interfaces: Shots.resolve(intent: StringName, feet: Vector3, origin: Vector3) -> StringName; Shots.build(intent, origin, feet, aim, side, service=false) -> Dictionary with kind/target/duration/reason; Shots.label_for(kind), color_for(kind).
- [ ] Write failing tests: soft position threshold; Lob apex >4.5 m and deeper target; Dink/Drop land inside 2.1336 m; Drive faster horizontally than Drop; valid Smash starts downward; low Smash falls back; representative shots clear net and land on requested target.
- [ ] Implement pure profile/arc solver. Run test_shots and existing flight suite.

### Task 2: Input, AI and rule integration
Files: scripts/match.gd, tests/test_shot_controls.gd, tests/test_match.gd, tools/check_project.ps1.
Interfaces: Match.request_swing(intent: StringName = &"drive"); Match.try_hit(side: int, aim: Vector2, intent: StringName = &"drive") -> bool. Expose last_shot_kind, last_shot_side and pending_intent to HUD.
- [ ] Write failing input/integration tests for all direct controls, buffer capture, fallback, soft Kitchen groundstroke, illegal volley, AI choice and serve overrides.
- [ ] Integrate shared shot construction and AI choices; keep movement/physics rules unchanged. Register new suites.
- [ ] Run full validator, including long rally and placement-win regressions; adjust only tests whose assumptions legitimately changed.

### Task 3: Presentation, docs and review
Files: scripts/hud.gd, scripts/actor.gd, tools/capture.gd, README.md, docs/README.md, docs/progress-five-shots.md.
- [ ] Add shot-specific compact/overhead animation, color/audio feedback, current right-click/Smash readiness and direct control legend.
- [ ] Update README and document index; distinguish approved A mapping from implemented behavior.
- [ ] Run full validation and actual GPU captures of ready/rally/Lob/soft/Smash/terminal UI; inspect and fix material defects.
- [ ] Fresh code review; fix material findings with regressions, record evidence and preserve the feature branch locally.
