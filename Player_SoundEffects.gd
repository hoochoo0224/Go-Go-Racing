extends Node

var position = Vector2.ZERO

puppet var puppet_position = Vector2.ZERO
puppet var puppet_drift_pitch = 1
puppet var puppet_accel_pitch = 1
puppet var puppet_accel_volume_db = 0

var player_owner = 0

func _ready() -> void:
	$Acceleration_SE.play()
	yield(get_tree(), "idle_frame")
	
	if is_network_master():
		rset("puppet_position", position)
		rset("puppet_drift_pitch", $Drift_SE.pitch_scale)
		rset("puppet_accel_pitch", $Acceleration_SE.pitch_scale)
		rset("puppet_accel_volume_db", $Acceleration_SE.volume_db)
		
func _process(_delta):
	if is_network_master():
		if Global.player_work:
			if Input.is_action_just_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")):
				$Drift_SE.play()
			elif Input.is_action_pressed("drift") and (Input.is_action_just_pressed("steer_left") or Input.is_action_just_pressed("steer_right")):
				$Drift_SE.play()
			elif Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and Input.is_action_just_pressed("accelerate"):
				$Drift_SE.play()
			if !(Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and Global.player_velocity.length() > 140):
				$Drift_SE.stop()
				
		$Acceleration_SE.position = position
		$Drift_SE.position = position
		
		position = Global.player_position
		
		$Acceleration_SE.pitch_scale = Global.player_velocity.length() / 1200 + 0.00001
		$Acceleration_SE.volume_db = 2
		
		if Global.player_velocity.length() / 600 > 1:
			$Drift_SE.pitch_scale = 1
		elif Global.player_velocity.length() / 600 < 0.4:
			$Drift_SE.pitch_scale = 0.4
		else:
			$Drift_SE.pitch_scale = Global.player_velocity.length() / 600
		
	else:
		position = puppet_position
		$Drift_SE.pitch_scale = puppet_drift_pitch
		$Acceleration_SE.pitch_scale = puppet_accel_pitch
		$Acceleration_SE.volume_db = puppet_accel_volume_db

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset("puppet_position", position)
		rset("puppet_drift_pitch", $Drift_SE.pitch_scale)
		rset("puppet_accel_pitch", $Acceleration_SE.pitch_scale)
		rset("puppet_accel_volume_db", $Acceleration_SE.volume_db)
