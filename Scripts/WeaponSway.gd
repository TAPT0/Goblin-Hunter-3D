extends Node3D
#setting that can be changed in the inspec.
@export var sway_amount:float=0.5
@export var sway_smoothness:float=10.0

var mouse_input:Vector2=Vector2.ZERO
var initial_rotation:Vector3 #varaible to store the starting rotation

func _ready():
	initial_rotation=rotation
#mouse movement
func _input(event):
	if event is InputEventMouseMotion:
		mouse_input=event.relative
		
func _process(delta):
	#target rotation exactly like mouse rotation
	var target_rot_x=clamp(mouse_input.y*sway_amount,-0.1,0.1)
	var target_rot_y=clamp(mouse_input.x*sway_amount,-0.1,0.1)
	var target_rotation=initial_rotation+Vector3(target_rot_x,target_rot_y,0.0)
	
	#move from cureent to target location smoothly
	rotation=rotation.lerp(target_rotation,sway_smoothness*delta)
	#reset mouse inout
	mouse_input=Vector2.ZERO
