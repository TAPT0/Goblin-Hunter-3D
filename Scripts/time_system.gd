extends Node

@export var sun : DirectionalLight3D
@export var env : WorldEnvironment

var time_speed = 0.1
var time_of_day = 6.0

func _process(delta):
	time_of_day += delta * time_speed
	
	if time_of_day > 24.0:
		time_of_day = 0.0
	var current_hour = int(time_of_day)
	@warning_ignore("unused_variable")
	var minutes = int((time_of_day - current_hour) * 60)
	var sun_angle = (time_of_day - 6.0) * 15.0 
	sun.rotation_degrees.x = -sun_angle
	
	var is_night = time_of_day < 6.0 or time_of_day > 18.0
	
	if is_night:
		if sun:
			sun.light_energy = move_toward(sun.light_energy, 0.0, delta * 0.2)
		if env and env.environment:
			env.environment.background_energy_multiplier = move_toward(env.environment.background_energy_multiplier, 0.0, delta * 0.2)
			env.environment.ambient_light_energy = move_toward(env.environment.ambient_light_energy, 0.0, delta * 0.2)
	else:
		if sun:
			sun.light_energy = move_toward(sun.light_energy, 1.0, delta * 0.2)
		if env and env.environment:
			env.environment.background_energy_multiplier = move_toward(env.environment.background_energy_multiplier, 1.0, delta * 0.2)
			env.environment.ambient_light_energy = move_toward(env.environment.ambient_light_energy, 1.0, delta * 0.2)
