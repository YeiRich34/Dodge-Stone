extends Area2D

signal StoneHitPlayer
signal ShieldActivated
signal PickedHeart

var TimerDisapierPlayer = Timer.new()
var VelocityMove = 300
var velocity = Vector2()
var OneTimeWalkDust = true
var ActiveShield = false
var AllowHurt = true
var AllowDeath = true
var GameOverV = false
var LandSpeelShield = false

func _ready():
	$AnimatedSprite2D.play("idle")
	$AnimatedWalk.visible = false
	TimerDisapierSettings()

func TimerDisapierSettings():
	TimerDisapierPlayer.one_shot = true
	TimerDisapierPlayer.wait_time = 2
	TimerDisapierPlayer.connect("timeout", self._on_TimerDisapierPlayer_timeout)
	add_child(TimerDisapierPlayer)

func MovePlayer(delty):
	velocity = Vector2()
	if Input.is_action_pressed("ui_up"):
		velocity.y = -1
	if Input.is_action_pressed("ui_down"):
		velocity.y = 1
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1
	if Input.is_action_pressed("ui_right"):
		velocity.x = 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * VelocityMove * delty
	position += velocity
	
	if Input.is_action_just_pressed("ui_f"):
		if LandSpeelShield:
			ActiveShield = true
			emit_signal("ShieldActivated")
			ActivateShield()
	
	if AllowHurt:
		SetAnimateToPlayer()
	WallsToPlayer()

func SetAnimateToPlayer():
	if velocity.x != 0 or velocity.y != 0:
		WalkDust()
		$AnimatedSprite2D.play("walk")
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		OneTimeWalkDust = true
		$AnimatedWalk.visible = false

func WalkDust():
	if OneTimeWalkDust:
		OneTimeWalkDust = false
		$AnimatedWalk.visible = true
		$AnimatedWalk.play("default")

func WallsToPlayer():
	position.x = clamp(position.x, 0, 800)
	position.y = clamp(position.y, 0, 570)

func _process(delta):
	if GameOverV:
		set_process(false)
	MovePlayer(delta)

func GameOver():
	GameOverV = true
	AllowHurt = false
	$AnimatedSprite2D.play("hurt")
	TimerDisapierPlayer.start()

func _on_animated_walk_animation_finished():
	$AnimatedWalk.visible = false

func _on_area_entered(area):
	if area.is_in_group("stone"):
		if !ActiveShield:
			emit_signal("StoneHitPlayer")
			AllowHurt = false
			$AnimatedSprite2D.play("hurt")
	if area.is_in_group("heart"):
		emit_signal("PickedHeart")

func _on_animated_sprite_2d_animation_finished_hurt():
	if GameOverV and AllowDeath:
		$AnimatedSprite2D.play("hurt")
	AllowHurt = true

func _on_TimerDisapierPlayer_timeout():
	AllowDeath = false
	$AnimatedSprite2D.play("death")

func ActivateShield():
	$AnimatedSprite2DShield.visible = true
	$AnimatedSprite2DShield.play("default")
	$AreaShield/CollisionShape2D2.set_deferred("disabled", false)

func DesactivateShield():
	ActiveShield = false
	$AnimatedSprite2DShield.visible = false
	$AnimatedSprite2DShield.play("default")
	$AreaShield/CollisionShape2D2.set_deferred("disabled", true)
