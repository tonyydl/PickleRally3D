extends SceneTree
## Exercise Godot's actual event dispatch and InputMap, including HUD controls.

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func click(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = Vector2(640, 410)
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var start: Vector3 = game.player.position
	key(KEY_D, true)
	for i in 20:
		await physics_frame
	key(KEY_D, false)
	await process_frame
	await physics_frame
	check(game.player.position.x > start.x + 0.5, "Physical D must move player right")
	key(KEY_R, true)
	key(KEY_R, false)
	await process_frame
	check(game.player.position.distance_to(start) < 0.05, "R event must reset positions")
	click(true)
	click(false)
	await process_frame
	check(game.rules.live and game.shot_count == 1, "Left click event must serve once")
	key(KEY_ESCAPE, true)
	key(KEY_ESCAPE, false)
	await process_frame
	check(game.paused and game.hud.overlay.visible, "Esc event pauses and shows overlay")
	var frozen: Vector3 = game.flight.position
	for i in 8:
		await physics_frame
	check(game.flight.position == frozen, "Ball stays frozen across actual paused frames")
	game.hud.continue_button.pressed.emit()
	await process_frame
	check(not game.paused and not game.hud.overlay.visible, "HUD continue resumes game")
	key(KEY_R, true)
	key(KEY_R, false)
	await process_frame
	check(not game.rules.live and game.phase == "ready" and game.rules.score == [0, 0], "R returns to clean playable ready state")
	game.free()
	await process_frame
	if failures == 0:
		print("PASS: Godot input dispatch WASD, left click, Esc, R and HUD resume")
	quit(1 if failures else 0)
