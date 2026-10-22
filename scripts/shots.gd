extends RefCounted
## Input intent -> actual shot and ballistic parameters. No rendering or match state.

const Flight = preload("res://scripts/flight.gd")
const SOFT_DISTANCE := 3.4
const SMASH_HEIGHT := 1.65
const LABELS := {
	&"serve": "發球", &"drive": "Drive 抽球", &"dink": "Dink 網前小球",
	&"drop": "Drop 放短球", &"lob": "Lob 高吊球", &"smash": "Smash 扣殺"
}
const COLORS := {
	&"serve": Color("efcf69"), &"drive": Color("61bec9"), &"dink": Color("78c9a1"),
	&"drop": Color("8daee7"), &"lob": Color("b59ae5"), &"smash": Color("ef8b69")
}

static func label_for(kind: StringName) -> String:
	return LABELS.get(kind, "Drive 抽球")

static func color_for(kind: StringName) -> Color:
	return COLORS.get(kind, COLORS[&"drive"])

static func resolve(intent: StringName, feet: Vector3, origin: Vector3) -> StringName:
	if intent == &"soft":
		return &"dink" if absf(feet.z) <= SOFT_DISTANCE + 0.00001 else &"drop"
	if intent == &"smash" and origin.y < SMASH_HEIGHT - 0.00001:
		return &"drive"
	return intent if intent in LABELS else &"drive"

static func minimum_clearance_time(origin: Vector3, target: Vector3, margin: float) -> float:
	if origin.z * target.z >= 0:
		return 0.0
	var fraction := absf(origin.z) / absf(target.z - origin.z)
	var cross_x := lerpf(origin.x, target.x, fraction)
	var clearance := Flight.net_height(cross_x) + Flight.RADIUS + margin
	var straight_y := lerpf(origin.y, target.y, fraction)
	return sqrt(maxf(0, 2 * (clearance - straight_y) / (Flight.GRAVITY * fraction * (1 - fraction))))

static func build(intent: StringName, origin: Vector3, feet: Vector3, aim: Vector2, side: int, service := false) -> Dictionary:
	var kind: StringName = &"serve" if service else resolve(intent, feet, origin)
	var reason := ""
	if not service and intent == &"smash" and kind != &"smash":
		reason = "球太低，改用 Drive"
	var facing := -1.0 if side == 0 else 1.0
	var target := Vector3(clampf(aim.x, -1, 1) * 2.25, Flight.RADIUS, 0)
	var depth := clampf(4.4 - aim.y * 2.5, 0.9, 6.05)
	var margin := 0.16
	if kind == &"serve":
		target.x = -1.5 * signf(feet.x)
		depth = 4.9
	elif kind == &"dink" or kind == &"drop":
		depth = clampf(1.3 - aim.y * 0.45, 0.85, 1.75)
		margin = 0.09 if kind == &"dink" else 0.12
	elif kind == &"lob":
		depth = clampf(5.7 - aim.y * 0.7, 4.8, 6.05)
	elif kind == &"smash":
		depth = clampf(5.5 - aim.y * 0.7, 4.6, 6.05)
		margin = 0.05
	target.z = facing * depth
	var distance := Vector2(target.x - origin.x, target.z - origin.z).length()
	var duration := clampf(distance / 12.0, 0.35, 1.15)
	if kind == &"serve":
		duration = Flight.duration_for(origin, target)
	elif kind == &"dink":
		duration = clampf(distance / 5, 0.42, 1.05)
	elif kind == &"drop":
		duration = clampf(distance / 6.5, 0.95, 1.6)
	elif kind == &"lob":
		var apex := maxf(4.8, origin.y + 0.7)
		duration = (sqrt(2 * Flight.GRAVITY * (apex - origin.y)) + sqrt(2 * Flight.GRAVITY * (apex - target.y))) / Flight.GRAVITY
	elif kind == &"smash":
		var downward_limit := sqrt(2 * (origin.y - target.y) / Flight.GRAVITY) * 0.88
		var minimum := minimum_clearance_time(origin, target, margin) + 0.006
		if minimum >= downward_limit:
			var fallback := build(&"drive", origin, feet, aim, side)
			fallback.reason = "角度不足，改用 Drive"
			return fallback
		duration = clampf(distance / 19, maxf(0.18, minimum), downward_limit)
	duration = maxf(duration, minimum_clearance_time(origin, target, margin) + 0.006)
	return {"kind": kind, "target": target, "duration": duration, "reason": reason}
