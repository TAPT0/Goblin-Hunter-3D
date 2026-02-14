extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE



# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass


func _on_button_pressed():
	get_tree().paused=false
	get_tree().reload_current_scene()
