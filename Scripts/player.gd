extends CharacterBody3D

var quest_status = "none"
var quest_active = false
var goblins_killed = 0
var quest_goal = 5
#speed/jump
var SPEED = 5.0
const JUMP_VELOCITY = 4.5
var is_ground_slamming = false

var is_blocking = false
var last_block_time = 0.0

var is_attacking = false
@onready var anim_playback = $MainAnimator

@export var shockwave_scene: PackedScene

@export var slam_damage = 50
@export var slam_speed = 25.0
#dash
@export var dash_speed: float = 20.0
@export var damage_indicator_scene: PackedScene
var is_dashing: bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var sensivity = 0.003


var onCooldown = false

#gold,hp,damage and stamina 
var stamina = 100.0
var max_stamina = 100.0
var stamina_regen_rate = 20.0
var dash_cost = 30.0
var gold = 0
var hp = 50
var maxhp = 50
var damage = 10
var target = []


@onready var quest_label = $HUD/QuestLabel
@onready var game_over_screen = $HUD/GameOverScreen
#stamina bar /hp bar and stuff
@onready var staminabar = $HUD/StaminaBar
@onready var hpbar = $HUD/HpBar
@onready var goldlabel = $HUD/GoldLabel
@onready var camera = $Head/FirstPerson
@onready var animationplayer = $MainAnimator
@onready var cooldown = $AttackCooldown
@onready var anim_movement = $character/AnimationPlayer
@onready var anim_combat = $MainAnimator

func player():
	pass

func _ready():
	is_blocking = false
	$MainAnimator.stop()
	if has_node("character/AnimationPlayer"):
		$character/AnimationPlayer.play("mixamo_com")
	anim_movement.play("mixamo_com") 
	anim_combat.stop()
	add_to_group("Player")
	$Head/FirstPerson.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.1).timeout
	load_game()
	update_HUD()

func attack():
	hpbar.max_value = 50
	if Input.is_action_just_pressed("attack") and not onCooldown and not is_blocking:
		is_attacking = true
		onCooldown = true
		$AttackCooldown.start()
		anim_movement.stop()      
		anim_combat.play("SwordSlash")  
		if has_node("SwordSound"): $SwordSound.play()
		deal_damage()
		await get_tree().create_timer(0.8).timeout
		is_attacking = false

func deal_damage():
	if target.size() > 0:
		GlobalEffects.hit_stop()
		#$Head/FirstPerson.apply_shake(0.01)
		for enemies in target:
			enemies.hp -= damage
			
			if enemies.has_method("apply_knockback"):
				var push_direction = (enemies.global_position - global_position).normalized()
				push_direction.y = 0
				enemies.apply_knockback(push_direction, 4.0)
#func _switch_view():
	#if Input.is_action_just_pressed("switch"):
	#
		#if $Head/FirstPerson.current:
			#$Head/FirstPerson.current=false
			##$Head/ThirdPerson.current = true
			#camera = $Head
		#else:
			#$Head/FirstPerson.current = true
			##$Head/ThirdPerson.current=true
			#
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensivity)
		$Head.rotate_x(-event.relative.y * sensivity)
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-60), deg_to_rad(70))

@warning_ignore("unused_parameter")
func _process(delta):
	update_HUD()
	attack()
	#_switch_view()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		var all_nodes = find_children("*", "Node3D", false)
		for node in all_nodes:
			if node.name == "character" or node.name == "Visuals" or node.name == "Node":
				node.position = Vector3(0, 0, 0)
				
				if node.has_node("Node"):
					node.get_node("Node").position = Vector3(0, 0, 0)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("dash") and not is_dashing and stamina >= dash_cost:
		start_dash()
		stamina -= dash_cost
		staminabar.value = stamina
	var current_speed = SPEED
	if is_dashing:
		current_speed = dash_speed
		
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_pressed("block"):
		is_blocking = true
		velocity.x = 0
		velocity.z = 0
	else:
		is_blocking = false
	if not is_blocking:
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
	if is_blocking:
		anim_combat.play("BlockIdle")
		if has_node("character/AnimationPlayer"): $character/AnimationPlayer.stop()
	elif is_attacking:
		pass
	else:
		if anim_combat.has_animation("RESET"):
			anim_combat.play("RESET")
		else:
			anim_combat.stop()
		if velocity.length() > 0:
			if has_node("character/AnimationPlayer"): $character/AnimationPlayer.play("RunForward")
		else:
			if has_node("character/AnimationPlayer"): $character/AnimationPlayer.play("mixamo_com")
	if not is_on_floor() and Input.is_action_just_pressed("attack") and not is_ground_slamming:
		start_ground_slam()
		
	if is_ground_slamming:
		velocity.x = 0
		velocity.z = 0
		velocity.y = -slam_speed
		
		if is_on_floor():    
			finish_ground_slam()
			
	move_and_slide()
	
	if anim_combat.is_playing() and anim_combat.current_animation == "SwordSlash":
		pass
	else:
		if velocity.length() > 0.5 and is_on_floor():
			if anim_movement.current_animation != "RunForward":
				anim_movement.play("RunForward") 
		else:
			if anim_movement.current_animation != "mixamo_com": 
				anim_movement.play("mixamo_com")
	#regenerate stamina
	if not is_dashing and stamina < max_stamina:
		stamina += stamina_regen_rate * delta
		if stamina > max_stamina:
			stamina = max_stamina
			staminabar.value = stamina

func _on_attack_cooldown_timeout():
	onCooldown = false

func update_HUD():
	hpbar.value = hp
	goldlabel.text = "Gold:" + str(gold)


func _on_attack_zone_body_entered(body):
	if body.has_method("enemy"):
		target.append(body)


func _on_attack_zone_body_exited(body):
	if body.has_method("enemy"):
		target.erase(body)

func start_dash():
	is_dashing = true
	$DashTimer.start()

func _on_dash_timer_timeout():
	is_dashing = false

func take_damage(amount):
	if is_blocking:
		var time_since_block = Time.get_ticks_msec() - last_block_time
		if time_since_block < 250:
			return
		else:
			amount = amount / 2
	hp -= amount
	update_HUD()
	if hp <= 0:
		die()
		
func die():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_screen.visible = true
	
func add_kill():
	if quest_active:
		goblins_killed += 1
		quest_label.text = "Mission:Kill Goblins(" + str(goblins_killed) + "/" + str(quest_goal) + ")"
		if goblins_killed >= quest_goal:
			quest_label.text = "Mission Complete! Return to Mage."
			quest_label.modulate = Color.GREEN

func save_game():
	var save_data = {
		"hp": hp,
		"max_hp": maxhp,
		"stamina": stamina,
		"max_stamina": max_stamina,
		"gold": gold,
		"damage": damage,
		"goblins_killed": goblins_killed,
		"quest_status": quest_status,
		"quest_active": quest_active,
		"position_x": global_position.x,
		"position_y": global_position.y,
		"position_z": global_position.z,
		"rotation_Y": rotation.y,
		"scene_path": get_tree().current_scene.scene_file_path
	}
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		file.close()
		show_save_notification()
		return true

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
		
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if not file:
		return false
	var json_string = file.get_line()
	file.close()
	
	var data = JSON.parse_string(json_string)
	
	if data:
		hp = data.get("hp", 50)
		maxhp = data.get("maxhp", 50)
		stamina = data.get("stamina", 100.0)
		gold = data.get("gold", 0)
		damage = data.get("damage", 10)
		goblins_killed = data.get("goblins_killed", 0)
		quest_status = data.get("quest_status", "none")
		quest_active = data.get("quest_active", false)
		
		if data.has("position_x"):
			global_position = Vector3(
				data["position_x"],
				data["position_y"],
				data["position_z"]
			)
			if data.has("rotation_y"):
				rotation.y = data["rotation_y"]
				
				update_HUD()
				return true

func show_save_notification():
	var label = Label.new()
	label.text = "Game Saved!"
	label.add_theme_font_size_override("font_size", 32)
	label.modulate = Color.GREEN
	label.position = Vector2(get_viewport().size.x / 2 - 100, 100)
	
	$HUD.add_child(label)
	
	await get_tree().create_timer(2.0).timeout
	if label:
		label.queue_free()
		
func get_quest_data():
	return {
		"quest_active": quest_active,
		"goblins_killed": goblins_killed,
		"quest_status": quest_status
	}

@warning_ignore("unused_parameter")
func _input(event):
	if Input.is_action_just_pressed("torch"):
		$character/Node/Skeleton3D/LeftHandAttachment/Torch.visible = not $character/Node/Skeleton3D/LeftHandAttachment/Torch.visible

func start_ground_slam():
	is_ground_slamming = true
	velocity.y = 0
	await get_tree().create_timer(0.2).timeout
	
func finish_ground_slam():
	is_ground_slamming = false
	
	if shockwave_scene:
		var effect = shockwave_scene.instantiate()
		get_parent().add_child(effect)
		effect.global_position = global_position
	
	var impact_area = Area3D.new()
	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 3.0
	
	add_child(impact_area)
	impact_area.add_child(collision)
	collision.shape = sphere
	
	await get_tree().process_frame
	
	var bodies = impact_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(slam_damage)
	impact_area.queue_free()


func _on_sword_hitbox_body_entered(body):
	if body == self:
		return
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			if body.has_method("take_damage"):
				body.take_damage(50)
				
				if damage_indicator_scene:
					var indicator = damage_indicator_scene.instantiate()
					get_tree().current_scene.add_child(indicator)
					
					indicator.global_position = body.global_position + Vector3(0, 1.5, 0)
					
					if indicator.has_method("set-damage"):
						indicator.set_damage(50)
