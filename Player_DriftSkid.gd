extends Particles2D

puppet var puppet_position = Vector2.ZERO setget puppet_position_set
puppet var puppet_angle = 0
puppet var puppet_emitting = false

var player_owner = 0

func _ready() -> void:
	yield(get_tree(), "idle_frame")
		
func _process(delta):
	if is_network_master():
		position = Global.player_position - Vector2(50, 0).rotated(Global.player_rotation)
		
		if Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and Global.player_velocity.length() > 140:
			if Global.skid:
				emitting = true
				process_material.angle = -(rad2deg(Global.player_rotation)-90)
		else:
			if Global.skid:
				emitting = false
				
	else:
		global_position = puppet_position
		process_material.angle = puppet_angle
		emitting = puppet_emitting

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position		

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", position)
		rset_unreliable("puppet_angle", process_material.angle)
		rset_unreliable("puppet_emitting", emitting)
