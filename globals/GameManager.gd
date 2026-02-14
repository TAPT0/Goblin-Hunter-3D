extends Node

const SAVE_FILE = "user://savegame.dat" # dont change this path

# default data
var player_data={
	"hp": 50,
	"max_hp":50,
	"stamina": 100.0,
	"max_stamina":100.0,
	"gold": 0,
	"damage": 10,
	"scene_path": "res:/scenes/main.tscn",
	"position": Vector3(0,0,0),
	"rotation": 0.0,
	"inventory": [],
	"quests": {},
	"goblins_killed": 0
}

func _ready():
	add_to_group("Player")
	
	# camera setup
	$Head/FirstPerson.current=true
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
	# debug for bone error logic
	var skeleton= $character/Node/Skeleton3D
	#print("Total bones in skeleton: ", skeleton.get_bone_count())
	
	# loop all bones check
	for i in skeleton.get_bone_count():
		#print("Bone ", i, ": ", skeleton.get_bone_name(i))
		pass 
		
	await get_tree().create_timer(0.1).timeout
	load_game() # auto load start

func save_game(player):
	# check player exist
	if not player:
		return false
		
	# save stats one by one
	player_data.hp = player.hp
	player_data.max_hp= player.maxhp
	player_data.stamina = player.stamina
	player_data.max_stamina=player.max_stamina
	player_data.gold= player.gold
	player_data.damage = player.damage
	player_data.goblins_killed= player.goblins_killed
	
	player_data.position= player.global_position
	player_data.rotation= player.rotation.y
	
	player_data.scene_path = get_tree().current_scene.scene_file_path
	
	if player.has_method("get_quest_data"):
		player_data.quests= player.get_quest_data()
		
	# write to file system
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(player_data)
		file.close()
		return true
	
	return false # save fail

func load_game():
	# check if file is there
	if not FileAccess.file_exists(SAVE_FILE):
		return false
		
	var file= FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		player_data = file.get_var()
		file.close()
		return true
		
func apply_data_to_player(player):
	if not player:
		return 
		
	# give player stats back
	player.hp= player_data.hp
	player.maxhp= player_data.max_hp
	player.stamina = player_data.stamina
	player.max_stamina= player_data.max_stamina
	player.gold= player_data.gold
	player.damage = player_data.damage
	player.goblins_killed = player_data.goblins_killed
	
	# pos set
	player.global_position= player_data.position
	player.rotation.y = player_data.rotation
	
	# ui refresh
	if player.has_method("update_hud"):
		player.update_hud()

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

func delete_save():
	# delete file permant
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
