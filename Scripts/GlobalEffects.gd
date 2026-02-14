extends Node

#this function freezes time for a tiny sec.
func hit_stop(duration:float =0.05):
	Engine.time_scale=0.05
	await get_tree().create_timer(duration*0.05,true,false,true).timeout
	Engine.time_scale=1.0
