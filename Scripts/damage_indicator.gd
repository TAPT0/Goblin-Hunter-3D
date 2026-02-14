extends Label3D

func set_damage(amount:int):
	text=str(amount)
	
	var random_x=randf_range(-0.5,0.5)
	position+=Vector3(random_x,0,0)
	
	var tween = create_tween()
	tween.set_parellel(true)
	tween.tween_property(self,"position",position+Vector3(0,1.2,0),0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate:a",0.0,0.7).set_ease(Tween.EASE_IN)
	scale=Vector3(1.5,1.5,1.5)
	tween.tween_property(self,"scale",Vector3(1.0,1.0,1.0),0.3)
	tween.chain().tween_callback(queue_free)


func _on_timer_timeout():
	queue_free()
