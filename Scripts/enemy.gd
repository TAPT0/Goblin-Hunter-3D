extends CharacterBody3D

enum States{attack,idle,chase,die}

var knockback_velocity= Vector3.ZERO
var is_dying= false

# coin scene load
var coin_scene=preload("res://Scenes/gold_coin.tscn")

var state= States.idle
var hp= 15
var speed=2
var accel= 10
var gravity= 9.8
var target= null
var damage= 10
var value= 15

# particles setup
@export var death_effect:PackedScene
@export var navAgent :NavigationAgent3D
@export var animationPlayer: AnimationPlayer

func enemy():
	pass 

@warning_ignore("unused_parameter")
func _process(delta):
	# check hp finish
	if hp <= 0 and not is_dying:
		die_sequence()

func _physics_process(delta):
	# gravity fall logic
	if not is_on_floor():
		velocity.y -= gravity
	
	if (state==States.chase or state== States.attack):
		# if player null stop
		if target == null or not is_instance_valid(target):
			state= States.idle
			target= null
			
	if state == States.idle:
		velocity= Vector3(0, velocity.y, 0)
		animationPlayer.play("Idle")
		
	elif state == States.chase:
		# face to player
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		
		navAgent.target_position = target.global_position
		
		var direction = navAgent.get_next_path_position() - global_position
		direction= direction.normalized()
		
		# move smooth
		velocity = velocity.lerp(direction*speed, accel*delta)
		animationPlayer.play("Walk")
		
	elif state == States.attack:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		
		animationPlayer.play("Punch")
		velocity = Vector3.ZERO
		
	# push back logic
	if knockback_velocity.length() > 0:
		knockback_velocity= knockback_velocity.move_toward(Vector3.ZERO, 15*delta)
		
	velocity += knockback_velocity
	move_and_slide()


func _on_chase_area_body_entered(body):
	# player enter range
	if body.has_method("player") and state != States.die:
		target= body
		state= States.chase


func _on_chase_area_body_exited(body):
	# player go away
	if body.has_method("player") and state != States.die:
		target= null
		state = States.idle


func _on_attack_area_body_entered(body):
	if body.has_method("player") and state != States.die:
		state = States.attack

func _on_attack_area_body_exited(body):
	if body.has_method("player") and state!= States.die:
		state= States.chase

func attack():
	# give damage
	if target != null:
		if target.has_method("take_damage"):
			target.take_damage(damage)

func give_loot():
	target.gold += value

func apply_knockback(force_direction:Vector3, force_strength:float):
	knockback_velocity = force_direction * force_strength

func die_sequence():
	if is_dying:
		return
		
	is_dying= true
	var player = get_tree().get_first_node_in_group("Player")
	
	# add kill count
	if player:
		if player.has_method("add_kill"):
			player.add_kill()
			
	if death_effect:
		var effect= death_effect.instantiate()
		get_parent().add_child(effect)
		effect.global_position = global_position
		
	$DeathSound.play()
	
	velocity= Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	state=States.die
	
	animationPlayer.play("Die")
	spawn_coin()
	
	# wait 1 sec delete
	await get_tree().create_timer(1.0).timeout
	
	if is_inside_tree():
		queue_free()

func spawn_coin():
	if not is_inside_tree():
		return
		
	var coin = coin_scene.instantiate()
	get_tree().current_scene.add_child(coin)
	
	coin.global_position= global_position
	coin.global_position.y+= 0.5
	
	# random throw coin
	coin.linear_velocity= Vector3(
		randf_range(-2, 2),
		5,
		randf_range(-2, 2)
	)
