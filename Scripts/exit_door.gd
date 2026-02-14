extends Area3D
@export var target_scene_path:String="res://Scenes/world.tscn"
var player_in_range=false
# Called when the node enters the scene tree for the first time.
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
		call_deferred("leave_house")
func leave_house():
	get_tree().change_scene_to_file(target_scene_path)
