# Progress — 2026-10-22-pickle-rally.md

Execution: inline, isolated new project directory with development branch. No worktree needed for a new independent repository. User explicitly requested direct implementation.
Pre-flight: Task 2 consumes Flight/Actor from Task 1. Task 3 integrates Rules into Match without replacing Flight API. No conflicts.

Task 1: complete — flight tests PASS; court/actor/scene headless startup clean. Commit c6a0b76.
Task 2: complete — AI integration tests observed failing then PASS; AI returned 62 shots over 70 simulated seconds; alternating wide volleys won after 5 shots.
Task 3: complete — rules tests observed failing then PASS. Full check_project.ps1 PASS: import, flight, rules, match, controls, startup.
Ruling: implement pure Rules before AI orchestration so both player and AI share one legal hit path; avoids temporary duplicated rally state.

Decisions:
- Deterministic ballistic flight, enlarged ball visuals and generous human paddle reach; documented prototype choices.
- AI has 0.24 second reaction time and 2.24 m/s chase speed; central rallies remain stable, wide volleys can win.
- Kitchen momentum tracking lasts until next bounce; tape roll-over and body/paddle-contact referee cases are documented limitations.

Visual QA: NVIDIA RTX 3080 OpenGL Compatibility real viewport PNGs inspected at .tools/visual/. Fixed anchor offsets, overlapping court layers, line placement and exposure. No final render warnings.
Windows UI helper could not connect after prescribed recovery. Used actual engine renders and Godot input event dispatch tests; no OS-level manual playtest claimed.
Control test timing investigation: buffered synthetic key events arrived after process_frame; Input.flush_buffered_events in test helper fixed ordering. Production input unchanged.

Final review: fresh independent reviewer found no Critical or Important gameplay blockers. Two state-invariant findings were reclassified for correction because they violate the documented kitchen restriction and full-reset contracts: opposing volleys overwrote the prior restriction; terminal animation/restart left stale actor state.
Final fixes: kitchen per-player pending restrictions; terminal simulation freeze; actor pose/clock reset on rally completion and restart. Both regressions observed RED then full suite GREEN. Explicit generator shutdown also releases audio playback on scene exit; final GPU render verification required below.
Declined-to-judge rulings: OS-level input playtest unavailable (Godot actual event dispatch tested); audio quality remains subjective (procedural tones); visual quality checked by main agent using actual GPU PNGs. Documented referee/physics simplifications remain prototype scope. No deferred code-review findings.

Final validation: all six check_project groups PASS; actual NVIDIA OpenGL ready/rally/pause/win captures PASS with no errors or warnings. Preview copied to docs/preview.png. Development branch retained locally; no remote integration applies to this new repository.
