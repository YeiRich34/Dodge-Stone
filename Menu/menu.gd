extends Control

var Background = preload("res://Menu/BackgroundMenu.png")


func _ready():
	$TextureRect.set_texture(Background)


func _on_button_start_pressed():
	get_tree().change_scene_to_file("res://Main/main.tscn")

