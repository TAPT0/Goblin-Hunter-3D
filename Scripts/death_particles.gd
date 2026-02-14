extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting=true
	await finished
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
