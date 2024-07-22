extends Area2D

var VelocityPerPixel = 200
var WhichPos = 0
var velocity = Vector2()
var StopMoving = false

func _ready():
	$AnimatedSprite2D.play("default")
#	randomize()
#	var PosR = int(randf_range(1, 5))
#	SetPosRamdon(PosR)

func SetPosRamdon(Pos):
	if Pos == 1:#Right
		position.x = 845
		position.y = randf_range(34, 570)
		WhichPos = 1
	elif Pos == 2:#Left
		position.x = -34
		position.y = randf_range(34, 570)
		WhichPos = 2
	elif Pos == 3:#Up
		position.x = randf_range(40, 770)
		position.y = -34
		WhichPos = 3
	elif Pos == 4:#Down
		position.x = randf_range(40, 770)
		position.y = 630
		WhichPos = 4

func MoveStone(Direcction, delta):
	velocity = Vector2()
	if Direcction == 1:
		velocity.x = -1
	if Direcction == 2:
		velocity.x = 1
	if Direcction == 3:
		velocity.y = 1
	if Direcction == 4:
		velocity.y = -1
	if velocity.length() > 0:
		velocity = velocity.normalized() * VelocityPerPixel * delta
	position += velocity

func WallForStone(Pos):
	if Pos == 1:#Right
		if position.x <= -30:
			call_deferred("queue_free")
	elif Pos == 2:#Left
		if position.x >= 840:
			call_deferred("queue_free")
	elif Pos == 3:#Up
		if position.y >= 630:
			call_deferred("queue_free")
	elif Pos == 4:#Down
		if position.y <= -30:
			call_deferred("queue_free")

func StoneExplote():
	$AnimatedSprite2D.visible = false
	$AnimatedSprite2DExplotion.visible = true
	$AnimatedSprite2DExplotion.play("default")

func _process(delta):
	if StopMoving:
		set_process(false)
	MoveStone(WhichPos, delta)
	WallForStone(WhichPos)

func _on_area_entered(area):
	if area.is_in_group("PlayerHit") or area.is_in_group("shield"):
		StopMoving = true
		StoneExplote()

func _on_animated_sprite_2d_explotion_animation_finished():
	call_deferred("queue_free")
