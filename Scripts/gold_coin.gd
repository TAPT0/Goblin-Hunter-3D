extends RigidBody3D

@export var value =10
# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name=="Player"or body.is_in_group("Player"):
		collect_coin(body)

func collect_coin(player):
	player.gold+=value
	player.update_HUD()
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
