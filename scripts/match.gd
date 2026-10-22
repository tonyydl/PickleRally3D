extends Node3D

const Court = preload("res://scripts/court.gd")
const Actor = preload("res://scripts/actor.gd")
const Flight = preload("res://scripts/flight.gd")
const Rules = preload("res://scripts/rules.gd")
var flight: Flight = Flight.new()
var rules: Rules = Rules.new()
var player: Node3D
var opponent: Node3D
var ball: MeshInstance3D
var camera: Camera3D
var landing_marker: MeshInstance3D
var aim_marker: MeshInstance3D
var shadow: MeshInstance3D
var impact: MeshInstance3D
var trail: Array[MeshInstance3D] = []
var phase := "ready"
var paused := false
var shot_count := 0
var best_rally := 0
var swing_buffer := 0.0
var elapsed := 0.0
var phase_time := 0.0
var impact_time := 0.0
var feedback_time := 0.0
var feedback := ""
var input_direction := Vector2.ZERO
var hud: CanvasLayer
var audio: AudioStreamPlayer
var audio_playback: AudioStreamGeneratorPlayback
var audio_phase := 0.0
var tone_left := 0.0
var tone_frequency := 500.0
var ai_reaction_left := 0.0

func _ready() -> void:
	for entry in [["left", KEY_A], ["right", KEY_D], ["forward", KEY_W], ["back", KEY_S]]:
		if not InputMap.has_action(entry[0]):
			InputMap.add_action(entry[0])
			var key := InputEventKey.new()
			key.physical_keycode = entry[1]
			InputMap.action_add_event(entry[0], key)
	add_child(Court.new())
	player = Actor.new()
	player.shirt = Color("f6e9bc")
	add_child(player)
	opponent = Actor.new()
	opponent.side = 1
	opponent.shirt = Color("de735f")
	add_child(opponent)
	ball = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.105
	sphere.height = 0.21
	sphere.radial_segments = 12
	sphere.rings = 6
	ball.mesh = sphere
	ball.material_override = Court.material(Color("edfa4c"), true)
	add_child(ball)
	landing_marker = Court.ring(self, 0.29, Color("ebf64b"))
	aim_marker = Court.ring(self, 0.39, Color("faf9db"))
	shadow = Court.cylinder(self, Vector3.ZERO, 0.115, 0.006, Color("2b676e"))
	impact = Court.ring(self, 0.2, Color("ffffff"))
	for i in 7:
		var dot := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.035 * (1 - i / 9.0)
		mesh.height = mesh.radius * 2
		dot.mesh = mesh
		dot.material_override = Court.material(Color("f4f8b0"), true)
		add_child(dot)
		trail.append(dot)
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0, 10.9, 17.4)
	camera.fov = 53
	camera.look_at(Vector3(0, 0, -0.3))
	camera.current = true
	setup_audio()
	if ResourceLoader.exists("res://scripts/hud.gd"):
		hud = load("res://scripts/hud.gd").new()
		hud.game = self
		add_child(hud)
	restart()

func setup_audio() -> void:
	if DisplayServer.get_name() == "headless":
		return
	audio = AudioStreamPlayer.new()
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.12
	audio.stream = generator
	audio.volume_db = -9
	add_child(audio)
	audio.play()
	audio_playback = audio.get_stream_playback()

func sound(frequency: float, duration: float) -> void:
	tone_frequency = frequency
	tone_left = duration

func fill_audio() -> void:
	if audio_playback == null:
		return
	for i in audio_playback.get_frames_available():
		var sample := 0.0
		if tone_left > 0 and not paused:
			audio_phase += TAU * tone_frequency / 22050.0
			sample = sin(audio_phase) * minf(1, tone_left * 40) * 0.45
			tone_left -= 1.0 / 22050
		audio_playback.push_frame(Vector2(sample, sample))

func restart() -> void:
	rules.reset()
	best_rally = 0
	paused = false
	elapsed = 0
	feedback = ""
	feedback_time = 0
	impact_time = 0
	prepare_service()
	update_visuals(0)

func prepare_service() -> void:
	phase = "ready"
	phase_time = 0
	flight.active = false
	swing_buffer = 0
	shot_count = 0
	ai_reaction_left = 0
	player.position = Vector3(rules.service_x(0) if rules.server == 0 else -rules.service_x(1), 0, 7.15 if rules.server == 0 else 5.5)
	opponent.position = Vector3(rules.service_x(1) if rules.server == 1 else -rules.service_x(0), 0, -7.15 if rules.server == 1 else -5.5)
	flight.position = (player.position if rules.server == 0 else opponent.position) + Vector3(0, 0.72, -0.28 if rules.server == 0 else 0.28)
	for dot in trail:
		dot.position = flight.position
		dot.visible = false

func set_paused(value: bool) -> void:
	paused = value
	swing_buffer = 0
	if hud:
		hud.refresh()

func request_swing() -> void:
	if paused or phase == "over":
		return
	if phase == "result":
		if phase_time < 0.65:
			return
		prepare_service()
	if phase == "ready":
		if rules.server == 0:
			try_hit(0, input_direction)
		else:
			phase = "ai_serve"
			phase_time = 0
	elif phase == "rally":
		swing_buffer = 0.3
		if try_hit(0, input_direction):
			swing_buffer = 0
		else:
			player.swing()
			feedback = "揮拍準備 · 靠近黃色落點"
			feedback_time = 0.5

func aim_target(side: int, aim: Vector2, service: bool) -> Vector3:
	var facing := -1.0 if side == 0 else 1.0
	if service:
		return Vector3(-rules.service_x(side), Flight.RADIUS, facing * 4.9)
	return Vector3(clampf(aim.x * 2.25, -2.5, 2.5), Flight.RADIUS, facing * clampf(4.4 - aim.y * 2.5, 0.9, 6.05))

func try_hit(side: int, aim: Vector2) -> bool:
	if paused or phase == "over" or phase == "result":
		return false
	var actor: Node3D = player if side == 0 else opponent
	var service := phase == "ready" or phase == "ai_serve"
	if service:
		if side != rules.server:
			return false
		rules.begin_rally()
	else:
		if not rules.live or rules.last_hitter == side or not flight.active:
			return false
		if (flight.position.z < 0 if side == 0 else flight.position.z > 0):
			return false
		var offset := Vector2(flight.position.x - actor.position.x, flight.position.z - actor.position.z)
		# AI must get behind the incoming ball; it cannot return balls past its body.
		if side == 1 and (offset.length() > 0.95 or offset.y < -0.2):
			return false
		if offset.length() > 1.3 or flight.position.y < 0.15 or flight.position.y > 2.35:
			return false
	var volley: bool = not service and rules.bounce_count == 0
	var error: String = rules.hit(side, actor.position)
	actor.swing()
	if not error.is_empty():
		finish_rally()
		return true
	var origin: Vector3 = actor.position + Vector3(0.42, 0.72, -0.28 if rules.server == 0 else 0.28) if service else flight.position
	var target := aim_target(side, aim, service)
	flight.launch(origin, target, Flight.duration_for(origin, target, volley))
	phase = "rally"
	shot_count += 1
	if side == 0:
		ai_reaction_left = 0.24
	best_rally = maxi(best_rally, shot_count)
	feedback = "發球" if service else ("截擊！" if volley else "漂亮抽球！")
	feedback_time = 0.7
	impact.position = Vector3(origin.x, 0.075, origin.z)
	impact_time = 0.22
	sound(720 if volley else 540, 0.065)
	return true

func chase_target(side: int) -> Vector3:
	var point: Vector3 = flight.landing() if rules.bounce_count == 0 else flight.position
	point.y = 0
	point.z += 0.45 if side == 0 else -0.45
	point.x = clampf(point.x, -4.3, 4.3)
	point.z = clampf(point.z, 0.5, 8.4) if side == 0 else clampf(point.z, -8.4, -0.5)
	return point

func simulate(delta: float) -> void:
	if paused:
		return
	elapsed += delta
	phase_time += delta
	feedback_time = maxf(0, feedback_time - delta)
	impact_time = maxf(0, impact_time - delta)
	player.animate(delta)
	opponent.animate(delta)
	if phase == "ai_serve":
		if phase_time >= 0.8:
			try_hit(1, Vector2.ZERO)
		return
	if phase != "rally":
		return
	rules.check_kitchen(0, player.position)
	rules.check_kitchen(1, opponent.position)
	if not rules.live:
		finish_rally()
		return
	for event in flight.step(delta):
		if event.kind == "ground":
			rules.bounce(event.point)
			impact.position = event.point + Vector3.UP * 0.035
			impact_time = 0.28
			sound(230, 0.045)
		elif event.kind == "net":
			rules.fault(rules.last_hitter, "觸網未過")
			sound(120, 0.12)
		if not rules.live:
			finish_rally()
			return
	if absf(flight.position.z) > 12 or absf(flight.position.x) > 9:
		rules.fault(1 - rules.last_hitter if rules.bounce_count > 0 else rules.last_hitter, "球已離開場地")
		finish_rally()
		return
	if rules.last_hitter == 0:
		ai_reaction_left = maxf(0, ai_reaction_left - delta)
		if ai_reaction_left <= 0:
			opponent.move_toward_point(chase_target(1), delta * 0.4)
		if rules.bounce_count > 0 and ai_reaction_left <= 0:
			var ai_aim := Vector2(sin(shot_count * 1.3) * 0.45, 0.12)
			try_hit(1, ai_aim)
	else:
		opponent.move_toward_point(Vector3(0, 0, -4.4), delta * 0.48)
	if swing_buffer > 0:
		swing_buffer = maxf(0, swing_buffer - delta)
		if try_hit(0, input_direction):
			swing_buffer = 0

func finish_rally() -> void:
	phase = "over" if rules.winner != -1 else "result"
	phase_time = 0
	flight.active = false
	swing_buffer = 0
	feedback_time = 0
	sound(880 if rules.last_rally_winner == 0 else 180, 0.16)

func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "forward", "back")
	if not paused and phase != "over" and phase != "result":
		player.move_input(input_direction, delta)
	simulate(delta)
	update_visuals(delta)
	fill_audio()
	if hud:
		hud.refresh()

func update_visuals(delta: float) -> void:
	if phase == "ready" or phase == "ai_serve":
		flight.position = (player.position if rules.server == 0 else opponent.position) + Vector3(0.42, 0.72, -0.28 if rules.server == 0 else 0.28)
	ball.position = flight.position + Vector3.UP * 0.1
	shadow.position = Vector3(ball.position.x, 0.065, ball.position.z)
	shadow.scale = Vector3.ONE * clampf(1 - ball.position.y * 0.08, 0.45, 1)
	landing_marker.visible = flight.active
	if flight.active:
		landing_marker.position = flight.landing() + Vector3.UP * 0.028
		landing_marker.scale = Vector3.ONE * (1 + sin(elapsed * 8) * 0.1)
	aim_marker.visible = (phase == "rally" or phase == "ready") and not paused
	aim_marker.position = aim_target(0, input_direction, phase == "ready") + Vector3.UP * 0.022
	impact.visible = impact_time > 0
	impact.scale = Vector3.ONE * (1 + (0.28 - impact_time) * 8)
	for i in range(trail.size() - 1, -1, -1):
		trail[i].visible = flight.active
		trail[i].position = trail[i - 1].position if i > 0 else ball.position
	camera.position.x = lerpf(camera.position.x, player.position.x * 0.28, minf(1, delta * 3))
	camera.look_at(Vector3(player.position.x * 0.12, 0, -0.3))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			restart()
		elif event.physical_keycode == KEY_ESCAPE:
			set_paused(not paused)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		request_swing()
