extends SceneTree
## The real match and court respond only to sustained foreground low FPS.

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	if not game.has_method("check_performance"):
		print("FAIL: automatic performance check is missing")
		game.free()
		quit(1)
		return
	game.set_process(false)
	game.set_physics_process(false)
	game.check_performance(0, 0, true)
	game.check_performance(1000, 10, true)
	check(not game.low_detail, "One slow second must not downgrade")
	game.check_performance(1100, 11, false)
	game.check_performance(5100, 12, true)
	check(not game.low_detail, "Background sampling must not downgrade")
	game.check_performance(7100, 72, true)
	check(not game.low_detail, "Thirty FPS must keep normal detail")
	game.check_performance(9100, 92, true)
	check(game.low_detail, "Two seconds at ten FPS must downgrade")
	check(not game.court.sun.shadow_enabled, "Low detail disables the sun shadow")
	check(not game.court.decor.visible, "Low detail hides optional scenery")
	check(game.ball.visible and game.landing_marker.visible == game.flight.active, "Gameplay markers and ball remain available")
	game.restart()
	check(game.low_detail, "Restarting a match keeps low detail active")
	game.free()
	await process_frame
	var adapter_game = load("res://scenes/main.tscn").instantiate()
	root.add_child(adapter_game)
	await process_frame
	if not adapter_game.has_method("check_software_adapter"):
		print("FAIL: startup software renderer detection is missing")
		adapter_game.free()
		quit(1)
		return
	adapter_game.set_process(false)
	adapter_game.set_physics_process(false)
	adapter_game.check_software_adapter("WebKit WebGL")
	check(not adapter_game.low_detail, "Masked adapter name must wait for FPS measurement")
	adapter_game.check_software_adapter("ANGLE (Google, SwiftShader driver)")
	check(adapter_game.low_detail and not adapter_game.court.decor.visible, "Known software renderer downgrades before play")
	adapter_game.free()
	await process_frame
	var early_game = load("res://scenes/main.tscn").instantiate()
	root.add_child(early_game)
	await process_frame
	early_game.set_process(false)
	early_game.set_physics_process(false)
	early_game.check_performance(0, 0, true)
	early_game.check_performance(1000, 10, true)
	check(not early_game.low_detail, "One slow second is not enough to downgrade")
	early_game.check_performance(2000, 20, true)
	check(early_game.low_detail, "Two seconds at ten FPS downgrades before the first rally")
	early_game.free()
	await process_frame
	if failures == 0:
		print("PASS: web performance fallback handles software adapters and preserves gameplay")
	quit(1 if failures else 0)
