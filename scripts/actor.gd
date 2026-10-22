extends Node3D

const Court = preload("res://scripts/court.gd")
const SPEED := 5.6
const FOOT_RADIUS := 0.17
var side := 0
var shirt := Color("faf4db")
var rig: Node3D
var paddle: Node3D
var legs: Array[Node3D] = []
var arms: Array[Node3D] = []
var animation_time := 0.0
var swing_time := 0.0
var moving := false

func _ready() -> void:
	rig = Node3D.new()
	add_child(rig)
	var skin := Color("deaa81")
	var shorts := Color("23444e")
	Court.cylinder(self, Vector3(0, 0.055, 0), 0.36, 0.012, Color("377f80"))
	Court.box(rig, Vector3(0, 0.97, 0), Vector3(0.48, 0.57, 0.3), shirt)
	Court.box(rig, Vector3(0, 0.68, 0), Vector3(0.45, 0.18, 0.29), shorts)
	Court.cylinder(rig, Vector3(0, 1.47, 0), 0.205, 0.34, skin, 8)
	Court.cylinder(rig, Vector3(0, 1.66, 0), 0.22, 0.09, shirt, 8)
	Court.box(rig, Vector3(0, 1.63, -0.18), Vector3(0.37, 0.04, 0.24), shirt)
	for s in [-1, 1]:
		var leg := Node3D.new()
		rig.add_child(leg)
		leg.position = Vector3(s * 0.135, 0.66, 0)
		Court.box(leg, Vector3(0, -0.24, 0), Vector3(0.16, 0.48, 0.18), skin)
		Court.box(leg, Vector3(0, -0.48, -0.045), Vector3(0.2, 0.13, 0.33), Color("fcf6dd"))
		legs.append(leg)
		var arm := Node3D.new()
		rig.add_child(arm)
		arm.position = Vector3(s * 0.3, 1.18, 0)
		arm.rotation.z = -s * 0.14
		Court.box(arm, Vector3(0, -0.19, 0), Vector3(0.14, 0.4, 0.16), skin)
		arms.append(arm)
	paddle = Node3D.new()
	arms[1].add_child(paddle)
	paddle.position = Vector3(0, -0.43, -0.12)
	Court.box(paddle, Vector3(0, 0, -0.06), Vector3(0.055, 0.055, 0.26), shorts)
	var face := Court.cylinder(paddle, Vector3(0, 0, -0.3), 0.18, 0.045, Color("243a48"), 8)
	face.rotation.z = PI / 2
	var inset := Court.cylinder(paddle, Vector3(0.026, 0, -0.3), 0.145, 0.004, Color("edc95b"), 8)
	inset.rotation.z = PI / 2
	if side == 1:
		rotation.y = PI

func move_input(direction: Vector2, delta: float) -> void:
	var previous := position
	position += Vector3(direction.x, 0, direction.y) * SPEED * delta
	position.x = clampf(position.x, -4.5, 4.5)
	position.z = clampf(position.z, 0.43, 8.7) if side == 0 else clampf(position.z, -8.7, -0.43)
	moving = previous.distance_to(position) > 0.001

func move_toward_point(target: Vector3, delta: float) -> void:
	var direction := Vector2(target.x - position.x, target.z - position.z)
	move_input(direction.normalized() * minf(1, direction.length() / maxf(SPEED * delta, 0.001)), delta)

func swing() -> void:
	swing_time = 0.28

func animate(delta: float) -> void:
	animation_time += delta
	swing_time = maxf(0, swing_time - delta)
	for i in 2:
		legs[i].rotation.x = sin(animation_time * 15 + i * PI) * 0.48 if moving else lerpf(legs[i].rotation.x, 0, 0.2)
		arms[i].rotation.x = -legs[i].rotation.x * 0.5
	if swing_time > 0:
		arms[1].rotation.x = -sin((1 - swing_time / 0.28) * PI) * 2.3
		arms[1].rotation.z = -sin((1 - swing_time / 0.28) * PI) * 0.7
	else:
		arms[1].rotation.z = -0.14
	rig.position.y = absf(sin(animation_time * 15)) * 0.035 if moving else 0.0
