extends SceneTree

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var script = load("res://scripts/flight.gd")
	if script == null:
		print("FAIL: Flight feature is missing")
		quit(1)
		return
	var flight = script.new()
	flight.launch(Vector3(1, 0.7, 7), Vector3(-1, 0.04, -4.6), 1.5)
	check(flight.landing().distance_to(Vector3(-1, 0.04, -4.6)) < 0.01, "Solved arc must land at requested point")
	var grounds := 0
	for i in 190:
		for event in flight.step(1.0 / 120.0):
			if event.kind == "ground":
				grounds += 1
				check(event.point.distance_to(Vector3(-1, 0.04, -4.6)) < 0.02, "First landing must match target")
			if event.kind == "net":
				check(false, "Legal high arc must clear net")
	check(grounds == 1, "Ground collision must happen once")
	check(flight.velocity.y > 0, "Ball must bounce upward")
	flight.position = Vector3(0, 0.45, 1)
	flight.velocity = Vector3(0, 0, -100)
	flight.active = true
	var events: Array = flight.step(0.03)
	check(events.any(func(e): return e.kind == "net"), "Fast low ball must not tunnel through net")
	check(flight.position.z > 0, "Net must keep blocked ball on incoming side")
	flight.position = Vector3(0, 1.6, 1)
	flight.velocity = Vector3(0, 0, -100)
	events = flight.step(0.03)
	check(not events.any(func(e): return e.kind == "net"), "High ball must clear net")
	flight.position = Vector3(0, 1, 3)
	flight.velocity = Vector3(0, -30, 0)
	events = flight.step(0.1)
	check(events.any(func(e): return e.kind == "ground"), "Fast downward ball must collide with ground")
	check(flight.position.y >= flight.RADIUS, "Ball cannot tunnel under court")
	if failures == 0:
		print("PASS: flight target, gravity, bounce, swept net and floor")
	quit(1 if failures else 0)
