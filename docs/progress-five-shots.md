# Progress — 2026-10-22-five-shots.md

Scope: five-shot scheme A selected by user; also relocated session-created contributor guide to this repository at user's correction. No existing destination AGENTS.md was overwritten.
Workspace: clean baseline verified, feature branch feat/five-shot-controls, same game directory retained for launch.cmd/editor. No additional worktree created or permission round added.
Baseline: check_project.ps1 passed import, flight, rules, match (62-shot rally and 5-shot placement win), controls, startup.
Interfaces: Shots supplies kind/target/duration/reason to Match; Match exposes actual shot and pending input to HUD/Actor. Flight remains unchanged. No conflicts.
Builder check: fresh reviewer found no important unanswered questions; tuning values left to implementer as specified.
Task 1: complete — missing module observed RED; profiles, real net/floor contact and inclusive thresholds GREEN.
Task 2: complete — missing integration observed RED; actual mouse/keyboard scheme A, contact-time soft and aim, buffered Smash, low-ball fallback, Kitchen/two-bounce/serve constraints, AI Lob retrieval and tactic choice GREEN. Existing match test now completes 75 legal shots in 70 seconds, with placement win after 5 shots.
Task 3: complete — presentation/docs, full validation, actual GPU captures and independent whole-change review completed.

Presentation: footer shows all controls; dynamic right-click Dink/Drop, Smash readiness and recent shot card. Shot-specific sounds/animations/marker colors; no change to gravity or rebound coefficients.
Visual QA: actual NVIDIA RTX 3080 OpenGL ready/rally/pause/win/Dink/Drop/Lob/Smash-ready/Smash captures inspected; Lob remains in frame, controls fit, high ball indicator and current soft type are readable.
Ruling: short procedural PCM effects replace the continuously running audio generator. GPU capture exposed native playback retained during immediate exit; waiting for the final finite effect's finished signal before capture teardown eliminates the warning. Three consecutive verbose GPU runs exited cleanly. Runtime pause/restart stops current audio.
Documentation: AGENTS.md is only in PickleRally3D; docs/README.md indexes specifications/plans/progress in this repository. docs/.gdignore prevents the editor importing documentation images.

Final review: independent reviewer found no Critical/Important gameplay defects, confirmed contact-time buffering/one-hit consumption and rule enforcement, and reran shot/profile/input suites successfully. One pause-state mismatch was addressed as required plan conformance: both actors now reset pending swing/pose state on pause. New regression observed RED, then all eight validation groups GREEN; final GPU capture exited without warnings/errors and pause image was inspected. No deferred code findings.
Review limitations: subjective balance, sound quality and OS-level manual input are not independently certified; automated Godot event dispatch and actual GPU captures are verified. Existing simplified referee/physics scope remains documented in README.
Final state: feature implementation committed as de31e27, with pause conformance fix in the following commit. Feature branch retained locally for review/play; no remote push or merge performed.
