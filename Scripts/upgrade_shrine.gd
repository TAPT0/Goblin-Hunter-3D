extends StaticBody3D

var player_in_range=null
var cost =50
var damage_increase=5
# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	update_label()
func update_label():
	$Label3D.text="Upgrade sword\nCost:"+str(cost)+"G"
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range=body
		$Label3D.modulate=Color.GREEN
func _on_body_exited(body):
	if body ==player_in_range:
		player_in_range=null
		$Label3D.modulate=Color.WHITE
	
@warning_ignore("unused_parameter")
func _input(event):
	# TEST 1: Direct Key Check (Bypasses Input Map)
	if Input.is_key_pressed(KEY_E):
		print("DEBUG: E Key is physically working!")
		
		# TEST 2: Check the Input Map Name
		if Input.is_action_just_pressed("interact"):
			print("DEBUG: 'interact' action is ALSO working!")
		else:
			print("DEBUG: 'interact' action is BROKEN. Check spelling!")

	# Your actual logic
	if player_in_range and Input.is_key_pressed(KEY_E):
		# We add a tiny delay or check 'just_pressed' to avoid buying 50 times in 1 second
		if Input.is_action_just_pressed("interact"): 
			buy_upgrade()
func buy_upgrade():
	if player_in_range.gold>=cost:
		player_in_range.gold-=cost
		player_in_range.damage +=damage_increase
		player_in_range.update_HUD()
		cost+=50
		update_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
