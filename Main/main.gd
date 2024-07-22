extends Node2D

const CHANGE_LEVEL = 10 #Change level every 10 seconds
const INCREMENT_VELOCITY_OF_STONES = 10
const VELOCITY_OF_SPAWN_STONE_EVERY_LEVEL = 0.1
const STOP_INTERVAL_OF_STOP_VREATE_STONES = 12 #At level 12 the velocity of spawn stone will be stopped
const SECONDS_WITH_SHIELD = 6
const EVERY_LEVEL_TO_UPGRADE_SHIELD = 2
const UPGRADE_SHIELD_TIME = 0.2
const EVERY_LEVEL_FOR_A_HEART = 3

var ImageG = preload("res://Main/SpaceBackgroundG.png")
var Stones = preload("res://FireBall/fire_ball.tscn").instantiate()
var Heart = preload("res://Heart/heart.tscn").instantiate()
var TimerGneratorStone = Timer.new()
var TimerTimeGame = Timer.new()
var TimerShield = Timer.new()
var GameOver = false
var ActiveShield = false
var UpdatingShield = true
var ShieldTimeOut = 0
var Level = 0
var LevelUpgradeShield = 0
var AllowLandShield = 0
var LevelLabel = 0
var ContHeart = 0
var VelocityForChargeShield = 1 # 1.2
var VelocityOfStones = 200
var LivesPlayer = 3
var TimeOfGame = 0
var IntervalOfCreateStones = 1.5

func _ready():
	$TextureRect.set_texture(ImageG)
	TimerGeneratorSettings()
	TimerTimeGameSettings()
	UpdateLives(LivesPlayer)
	TimerShieldSettings()

func UpdateLives(Lives):
	$HUD/MarginContainer/LabelLives.text = "LIVES: " + str(Lives)

func UpdateTime(TimeG):
	$HUD/MarginContainer/LabelTime.text = "TIME: " + str(TimeG)

func UpdateLevel(Lvl):
	$HUD/MarginContainer/LabelLevel.text = " LEVEL: " + str(Lvl)

func TimerGeneratorSettings():
	TimerGneratorStone.wait_time = IntervalOfCreateStones
	TimerGneratorStone.autostart = true
	TimerGneratorStone.connect("timeout", self._on_TimerGenerator_timeout)
	add_child(TimerGneratorStone)

func LevelGetHard():
	if Level >= CHANGE_LEVEL:
		VelocityOfStones += INCREMENT_VELOCITY_OF_STONES
		Level = 0
		LevelLabel += 1
		UpgradeShield()
		CreateHeart()
		if LevelLabel <= STOP_INTERVAL_OF_STOP_VREATE_STONES:
			IntervalOfCreateStones -= VELOCITY_OF_SPAWN_STONE_EVERY_LEVEL
			TimerGneratorStone.wait_time = IntervalOfCreateStones
		UpdateLevel(LevelLabel)

func TimerTimeGameSettings():
	TimerTimeGame.wait_time = 1
	TimerTimeGame.autostart = true
	TimerTimeGame.connect("timeout", self._on_TimerTimeGame_timeout)
	add_child(TimerTimeGame)

func TimerShieldSettings():
	TimerShield.wait_time = VelocityForChargeShield
	TimerShield.autostart = true
	TimerShield.connect("timeout", self._on_TimerShield_timeout)
	add_child(TimerShield)

func TimerTimeGameSettingsGameOver():
	GameOver = true
	TimerTimeGame.wait_time = 6
	TimerTimeGame.start()

func GenerateStones():
	randomize()
	var PosR = int(randf_range(1, 5))
	Stones.VelocityPerPixel = VelocityOfStones
	Stones.SetPosRamdon(PosR)
	$StoneContainer.add_child(Stones)
	Stones = preload("res://FireBall/fire_ball.tscn").instantiate()

func _on_TimerGenerator_timeout():
	GenerateStones()

@warning_ignore("unused_parameter")
func _process(delta):
	pass

func GameOverG():
	if LivesPlayer <= 0:
		TimerGneratorStone.stop()
		TimerTimeGame.stop()
		TimerShield.stop()
		$LabelGameOver.visible = true
		$StoneContainer.call_deferred("queue_free")
		$Player.GameOver()
		TimerTimeGameSettingsGameOver()

func _on_player_stone_hit_player():
	LivesPlayer += -1
	UpdateLives(LivesPlayer)
	GameOverG()

func _on_TimerTimeGame_timeout():
	if GameOver:
		get_tree().change_scene_to_file("res://Menu/menu.tscn")
	TimeOfGame += 1
	Level += 1
	LevelGetHard()
	UpdateTime(TimeOfGame)
	TimeOutForDisableShield()

func _on_TimerShield_timeout():
	if !ActiveShield:
		AllowLandShield += 1
		$HUD/ProgressBar.value += 1
		if AllowLandShield >= 100:
			$Player.LandSpeelShield = true

func TimeOutForDisableShield():
	if ActiveShield:
		ShieldTimeOut += 1
		if ShieldTimeOut >= SECONDS_WITH_SHIELD:
			ShieldTimeOut = 0
			ActiveShield = false
			$Player.DesactivateShield()

func _on_player_shield_activated():
	ActiveShield = true
	$HUD/ProgressBar.value = 0
	AllowLandShield = 0
	$Player.LandSpeelShield = false

func UpgradeShield():
	if UpdatingShield:
		LevelUpgradeShield += 1
		if LevelUpgradeShield >= EVERY_LEVEL_TO_UPGRADE_SHIELD:
			VelocityForChargeShield -= UPGRADE_SHIELD_TIME
			if !VelocityForChargeShield <= 0:
				if VelocityForChargeShield >= 0.4:
					TimerShield.wait_time = VelocityForChargeShield
			else:
				UpdatingShield = false
			LevelUpgradeShield = 0

func CreateHeart():
	ContHeart += 1
	if ContHeart >= EVERY_LEVEL_FOR_A_HEART:
		ContHeart = 0
		add_child(Heart)
		Heart = preload("res://Heart/heart.tscn").instantiate()

func _on_player_picked_heart():
	LivesPlayer += 1
	UpdateLives(LivesPlayer)
