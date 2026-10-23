# Automatic Web Performance Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lower scene cost immediately for known software renderers, with a two-second FPS fallback for masked adapters.

**Architecture:** `match.gd` checks the WebGL canvas renderer name at startup, then samples drawn frames over wall-clock time on Web if needed. It switches scene quality once. `court.gd` owns the light and optional decor so gameplay objects remain unchanged.

**Tech Stack:** Godot 4.7.2, GDScript, Compatibility renderer, headless SceneTree tests.

**Spec:** `docs/superpowers/specs/2026-10-22-web-low-performance-mode-design.md`

## Global Constraints

- Keep Windows rendering unchanged and maintain gameplay behavior.
- Do not alter the existing HUD font changes or other uncommitted export work.
- Do not use Compatibility renderer's unsupported 3D resolution scaling.

## Review Focus

- Background or paused sampling must reset the measurement window.
- Brief slow periods below two seconds must not downgrade.
- A full window at or above 25 FPS must keep default quality.
- Once downgraded, restart must keep the mode active.
- Court lines, net, players, ball and markers must stay visible.

---

### Task 1: Automatic performance fallback

**Files:**
- Modify: `scripts/match.gd`
- Modify: `scripts/court.gd`
- Create: `tests/test_web_performance.gd`
- Modify: `tools/check_project.ps1`
- Modify: `docs/superpowers/specs/2026-10-22-web-low-performance-mode-design.md` if tests reveal missing behavior.

**Interfaces:**
- `match.check_software_adapter(adapter_name: String) -> void`: switch immediately for known software renderers.
- `match.check_performance(now_ms: int, frames_drawn: int, active: bool) -> void`: sample a two-second window; switch to low detail once if average FPS is below 25.
- `court.set_low_detail(enabled: bool) -> void`: disable sun shadows and hide optional decor.

- [x] **Step 1:** Write `tests/test_web_performance.gd` to exercise `check_performance` with hand-set time/frame samples; assert normal, brief, inactive, sustained-low and restart behavior against real Court nodes.
- [x] **Step 2:** Run `godot --headless --path . --script tests/test_web_performance.gd`; confirm the feature is absent.
- [x] **Step 3:** Add court decor group/light references and `set_low_detail`; add match sampling state, Web-only `_process` integration, and `check_performance`.
- [x] **Step 4:** Run the new test and correct implementation until it passes.
- [x] **Step 5:** Register test in `tools/check_project.ps1` and run the full validator; inspect a rendered capture to check that normal visuals remain intact.
