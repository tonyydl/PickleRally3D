extends SceneTree
## Render real Windows viewport frames for repeatable visual inspection.

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	DirAccess.make_dir_recursive_absolute("res://.tools/visual")
	await process_frame
	game.hud.refresh()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/visual/ready.png")
	game.request_swing()
	for i in 260:
		game.simulate(1.0 / 120)
	game.update_visuals(1)
	game.hud.refresh()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/visual/rally.png")
	game.set_paused(true)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/visual/pause.png")
	print("PASS: rendered ready/rally/pause screenshots")
	game.free()
	await process_frame
	quit()
