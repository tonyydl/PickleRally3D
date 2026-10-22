extends CanvasLayer
## Chinese HUD with a quiet frame around the court and clear rally prompts.

const INK := Color("173f42")
const MUTED := Color("5b7e79")
const PAPER := Color("f8f6e9")
var game: Node3D
var root: Control
var score_label: Label
var player_name: Label
var ai_name: Label
var server_label: Label
var rally_label: Label
var best_label: Label
var title_label: Label
var hint_label: Label
var shot_label: Label
var rule_label: Label
var pause_button: Button
var overlay: Panel
var overlay_title: Label
var overlay_hint: Label
var continue_button: Button
var message_panel: Panel

func style(color: Color, radius := 16) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	return box

func panel(parent: Node, rect: Rect2, color: Color, anchor := Vector2.ZERO) -> Panel:
	var node := Panel.new()
	parent.add_child(node)
	node.anchor_left = anchor.x
	node.anchor_right = anchor.x
	node.anchor_top = anchor.y
	node.anchor_bottom = anchor.y
	node.offset_left = rect.position.x
	node.offset_top = rect.position.y
	node.offset_right = rect.end.x
	node.offset_bottom = rect.end.y
	node.add_theme_stylebox_override("panel", style(color))
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func label(parent: Node, text: String, rect: Rect2, font_size: int, color := INK, centered := false) -> Label:
	var node := Label.new()
	parent.add_child(node)
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if centered:
		node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func button(parent: Node, text: String, rect: Rect2, action: Callable, dark := false) -> Button:
	var node := Button.new()
	parent.add_child(node)
	node.position = rect.position
	node.size = rect.size
	node.text = text
	node.focus_mode = Control.FOCUS_NONE
	node.add_theme_font_size_override("font_size", 16)
	node.add_theme_color_override("font_color", PAPER if dark else INK)
	node.add_theme_stylebox_override("normal", style(INK if dark else Color("e4e9d8"), 10))
	node.add_theme_stylebox_override("hover", style(Color("32635e") if dark else Color("d1dfc6"), 10))
	node.add_theme_stylebox_override("pressed", style(Color("4a7971"), 10))
	node.pressed.connect(action)
	return node

func _ready() -> void:
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Microsoft JhengHei UI", "Microsoft JhengHei", "Noto Sans CJK TC", "sans-serif"])
	theme.default_font = font
	root.theme = theme
	var brand := panel(root, Rect2(24, 24, 255, 94), Color(0.97, 0.96, 0.90, 0.94))
	label(brand, "PICKLE", Rect2(18, 6, 210, 27), 18, MUTED)
	label(brand, "RALLY 3D", Rect2(16, 28, 225, 44), 33)
	label(brand, "陽光球場  /  單人對戰", Rect2(18, 70, 225, 17), 12, MUTED)
	var scores := panel(root, Rect2(-204, 24, 408, 94), PAPER, Vector2(0.5, 0))
	player_name = label(scores, "玩家", Rect2(16, 16, 90, 27), 18, INK, true)
	ai_name = label(scores, "AI 對手", Rect2(302, 16, 90, 27), 18, INK, true)
	var score_bg := panel(scores, Rect2(112, 10, 184, 62), INK)
	score_label = label(score_bg, "0   :   0", Rect2(0, 0, 184, 62), 35, PAPER, true)
	server_label = label(scores, "● 你發球", Rect2(16, 51, 90, 24), 12, MUTED, true)
	label(scores, "11 分制  ·  領先 2 分", Rect2(108, 73, 192, 16), 11, MUTED, true)
	var stats := panel(root, Rect2(-220, 24, 196, 94), PAPER, Vector2(1, 0))
	label(stats, "RALLY / 來回拍數", Rect2(16, 9, 170, 22), 13, MUTED)
	rally_label = label(stats, "00", Rect2(14, 27, 80, 48), 36)
	best_label = label(stats, "最佳 00", Rect2(97, 43, 91, 26), 13, MUTED)
	label(stats, "傳統發球方得分制", Rect2(16, 74, 170, 16), 11, MUTED)
	message_panel = panel(root, Rect2(-260, -174, 520, 68), Color(0.97, 0.96, 0.90, 0.95), Vector2(0.5, 1))
	title_label = label(message_panel, "準備發球", Rect2(12, 4, 496, 32), 21, INK, true)
	hint_label = label(message_panel, "左鍵發球，朝黃色落點移動接球", Rect2(10, 37, 500, 23), 13, MUTED, true)
	var guide := panel(root, Rect2(24, 143, 214, 154), Color(0.97, 0.96, 0.90, 0.89))
	label(guide, "COURT 01", Rect2(16, 11, 180, 22), 13, MUTED)
	label(guide, "先落地，再回擊", Rect2(16, 37, 186, 28), 18)
	rule_label = label(guide, "發球與接發球皆須先彈地\nKitchen 內可打落地球\n但不能截擊", Rect2(16, 72, 186, 68), 13, MUTED)
	var legend := panel(root, Rect2(-220, 143, 196, 115), Color(0.97, 0.96, 0.90, 0.89), Vector2(1, 0))
	label(legend, "球場提示", Rect2(16, 11, 166, 24), 16)
	label(legend, "● 黃圈  球的預測落點\n○ 白圈  你的擊球目標\n■ 綠色區域  Kitchen", Rect2(16, 42, 170, 61), 12, MUTED)
	shot_label = label(root, "", Rect2(0, 0, 300, 32), 19, INK, true)
	shot_label.anchor_left = 0.5
	shot_label.anchor_right = 0.5
	shot_label.offset_left = -150
	shot_label.offset_right = 150
	shot_label.offset_top = 142
	shot_label.offset_bottom = 174
	var footer := panel(root, Rect2(24, -88, 1232, 64), PAPER, Vector2(0, 1))
	footer.anchor_right = 1
	footer.offset_right = -24
	label(footer, "W A S D", Rect2(18, 8, 100, 23), 17)
	label(footer, "移動 / 擊球時瞄準", Rect2(18, 34, 178, 18), 12, MUTED)
	label(footer, "滑鼠左鍵", Rect2(205, 8, 126, 23), 17)
	label(footer, "發球 / 揮拍 / 下一回合", Rect2(205, 34, 210, 18), 12, MUTED)
	label(footer, "A D 左右 · W 深球 · S 短球", Rect2(440, 11, 330, 22), 14)
	label(footer, "不按方向鍵，安全打向中央", Rect2(440, 35, 330, 17), 12, MUTED)
	pause_button = button(footer, "暫停  Esc", Rect2(902, 11, 130, 42), func(): game.set_paused(not game.paused))
	pause_button.anchor_left = 1
	pause_button.anchor_right = 1
	pause_button.offset_left = -294
	pause_button.offset_right = -164
	var restart_button := button(footer, "重新開始  R", Rect2(1048, 11, 160, 42), func(): game.restart(), true)
	restart_button.anchor_left = 1
	restart_button.anchor_right = 1
	restart_button.offset_left = -148
	restart_button.offset_right = -18
	overlay = panel(root, Rect2(-270, -128, 540, 256), PAPER, Vector2(0.5, 0.5))
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_title = label(overlay, "已暫停", Rect2(20, 24, 500, 52), 31, INK, true)
	overlay_hint = label(overlay, "按 Esc 或繼續比賽", Rect2(20, 86, 500, 50), 17, MUTED, true)
	continue_button = button(overlay, "繼續比賽", Rect2(72, 168, 182, 48), func(): game.set_paused(false), true)
	button(overlay, "重新開始", Rect2(274, 168, 194, 48), func(): game.restart())
	overlay.visible = false

func refresh() -> void:
	if not is_instance_valid(game.player):
		return
	var r = game.rules
	score_label.text = "%d   :   %d" % [r.score[0], r.score[1]]
	server_label.text = "● 你發球" if r.server == 0 else "● AI 發球"
	server_label.position.x = 16 if r.server == 0 else 302
	player_name.modulate = Color.WHITE if r.server == 0 else Color(1, 1, 1, 0.65)
	ai_name.modulate = Color.WHITE if r.server == 1 else Color(1, 1, 1, 0.65)
	rally_label.text = "%02d" % game.shot_count
	best_label.text = "最佳 %02d" % game.best_rally
	shot_label.text = game.feedback if game.feedback_time > 0 and game.phase == "rally" else ""
	message_panel.visible = not game.paused and game.phase != "over"
	if game.phase == "ready":
		title_label.text = "你的發球" if r.server == 0 else "準備接 AI 發球"
		hint_label.text = "站在底線後方，按左鍵對角發球" if r.server == 0 else "按左鍵準備，AI 將在片刻後發球"
		if r.server == 0 and not r.legal_service_feet(0, game.player.position):
			hint_label.text = "請回到底線後方的正確發球側"
	elif game.phase == "ai_serve":
		title_label.text = "AI 準備發球"
		hint_label.text = "追黃色落點，等球彈地後按左鍵"
	elif game.phase == "result":
		title_label.text = "你拿下這一球！" if r.last_rally_winner == 0 else "下一球再來！"
		hint_label.text = r.result + "  /  左鍵繼續"
	else:
		var incoming: bool = r.last_hitter == 1
		var required: bool = incoming and not r.bounced_once[0]
		title_label.text = "等球落地再回擊" if required else ("靠近球，左鍵擊球" if incoming else "漂亮！回到場中央")
		hint_label.text = "發球後的首次接球，雙方都必須先讓球彈地" if required else "Kitchen 內僅可擊打落地球" if Rules_kitchen() else "按 A / D 控制左右，W 打深球，S 打短球"
	overlay.visible = game.paused or game.phase == "over"
	pause_button.text = "繼續  Esc" if game.paused else "暫停  Esc"
	if game.phase == "over":
		overlay_title.text = "你贏得比賽！" if r.winner == 0 else "AI 贏得比賽"
		overlay_hint.text = "%d : %d  ·  %s\n按 R 或重新開始，再打一場" % [r.score[0], r.score[1], r.result]
		continue_button.visible = false
	else:
		overlay_title.text = "比賽已暫停"
		overlay_hint.text = "喝口水，準備下一拍。\n按 Esc 或下方按鈕繼續。"
		continue_button.visible = true

func Rules_kitchen() -> bool:
	return game.rules.in_kitchen(game.player.position)
