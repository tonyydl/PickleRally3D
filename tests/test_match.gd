extends SceneTree

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
	game.set_physics_process(false)
	if not game.has_method("simulate"):
		print("FAIL: AI/rally simulation feature is missing")
		game.free()
		quit(1)
		return
	check(game.player.position.z > 6.9, "Player must start behind baseline")
	game.request_swing()
	check(game.rules.live, "Click must serve")
	var initial_ai: Vector3 = game.opponent.position
	# Test driver controls only the human, with the real move/hit paths. AI is untouched.
	for i in 120 * 70:
		if not game.rules.live:
			break
		if game.rules.last_hitter == 1:
			var target: Vector3 = game.chase_target(0)
			game.player.move_toward_point(target, 1.0 / 120.0)
			if game.rules.bounce_count > 0:
				game.try_hit(0, Vector2.ZERO)
		game.simulate(1.0 / 120.0)
	check(game.shot_count >= 20, "Real AI must sustain at least 20 legal shots; got %d (%s)" % [game.shot_count, game.rules.result])
	check(game.opponent.position.distance_to(initial_ai) > 0.2, "AI must move to chase ball")
	print("Rally verification: %d legal shots in 70 simulated seconds" % game.shot_count)
	game.restart()
	check(game.shot_count == 0 and not game.flight.active and game.rules.score == [0, 0], "Restart clears physics, rally, score")
	game.request_swing()
	game.set_paused(true)
	var before: Vector3 = game.flight.position
	game.simulate(1)
	check(game.flight.position == before, "Pause freezes ball")
	game.set_paused(false)
	game.simulate(0.05)
	check(game.flight.position != before, "Resume continues ball")
	game.restart()
	# Holding aim while serving must retain legal diagonal service.
	game.player.position.x = game.rules.service_x(0)
	game.try_hit(0, Vector2(1, -1))
	check(game.flight.landing().x < 0, "Directional aim must not override serve diagonal")
	for i in 300:
		game.simulate(1.0 / 120)
		if game.rules.last_hitter == 1:
			break
	check(game.rules.live and game.rules.last_hitter == 1, "AI returns legal diagonal service")
	game.restart()
	game.request_swing()
	for i in 120 * 120:
		if not game.rules.live:
			break
		if game.rules.last_hitter == 1:
			var approach: Vector3 = game.chase_target(0)
			if game.rules.can_volley(0):
				approach.z = 2.55
			game.player.move_toward_point(approach, 1.0 / 120)
			var wide: float = 1 if game.shot_count % 4 < 2 else -1
			if game.rules.bounce_count > 0 or game.rules.can_volley(0):
				game.try_hit(0, Vector2(wide, 0))
		elif game.shot_count > 2:
			game.player.move_toward_point(Vector3(0, 0, 2.55), 1.0 / 120)
		game.simulate(1.0 / 120)
	print("Placement verification: %d shots, live=%s, result=%s" % [game.shot_count, game.rules.live, game.rules.result])
	check(not game.rules.live and game.rules.last_rally_winner == 0, "Approaching net and alternating placement must allow player to beat AI")
	# Early click: buffer must connect once as an incoming ball enters paddle reach.
	game.restart()
	game.phase = "rally"
	game.rules.begin_rally()
	game.rules.last_hitter = 1
	game.rules.hit_count = 4
	game.rules.bounced_once = [true, true]
	game.player.position = Vector3(0, 0, 4.2)
	game.flight.position = Vector3(1.65, 1.1, 4.2)
	game.flight.velocity = Vector3(-3, 0, 0)
	game.flight.active = true
	game.request_swing()
	check(game.shot_count == 0, "Early swing must wait for ball to enter reach")
	for i in 36:
		game.simulate(1.0 / 120)
	check(game.shot_count == 1 and game.rules.last_hitter == 0, "Buffered click must hit exactly once")
	game.rules.score = [10, 0]
	game.rules.fault(1, "test")
	game.finish_rally()
	var final_position: Vector3 = game.flight.position
	game.simulate(1)
	check(game.phase == "over" and game.flight.position == final_position, "Match win freezes ball")
	game.hud.refresh()
	check(game.hud.overlay.visible and not game.hud.continue_button.visible, "Win screen must show restart instead of resume")
	game.restart()
	game.rules.server = 1
	game.prepare_service()
	game.request_swing()
	for i in 121:
		game.simulate(1.0 / 120)
	check(game.rules.live and game.rules.last_hitter == 1 and game.shot_count == 1, "AI serves from correct baseline after ready click")
	game.free()
	if failures == 0:
		print("PASS: actual AI 20+ shot rally, pursuit, service, restart and pause")
	quit(1 if failures else 0)
