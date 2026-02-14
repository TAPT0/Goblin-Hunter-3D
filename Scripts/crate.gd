extends StaticBody3D

@export var debris_scene:PackedScene
@export var loot_scene: PackedScene 
@export var max_health = 150

var current_health=0

func _ready():
	# start hp set
	current_health = max_health

@warning_ignore("unused_parameter")
func take_damage(amount):
	current_health -= amount 
	
	# check dead or alive
	if current_health <= 0:
		die()
	else:
		shake_box()

func shake_box():
	var tween= create_tween()
	var original_pos = position
	
	# move shake effect little bit
	tween.tween_property(self,"position", original_pos+Vector3(0.1,0,0), 0.05)
	tween.tween_property(self,"position", original_pos-Vector3(0.1,0,0), 0.05)
	tween.tween_property(self,"position", original_pos, 0.05)

func die():
	if debris_scene:
		# loop for 4 parts debris
		for i in range(4):
			spawn_debris()
			
	# spawn item if exist
	if loot_scene:
		spawn_loot()
		
	queue_free() # delete box now

func spawn_debris():
	var debris= debris_scene.instantiate()
	get_parent().add_child(debris)
	
	debris.global_position = global_position
	
	# up position
	debris.global_position.y += 0.5
	
	# random pos x and z
	debris.global_position.x+=randf_range(-0.5, 0.5)
	debris.global_position.z+= randf_range(-0.5, 0.5)
	
	# physics force apply
	debris.apply_impulse(Vector3(randf_range(-5, 5), 5, randf_range(-5, 5)))

func spawn_loot():
	var loot = loot_scene.instantiate()
	get_parent().add_child(loot)
	
	loot.global_position=global_position
	loot.global_position.y+=0.5
