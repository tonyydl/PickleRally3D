extends RefCounted
## Metres, seconds; exact ballistic integration with chronological swept contacts.

const GRAVITY := 9.8
const RADIUS := 0.04
const RESTITUTION := 0.74
var position := Vector3.ZERO
var velocity := Vector3.ZERO
var active := false

func launch(origin: Vector3, target: Vector3, duration: float) -> void:
	position = origin
	velocity = (target - origin) / duration + Vector3.UP * GRAVITY * duration * 0.5
	active = true

func landing() -> Vector3:
	var t := ground_time()
	return Vector3(position.x + velocity.x * t, RADIUS, position.z + velocity.z * t)

func ground_time() -> float:
	return (velocity.y + sqrt(maxf(0, velocity.y * velocity.y + 2 * GRAVITY * (position.y - RADIUS)))) / GRAVITY

static func net_height(x: float) -> float:
	return lerpf(0.8636, 0.9144, clampf(absf(x) / 3.048, 0, 1))

static func duration_for(origin: Vector3, target: Vector3, volley := false) -> float:
	var duration := clampf(origin.distance_to(target) / (9.0 if volley else 8.0), 0.8, 1.6)
	if origin.z * target.z < 0:
		var fraction := absf(origin.z) / absf(target.z - origin.z)
		for i in 30:
			var y := lerpf(origin.y, target.y, fraction) + 0.5 * GRAVITY * duration * duration * fraction * (1 - fraction)
			if y > 1.16:
				break
			duration += 0.04
	return duration

func advance(t: float) -> void:
	position += velocity * t + Vector3.DOWN * GRAVITY * t * t * 0.5
	velocity.y -= GRAVITY * t

func step(delta: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if not active:
		return events
	var remaining := delta
	for iteration in 8:
		if remaining < 0.000001:
			break
		var floor_t := ground_time()
		var net_t := INF
		if absf(velocity.z) > 0.001 and position.z * velocity.z < 0:
			var crossing := -position.z / velocity.z
			var crossing_point := position + velocity * crossing + Vector3.DOWN * GRAVITY * crossing * crossing * 0.5
			if crossing <= remaining and absf(crossing_point.x) <= 3.15 and crossing_point.y - RADIUS <= net_height(crossing_point.x):
				net_t = crossing
		if floor_t <= remaining and floor_t <= net_t:
			advance(floor_t)
			position.y = RADIUS
			velocity.y = absf(velocity.y) * RESTITUTION
			velocity.x *= 0.86
			velocity.z *= 0.86
			events.append({"kind": "ground", "point": position})
			remaining -= maxf(floor_t, 0.000001)
		elif net_t <= remaining:
			advance(net_t)
			velocity.z *= -0.18
			velocity.x *= 0.6
			position.z = signf(velocity.z) * 0.045
			events.append({"kind": "net", "point": position})
			remaining -= maxf(net_t, 0.000001)
		else:
			advance(remaining)
			break
	return events
