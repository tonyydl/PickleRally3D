extends RefCounted
## Singles side-out scoring; independent of rendering and input.

const HALF_WIDTH := 3.048
const HALF_LENGTH := 6.7056
const KITCHEN := 2.1336
const FOOT_RADIUS := 0.17
var score: Array = [0, 0]
var server := 0
var winner := -1
var live := false
var last_hitter := -1
var hit_count := 0
var bounce_count := 0
var bounced_once: Array = [false, false]
var volley_pending: Array = [false, false]
var result := ""
var last_rally_winner := -1

func reset() -> void:
	score = [0, 0]
	server = 0
	winner = -1
	live = false
	last_hitter = -1
	hit_count = 0
	bounce_count = 0
	bounced_once = [false, false]
	volley_pending = [false, false]
	result = ""
	last_rally_winner = -1

func begin_rally() -> void:
	if winner != -1:
		return
	live = true
	last_hitter = -1
	hit_count = 0
	bounce_count = 0
	bounced_once = [false, false]
	volley_pending = [false, false]
	result = ""

func service_x(side: int) -> float:
	return (1.5 if score[side] % 2 == 0 else -1.5) * (1 if side == 0 else -1)

static func in_court(point: Vector3) -> bool:
	return absf(point.x) <= HALF_WIDTH + 0.00001 and absf(point.z) <= HALF_LENGTH + 0.00001

static func in_kitchen(feet: Vector3) -> bool:
	return absf(feet.z) <= KITCHEN + FOOT_RADIUS and absf(feet.x) <= HALF_WIDTH + FOOT_RADIUS

func can_volley(side: int) -> bool:
	return bounced_once[0] and bounced_once[1] and side != last_hitter

func legal_service_feet(side: int, feet: Vector3) -> bool:
	var own_side := feet.z > 0 if side == 0 else feet.z < 0
	return own_side and absf(feet.z) - FOOT_RADIUS > HALF_LENGTH and absf(feet.x) + FOOT_RADIUS < HALF_WIDTH and feet.x * service_x(side) > FOOT_RADIUS * absf(service_x(side))

func hit(side: int, feet: Vector3) -> String:
	if not live:
		return "回合尚未開始"
	var reason := ""
	if last_hitter == -1:
		if side != server:
			reason = "發球順序錯誤"
		elif not legal_service_feet(side, feet):
			reason = "發球站位違例"
	elif side == last_hitter:
		reason = "重複擊球"
	elif not bounced_once[side]:
		reason = "兩次落地規則：必須先讓球落地"
	elif bounce_count == 0 and in_kitchen(feet):
		reason = "Kitchen 違例：非截擊區內不能截擊"
	if not reason.is_empty():
		fault(side, reason)
		return reason
	if last_hitter != -1 and bounce_count == 0:
		volley_pending[side] = true
	last_hitter = side
	hit_count += 1
	bounce_count = 0
	return ""

func check_kitchen(side: int, feet: Vector3) -> void:
	if live and volley_pending[side] and in_kitchen(feet):
		fault(side, "Kitchen 違例：截擊後踏入非截擊區")

func bounce(point: Vector3) -> String:
	if not live or last_hitter == -1:
		return ""
	volley_pending = [false, false]
	var landing_side := 0 if point.z > 0 else 1
	var reason := ""
	var loser := last_hitter
	if bounce_count > 0:
		loser = 1 - last_hitter
		reason = "兩次彈地"
	elif not in_court(point):
		reason = "出界"
	elif landing_side == last_hitter:
		reason = "球未落入對方場地"
	elif hit_count == 1 and (absf(point.z) <= KITCHEN + 0.00001 or point.x * signf(service_x(server)) > 0.0254 + 0.00001):
		reason = "發球須對角落在 Kitchen 後方"
	if not reason.is_empty():
		fault(loser, reason)
		return reason
	bounce_count += 1
	bounced_once[landing_side] = true
	return ""

func fault(loser: int, reason: String) -> void:
	if not live or winner != -1:
		return
	live = false
	last_rally_winner = 1 - loser
	if last_rally_winner == server:
		score[server] += 1
		result = reason + " · " + ("你得分" if server == 0 else "AI 得分")
	else:
		server = last_rally_winner
		result = reason + " · 換發球"
	if score[server] >= 11 and score[server] - score[1 - server] >= 2:
		winner = server
