extends Area3D

var player_in_range=false
@export var target_scene_path:String="res://Scenes/house_interior.tscn"
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range=true
		if has_node("Label3D"):
			$Label3D.visible=true
		
func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range=false
		if has_node("Label3D"):
			$Label3D.visible=false

@warning_ignore("unused_parameter")
func _input(event):
	if player_in_range and Input.is_action_just_pressed("interact"):
		call_deferred("enter_house")

	
func enter_house():
	get_tree().change_scene_to_file(target_scene_path)
