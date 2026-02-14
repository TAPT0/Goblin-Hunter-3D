extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
	
func _on_quit_pressed():
	get_tree().quit()
