extends Node3D
## Procedural low-poly court. One world unit is one metre.

const HALF_WIDTH := 3.048
const HALF_LENGTH := 6.7056
const KITCHEN := 2.1336
const LINE := 0.0508
var sun: DirectionalLight3D
var decor: Node3D

static func material(color: Color, unshaded := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

static func box(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	node.mesh = shape
	node.material_override = material(color)
	parent.add_child(node)
	node.position = at
	return node

static func cylinder(parent: Node3D, at: Vector3, radius: float, height: float, color: Color, vertices := 12) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = vertices
	node.mesh = shape
	node.material_override = material(color)
	parent.add_child(node)
	node.position = at
	return node

static func ring(parent: Node3D, radius: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.025
	torus.outer_radius = radius + 0.025
	torus.rings = 32
	torus.ring_segments = 8
	node.mesh = torus
	node.material_override = material(color, true)
	parent.add_child(node)
	return node

func _ready() -> void:
	var cream := Color("ecedda")
	var white := Color("f9ffef")
	var dark := Color("24484e")
	box(self, Vector3(0, -0.4, 0), Vector3(200, 0.3, 200), Color("bcd3b1"))
	box(self, Vector3(0, -0.14, 0), Vector3(15, 0.16, 23), cream)
	box(self, Vector3(0, -0.055, 0), Vector3(11.4, 0.1, 19.2), Color("79b7ad"))
	box(self, Vector3(0, 0.007, 0), Vector3(6.096, 0.045, 13.4112), Color("427fa7"))
	box(self, Vector3(0, 0.034, 0), Vector3(6.096, 0.01, 4.2672), Color("4ea397"))
	for x in [-HALF_WIDTH, HALF_WIDTH]:
		box(self, Vector3(x - signf(x) * LINE / 2, 0.043, 0), Vector3(LINE, 0.012, HALF_LENGTH * 2), white)
	for z in [-HALF_LENGTH, -KITCHEN, KITCHEN, HALF_LENGTH]:
		var centre_z: float = z - signf(z) * LINE / 2
		box(self, Vector3(0, 0.043, centre_z), Vector3(HALF_WIDTH * 2, 0.012, LINE), white)
	for side in [-1, 1]:
		box(self, Vector3(0, 0.043, side * (HALF_LENGTH + KITCHEN) / 2), Vector3(LINE, 0.012, HALF_LENGTH - KITCHEN), white)
	for x in [-3.18, 3.18]:
		cylinder(self, Vector3(x, 0.52, 0), 0.055, 1.04, dark)
		cylinder(self, Vector3(x, 0.05, 0), 0.17, 0.05, dark)
	# Thin strands keep the opponent and ball visible through the net.
	for n in 49:
		var x: float = -3.12 + n * 0.13
		box(self, Vector3(x, 0.47, 0), Vector3(0.011, 0.79, 0.013), dark)
	for n in 8:
		box(self, Vector3(0, 0.10 + n * 0.10, 0), Vector3(6.3, 0.012, 0.014), dark)
	for n in 24:
		var x := -3.12 + (n + 0.5) * 0.26
		var h := lerpf(0.8636, 0.9144, absf(x) / HALF_WIDTH)
		box(self, Vector3(x, h - 0.018, 0), Vector3(0.265, 0.036, 0.045), white)
	# Open, bright club setting with simple benches and faceted trees.
	decor = Node3D.new()
	decor.name = "Decor"
	add_child(decor)
	for side in [-1, 1]:
		for z in [-5.0, 3.8]:
			box(decor, Vector3(side * 6.4, 0.45, z), Vector3(0.65, 0.13, 2.2), Color("c9a47c"))
			box(decor, Vector3(side * 6.7, 0.8, z), Vector3(0.1, 0.55, 2.2), Color("c9a47c"))
			for dz in [-0.75, 0.75]:
				box(decor, Vector3(side * 6.4, 0.2, z + dz), Vector3(0.5, 0.4, 0.08), dark)
		for z in [-10.0, -3.0, 6.0, 12.0]:
			var x: float = side * (9.1 + fmod(absf(z), 2))
			cylinder(decor, Vector3(x, 0.7, z), 0.16, 1.4, Color("a58c67"), 6)
			var tree := cylinder(decor, Vector3(x, 2.3, z), 1.25, 2.8, Color("75a77c"), 7)
			(tree.mesh as CylinderMesh).top_radius = 0.05
	for z in [-11.0, 11.0]:
		box(self, Vector3(0, 0.19, z), Vector3(16, 0.38, 0.5), Color("a1bda4"))
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("c3dfe1")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("e1eff2")
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = env
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-53, -28, 0)
	sun.light_color = Color("fff5dc")
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 45
	add_child(sun)

func set_low_detail(enabled: bool) -> void:
	sun.shadow_enabled = not enabled
	decor.visible = not enabled
