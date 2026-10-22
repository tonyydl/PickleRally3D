extends SceneTree
## Render real Windows viewport frames for repeatable visual inspection.

func _initialize() -> void:
	call_deferred("capture")

func save_view(game, name: String) -> void:
	game.update_visuals(1.0 / 60)
	game.hud.refresh()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/visual/%s.png" % name)

func prepare_shot(game, feet: Vector3, point: Vector3, bounced: bool) -> void:
	game.restart()
	game.phase = "rally"
	game.rules.begin_rally()
	game.rules.last_hitter = 1
	game.rules.hit_count = 4
	game.rules.bounced_once = [true, true]
	game.rules.bounce_count = 1 if bounced else 0
	game.player.position = feet
	game.flight.position = point
	game.flight.velocity = Vector3(0, -0.1, 2)
	game.flight.active = true

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
	game.set_paused(false)
	game.rules.score = [10, 0]
	game.rules.fault(1, "兩次彈地")
	game.finish_rally()
	game.hud.refresh()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/visual/win.png")
	var shots := [
		["dink", &"soft", Vector3(0, 0, 2.7), Vector3(0.3, 0.6, 2.5), true, 30],
		["drop", &"soft", Vector3(0, 0, 5.2), Vector3(0.3, 0.7, 5), true, 50],
		["lob", &"lob", Vector3(0, 0, 5.2), Vector3(0.3, 0.8, 5), true, 108],
		["smash", &"smash", Vector3(0, 0, 2.7), Vector3(0.3, 2.3, 2.5), false, 16]
	]
	for row in shots:
		prepare_shot(game, row[2], row[3], row[4])
		if row[0] == "smash":
			await save_view(game, "smash_ready")
		game.request_swing(row[1])
		for i in row[5]:
			game.simulate(1.0 / 120)
			game.update_visuals(1.0 / 120)
		await save_view(game, row[0])
	print("PASS: rendered ready/rally/pause/win and Dink/Drop/Lob/Smash screenshots")
	# Let the last short effect finish before destroying its native playback.
	if game.audio.playing:
		await game.audio.finished
	await process_frame
	game.free()
	await process_frame
	quit()
