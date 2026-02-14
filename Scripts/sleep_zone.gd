extends Area3D

var player_in_range=false
var player_ref=null

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Label3D.visible=false
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range=true
		player_ref=body
		$Label3D.visible=true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range=false
		player_ref=null
		$Label3D.visible=false
		
@warning_ignore("unused_parameter")
func _input(event):
	if player_in_range and Input.is_action_just_pressed("interact"):
		sleep_and_save()
	
func sleep_and_save():
	if not player_ref:
		return
		
	player_ref.hp=player_ref.maxhp
	player_ref.stamina=player_ref.max_stamina
	player_ref.update_HUD()
	save_game()
	$Label3D.text="Game Saved!"
	$Label3D.modulate=Color.GREEN
	await get_tree().create_timer(2.0).timeout
	$Label3D.text="Sleep (Press E)"
	$Label3D.modulate=Color.WHITE
func save_game():
	if not player_ref:
		return
	var save_data={
		"hp": player_ref.hp,
		"maxhp": player_ref.maxhp,
		"stamina": player_ref.stamina,
		"gold": player_ref.gold,
		"damage": player_ref.damage,

		"goblins_killed": player_ref.goblins_killed,
		"quest_status": player_ref.quest_status,
		"quest_active": player_ref.quest_active,
		
		"position_x": player_ref.global_position.x,
		"position_y": player_ref.global_position.y,
		"position_z": player_ref.global_position.z,
		"rotation_y": player_ref.rotation.y,

		"scene_path": get_tree().current_scene.scene_file_path
	}
		
	var file=FileAccess.open("user://savegame.save",FileAccess.WRITE)
	if file:
		var json_string=JSON.stringify(save_data)
		file.store_line(json_string)
		file.close()
	
