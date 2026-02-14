extends GPUParticles3D
func ready():
	one_shot=true
	emitting=true
	restart()
	await get_tree().create_timer(2.0).timeout
	queue_free()
