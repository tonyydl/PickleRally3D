extends SceneTree

var failures := 0
const Flight = preload("res://scripts/flight.gd")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var shots = load("res://scripts/shots.gd")
	if shots == null:
		print("FAIL: distinct shot profiles are missing")
		quit(1)
		return
	check(shots.resolve(&"soft", Vector3(0, 0, 3.4), Vector3(0, 0.6, 3)) == &"dink", "Soft within near-net boundary must be Dink")
	check(shots.resolve(&"soft", Vector3(0, 0, 3.41), Vector3(0, 0.6, 3)) == &"drop", "Soft from backcourt must be Drop")
	check(shots.resolve(&"soft", Vector3(0, 0, -3), Vector3(0, 0.6, -3)) == &"dink", "Near-net resolution must work for AI side")
	check(shots.resolve(&"smash", Vector3(0, 0, 3), Vector3(0, 1.65, 3)) == &"smash", "Smash exact height threshold must be inclusive")
	var origin := Vector3(0, 0.7, 5.5)
	var feet := Vector3(0, 0, 5.7)
	var drive: Dictionary = shots.build(&"drive", origin, feet, Vector2.ZERO, 0)
	var drop: Dictionary = shots.build(&"soft", origin, feet, Vector2.ZERO, 0)
	var lob: Dictionary = shots.build(&"lob", origin, feet, Vector2.ZERO, 0)
	check(absf(drop.target.z) < 2.1336, "Drop target must be inside Kitchen")
	var drive_speed: float = Vector2(drive.target.x - origin.x, drive.target.z - origin.z).length() / drive.duration
	var drop_speed: float = Vector2(drop.target.x - origin.x, drop.target.z - origin.z).length() / drop.duration
	check(drive_speed > drop_speed + 1, "Drive must be horizontally faster than soft Drop")
	check(lob.target.z < drive.target.z and lob.duration > drive.duration, "Lob must travel deeper and stay airborne longer")
	var flight := Flight.new()
	flight.launch(origin, lob.target, lob.duration)
	var apex: float = origin.y + pow(maxf(0, flight.velocity.y), 2) / (2 * Flight.GRAVITY)
	check(apex >= 4.5, "Lob must have recognizably high apex")
	var smash: Dictionary = shots.build(&"smash", Vector3(0, 2.3, 3.8), Vector3(0, 0, 4), Vector2.ZERO, 0)
	flight.launch(Vector3(0, 2.3, 3.8), smash.target, smash.duration)
	check(smash.kind == &"smash" and flight.velocity.y < 0, "Valid Smash must begin downward")
	var low: Dictionary = shots.build(&"smash", origin, feet, Vector2.ZERO, 0)
	check(low.kind == &"drive" and not low.reason.is_empty(), "Low Smash must explicitly fall back to Drive")
	var serve: Dictionary = shots.build(&"lob", Vector3(1.5, 0.72, 7), Vector3(1.5, 0, 7.2), Vector2(1, -1), 0, true)
	check(serve.kind == &"serve" and serve.target.x < 0 and serve.target.z < -2.1336, "Serve must override requested type and direction with legal diagonal")
	var cases := [
		[&"drive", Vector3(0, 0.8, 5), Vector3(0, 0, 5.2)],
		[&"soft", Vector3(0, 0.55, 2.8), Vector3(0, 0, 3)],
		[&"soft", Vector3(0, 0.7, 5.8), Vector3(0, 0, 6)],
		[&"lob", Vector3(0, 0.8, 5), Vector3(0, 0, 5.2)],
		[&"smash", Vector3(0, 2.3, 3), Vector3(0, 0, 3.2)]
	]
	for row in cases:
		var data: Dictionary = shots.build(row[0], row[1], row[2], Vector2.ZERO, 0)
		flight.launch(row[1], data.target, data.duration)
		var landed := false
		for i in 600:
			for event in flight.step(1.0 / 120):
				check(event.kind != "net", "%s representative shot must clear net" % data.kind)
				if event.kind == "ground":
					landed = true
					check(event.point.distance_to(data.target) < 0.025, "%s must land on target" % data.kind)
			if landed:
				break
		check(landed, "%s must land within bounded simulation" % data.kind)
		var directed: Dictionary = shots.build(row[0], row[1], row[2], Vector2(-0.7, -0.7), 0)
		check(directed.target.x < data.target.x and directed.target.z <= data.target.z, "%s must honor left/deep aim" % data.kind)
		check(absf(directed.target.x) < 3.048 and absf(directed.target.z) < 6.7056, "%s aim must remain in court" % data.kind)
	if failures == 0:
		print("PASS: five profiles, contextual soft, distinct speed/apex/targets, Smash fallback, legal flight")
	quit(1 if failures else 0)
