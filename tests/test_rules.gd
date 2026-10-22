extends SceneTree

var failures := 0
var Rules

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func started():
	var r = Rules.new()
	r.begin_rally()
	r.hit(0, Vector3(1.5, 0, 7.1))
	return r

func open_rally():
	var r = started()
	r.bounce(Vector3(-1.5, 0.04, -4.8))
	r.hit(1, Vector3(-1.5, 0, -4.7))
	r.bounce(Vector3(0, 0.04, 4.8))
	r.hit(0, Vector3(0, 0, 4.5))
	return r

func _initialize() -> void:
	Rules = load("res://scripts/rules.gd")
	if Rules == null:
		print("FAIL: Rules feature is missing")
		quit(1)
		return
	var r = started()
	check(r.live and r.last_hitter == 0, "Legal serve must start rally")
	r.hit(1, Vector3(0, 0, -4))
	check(not r.live and r.score[0] == 1, "Receiver cannot volley serve")
	r = started()
	r.bounce(Vector3(-1, 0.04, -4))
	r.hit(1, Vector3(-1, 0, -4))
	r.hit(0, Vector3(0, 0, 4))
	check(not r.live and r.server == 1 and r.score[1] == 0, "Server must let return bounce; side out gives no point")
	r = started()
	r.bounce(Vector3(1, 0.04, -4))
	check(not r.live and r.server == 1, "Serve must land diagonally")
	r = started()
	r.bounce(Vector3(-1, 0.04, -2.1336))
	check(not r.live and r.server == 1, "Kitchen service line is out")
	r = started()
	r.bounce(Vector3(-3.048, 0.04, -6.7056))
	check(r.live, "Baseline/sideline corner is in on serve")
	r = started()
	r.bounce(Vector3(0, 0.04, -4.2))
	check(r.live, "Service centre line is in")
	r = started()
	r.bounce(Vector3(0.02, 0.04, -4.2))
	check(r.live, "Whole centre-line width belongs to both service courts")
	r = started()
	r.bounce(Vector3(-3.06, 0.04, -4))
	check(not r.live, "Beyond sideline is out")
	r = started()
	r.bounce(Vector3(-1, 0.04, -4))
	r.bounce(Vector3(-1, 0.04, -5))
	check(not r.live and r.score[0] == 1, "Second bounce loses rally")
	r = started()
	r.bounce(Vector3(0, 0.04, 4))
	check(not r.live and r.server == 1, "Ball landing on hitter side is a fault")
	r = open_rally()
	check(r.live and r.can_volley(1), "Two legal bounces unlock volleys")
	r.hit(1, Vector3(0, 0, -2.2))
	check(not r.live and r.score[0] == 1, "Foot overlap with kitchen line forbids volley")
	r = open_rally()
	r.hit(1, Vector3(0, 0, -2.5))
	check(r.live, "Volley outside kitchen is legal")
	r.check_kitchen(1, Vector3(0, 0, -1.9))
	check(not r.live, "Volley momentum into kitchen must fault")
	r = open_rally()
	r.bounce(Vector3(0, 0.04, -1.0))
	r.hit(1, Vector3(0, 0, -1.1))
	check(r.live, "Bounced shot may be hit inside kitchen")
	r = Rules.new()
	r.score = [1, 0]
	check(r.service_x(0) < 0 and r.service_x(1) < 0, "Service side follows score parity and facing direction")
	r.begin_rally()
	r.hit(0, Vector3(-1.5, 0, 7.1))
	r.bounce(Vector3(1.5, 0.04, -4))
	check(r.live, "Odd-score serve uses other diagonal")
	r = Rules.new()
	r.begin_rally()
	r.hit(0, Vector3(1.5, 0, 6.8))
	check(not r.live and r.server == 1, "Service foot touching baseline is a fault")
	r = Rules.new()
	r.score = [10, 10]
	r.begin_rally()
	r.fault(1, "test")
	check(r.score == [11, 10] and r.winner == -1, "11-10 must continue")
	r.begin_rally()
	r.fault(1, "test")
	check(r.score == [12, 10] and r.winner == 0, "12-10 wins")
	r.begin_rally()
	check(not r.live, "Finished match cannot restart rally")
	r.fault(1, "test")
	check(r.score == [12, 10], "Duplicate fault cannot award points")
	r.reset()
	check(r.score == [0, 0] and r.winner == -1 and r.server == 0, "Restart must clear match state")
	if failures == 0:
		print("PASS: singles service, lines, two-bounce, kitchen, side-out, deuce, win, reset")
	quit(1 if failures else 0)
