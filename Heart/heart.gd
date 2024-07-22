extends Area2D

var VelocityPerPixel = 200
var PosSelected = 0
var Moving = false
var velocity = Vector2()
var TimerToFreeHeart = Timer.new()

func _ready():
	TimerToFreeHeartSettings()
	WhichMove()

func TimerToFreeHeartSettings():
	TimerToFreeHeart.wait_time = 5
	TimerToFreeHeart.one_shot = true
	TimerToFreeHeart.connect("timeout", self._on_TimerToFreeHeart_timeout)
	add_child(TimerToFreeHeart)

func WhichMove():
	randomize()
	var MovingOrStatic = int(randf_range(1, 3))
	if MovingOrStatic == 1:
		TimerToFreeHeart.start()
		SetPosRamdom()
	elif MovingOrStatic == 2:
		SetDirecction()
		SetPosForMoving(PosSelected)
		Moving = true

func SetPosRamdom():
	randomize()
	position.x = randf_range(45, 750)
	position.y = randf_range(40, 560)

func _on_TimerToFreeHeart_timeout():
	call_deferred("queue_free")

func SetDirecction():
	randomize()
	PosSelected = int(randf_range(1, 5))

func SetPosForMoving(Pos):
	if Pos == 1:#Right
		position.x = -44
		position.y = randf_range(40, 560)
	elif Pos == 2:#Left
		position.x = 845
		position.y = randf_range(40, 560)
	elif Pos == 3:#Up
		position.x = randf_range(45, 750)
		position.y = 638
	elif Pos == 4:#Down
		position.x = randf_range(45, 750)
		position.y = -37

func MoveHeart(Move, Delta):
	velocity = Vector2()
	if Move == 1:#Right
		velocity.x = 1
	if Move == 2:#Left
		velocity.x = -1
	if Move == 3:#Up
		velocity.y = -1
	if Move == 4:#Down
		velocity.y = 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * VelocityPerPixel * Delta
	position += velocity

func WallForStone(Pos):
	if Pos == 1:#Right
		if position.x >= 850:
			call_deferred("queue_free")
	elif Pos == 2:#Left
		if position.x <= -50:
			call_deferred("queue_free")
	elif Pos == 3:#Up
		if position.y <= -40:
			call_deferred("queue_free")
	elif Pos == 4:#Down
		if position.y >= 640:
			call_deferred("queue_free")

func _process(delta):
	if !Moving:
		set_process(false)
	MoveHeart(PosSelected, delta)
	WallForStone(PosSelected)

func _on_area_entered(area):
	if area.is_in_group("PlayerHit"):
		call_deferred("queue_free")
