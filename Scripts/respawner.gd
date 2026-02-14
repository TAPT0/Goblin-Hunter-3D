extends Node3D

@export var enemy_scene: PackedScene
@export var time_system_node: Node 

@export var max_enemies: int = 5
@export var max_enemies_per_night: int = 8

var goblins_spawned_tonight = 0
var is_day_reset_done = false
var time_system = null

func _ready():
	time_system = time_system_node

@warning_ignore("unused_parameter")
func _process(delta):
	if time_system == null:
		return

	if time_system.time_of_day < 18.0 and time_system.time_of_day > 6.0:
		if not is_day_reset_done:
			goblins_spawned_tonight = 0
			is_day_reset_done = true
	
	if time_system.time_of_day > 18.0:
		is_day_reset_done = false

func _on_timer_timeout():
	if time_system == null:
		return

	if time_system.time_of_day < 18.0 and time_system.time_of_day > 6.0:
		return
		
	if goblins_spawned_tonight >= max_enemies_per_night:
		return
		
	var current_count = get_tree().get_nodes_in_group("Enemy").size()
	if current_count >= max_enemies:
		return

	spawn_enemy()
	
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	goblins_spawned_tonight += 1
