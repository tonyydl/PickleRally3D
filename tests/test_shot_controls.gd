extends SceneTree
## Real input dispatch and shared match/rule paths for scheme A.

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func incoming(game, feet := Vector3(0, 0, 4.2), point := Vector3(0.3, 0.8, 4.1), bounced := true) -> void:
	game.restart()
	game.phase = "rally"
	game.rules.begin_rally()
	game.rules.last_hitter = 1
	game.rules.hit_count = 4
	game.rules.bounced_once = [true, true]
	game.rules.bounce_count = 1 if bounced else 0
	game.player.position = feet
	game.flight.position = point
	game.flight.velocity = Vector3(0, -0.1, 2)
	game.flight.active = true

func mouse(button: MouseButton, shifted := false) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.shift_pressed = shifted
		event.pressed = pressed
		event.position = Vector2(640, 410)
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func space(echo := false) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_SPACE
		event.physical_keycode = KEY_SPACE
		event.pressed = pressed
		event.echo = echo
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	await process_frame
	if not game.has_method("choose_ai_intent"):
		print("FAIL: five-shot match/input integration is missing")
		game.free()
		quit(1)
		return
	incoming(game)
	mouse(MOUSE_BUTTON_LEFT)
	check(game.shot_count == 1 and game.last_shot_kind == &"drive", "Left mouse must directly Drive once")
	incoming(game)
	mouse(MOUSE_BUTTON_RIGHT)
	check(game.last_shot_kind == &"drop", "Right mouse in backcourt must Drop")
	incoming(game, Vector3(0, 0, 1.7), Vector3(0.3, 0.5, 1.6))
	mouse(MOUSE_BUTTON_RIGHT)
	check(game.rules.live and game.last_shot_kind == &"dink", "Right mouse may Dink a bounced ball inside Kitchen")
	incoming(game)
	space()
	check(game.last_shot_kind == &"lob", "Space must directly Lob")
	space(true)
	check(game.shot_count == 1 and game.pending_intent == &"", "Space auto-repeat must not enqueue another shot")
	incoming(game, Vector3(0, 0, 4.2), Vector3(0.3, 2.2, 4.1), false)
	mouse(MOUSE_BUTTON_LEFT, true)
	check(game.last_shot_kind == &"smash" and game.flight.velocity.y < 0, "Shift+left must Smash a legal high ball downward")
	incoming(game)
	mouse(MOUSE_BUTTON_LEFT, true)
	check(game.last_shot_kind == &"drive" and game.feedback.contains("球太低"), "Low Smash must hit once as Drive with clear explanation")
	incoming(game, Vector3(0, 0, 3.2), Vector3(1.65, 1.1, 3.2), false)
	game.flight.velocity = Vector3(-3, 0, 0)
	mouse(MOUSE_BUTTON_RIGHT)
	check(game.shot_count == 0 and game.pending_intent == &"soft", "Early right click must capture soft intent after release")
	game.player.position.z = 3.8
	game.input_direction = Vector2(-1, -1)
	for i in 36:
		game.simulate(1.0 / 120)
	check(game.shot_count == 1 and game.last_shot_kind == &"drop", "Buffered soft must resolve position at contact and hit once")
	check(game.flight.landing().x < -2 and absf(game.flight.landing().z) > 1.6, "Buffered shot must use contact-time direction rather than button-down direction")
	incoming(game, Vector3(0, 0, 4.2), Vector3(1.65, 2.4, 4.2), false)
	game.flight.velocity = Vector3(-3, 0, 0)
	mouse(MOUSE_BUTTON_LEFT, true)
	for i in 36:
		game.simulate(1.0 / 120)
	check(game.shot_count == 1 and game.last_shot_kind == &"smash", "Buffered Smash must retain intent after Shift release")
	incoming(game, Vector3(0, 0, 1.7), Vector3(0.2, 0.8, 1.6), false)
	mouse(MOUSE_BUTTON_RIGHT)
	check(not game.rules.live and game.rules.result.contains("Kitchen"), "Soft input cannot bypass Kitchen volley restriction")
	incoming(game)
	game.rules.bounced_once = [false, true]
	game.rules.bounce_count = 0
	space()
	check(not game.rules.live and game.rules.result.contains("兩次落地"), "Lob input cannot bypass mandatory service-return bounce")
	game.restart()
	mouse(MOUSE_BUTTON_RIGHT)
	space()
	check(not game.rules.live and game.phase == "ready", "Right and Space must not start service")
	mouse(MOUSE_BUTTON_LEFT, true)
	check(game.rules.live and game.last_shot_kind == &"serve" and game.flight.landing().x < 0, "Shift+left during service must retain legal diagonal serve")
	incoming(game, Vector3(0, 0, 4.2), Vector3(1.65, 1.1, 4.2), false)
	game.request_swing(&"soft")
	game.set_paused(true)
	check(game.pending_intent == &"" and game.swing_buffer == 0, "Pause must discard buffered shot intent")
	game.restart()
	check(game.pending_intent == &"" and game.last_shot_kind == &"", "Restart must clear new shot state")
	# AI uses the same shots and real movement, including lob retrieval.
	incoming(game)
	game.try_hit(0, Vector2.ZERO, &"lob")
	for i in 480:
		game.simulate(1.0 / 120)
		if game.rules.last_hitter == 1 or not game.rules.live:
			break
	check(game.rules.live and game.rules.last_hitter == 1, "AI must retrieve a legal Lob using actual movement and hit rules")
	incoming(game)
	game.rules.last_hitter = 0
	game.rules.bounce_count = 0
	game.opponent.position = Vector3(0, 0, -3.2)
	game.flight.position = Vector3(0, 2.2, -3.3)
	check(game.choose_ai_intent() == &"smash", "AI must select Smash for reachable legal high ball")
	game.flight.position.y = 0.7
	game.last_shot_kind = &"drop"
	check(game.choose_ai_intent() == &"soft", "AI near net must recognize soft response to short ball")
	game.opponent.position.z = -4.4
	game.player.position.z = 2.6
	game.shot_count = 5
	check(game.choose_ai_intent() == &"lob", "AI must sometimes Lob against net positioning")
	game.free()
	await process_frame
	if failures == 0:
		print("PASS: five direct controls, contact-time buffer, service, Kitchen, bounce rules, AI and reset")
	quit(1 if failures else 0)
