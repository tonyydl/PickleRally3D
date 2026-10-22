extends Node3D

const Court = preload("res://scripts/court.gd")
const Actor = preload("res://scripts/actor.gd")
const Flight = preload("res://scripts/flight.gd")
var flight = Flight.new()
var player: Node3D
var opponent: Node3D
var ball: MeshInstance3D
var camera: Camera3D
var landing_marker: MeshInstance3D

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
	player.position = Vector3(1.45, 0, 7.1)
	opponent = Actor.new()
	opponent.side = 1
	opponent.shirt = Color("de735f")
	add_child(opponent)
	opponent.position = Vector3(-1.45, 0, -5.7)
	ball = Court.cylinder(self, Vector3(1.45, 0.75, 6.8), 0.105, 0.21, Color("eafa4b"))
	var sphere := SphereMesh.new()
	sphere.radius = 0.105
	sphere.height = 0.21
	sphere.radial_segments = 12
	sphere.rings = 6
	ball.mesh = sphere
	landing_marker = Court.ring(self, 0.28, Color("edfa55"))
	landing_marker.visible = false
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0, 10.9, 17.4)
	camera.fov = 53
	camera.look_at(Vector3(0, 0, -0.3))
	camera.current = true

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "forward", "back")
	player.move_input(direction, delta)
	player.animate(delta)
	opponent.animate(delta)
	flight.step(delta)
	if flight.active:
		ball.position = flight.position
		landing_marker.visible = true
		landing_marker.position = flight.landing() + Vector3.UP * 0.02
	camera.position.x = lerpf(camera.position.x, player.position.x * 0.28, delta * 3)
	camera.look_at(Vector3(player.position.x * 0.12, 0, -0.3))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		flight.launch(player.position + Vector3(0, 0.7, -0.3), Vector3(-1.5, 0.04, -4.7), 1.6)
		player.swing()
