extends RigidBody2D

var max_speed = Global.max_speed
var friction_ = -Global.friction
var drift_friction = -Global.drift_friction
var engine_power = Global.engine_power
var braking = Global.braking
var drift_wheel_base = Global.drift_wheel_base
var wheel_base = Global.wheel_base
var steering_angle = Global.steering_angle
var traction_fast = Global.traction_fast
var traction_slow = Global.traction_slow
var slip_speed = Global.slip_speed
var max_speed_reverse = Global.max_speed_reverse
var drag = Global.drag

var steer_direction = deg2rad(0)
var acceleration = Vector2.ZERO

puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_rotation = 0
puppet var puppet_velocity = Vector2.ZERO

onready var tween = $Tween

onready var defaultCollision = $DefaultCollision
onready var miniCarCollision = $MiniCarCollision
onready var motocycleCollision = $MotocycleCollision

func _ready():
	defaultCollision.disabled = true
	miniCarCollision.disabled = true
	motocycleCollision.disabled = true
	
	if Global.carNum[0] == 0 or Global.carNum[0] == 1:
		defaultCollision.disabled = false
	elif Global.carNum[0] == 2:
		miniCarCollision.disabled = false
	elif Global.carNum[0] == 3:
		motocycleCollision.disabled = false
	
	$Sprite.texture = load("res://Cars/car_{0}.png".format([Global.carNum[0]], "{_}"))

	$Camera2D/CanvasLayer/Countdown.text = ""
	$Camera2D/CanvasLayer/Time.text = ""

var work = false
var canRpc = true
var anim_not_played = true

func _physics_process(delta):
	if is_network_master():
		Global.player_rotation = rotation
		Global.player_position = position
		Global.player_velocity = linear_velocity
		Global.player_work = work
		
		if Global.knockBackGameStart and anim_not_played:
			$Camera2D/AnimationPlayer.play("Timer")
			anim_not_played = false
		
		if !Global.knockBackGameStart:
			work = false
			$Camera2D.rotating = false
			$Camera2D.current = false
			$Camera2D.position = Vector2.ZERO
		elif Global.knockBackGameStart:
			work = true
			$Camera2D.rotating = true
			$Camera2D.current = true
			$Camera2D.position = Vector2(200, 0)
			$Camera2D.make_current()
		
		acceleration = Vector2.ZERO
		get_input(work)
		apply_friction()
		calculate_steering(delta)
		linear_velocity += acceleration * delta
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed
		
		
		if (Input.is_action_just_pressed("accelerate") or Input.is_action_just_pressed("back")) and canRpc:
			rpc("instance_sound_effect", get_tree().get_network_unique_id())
			rpc("instance_drift_skid", get_tree().get_network_unique_id())
			canRpc = false
		
	else:
		rotation = lerp_angle(rotation, puppet_rotation, delta*8)
		global_position = puppet_position

func apply_friction():
	if linear_velocity.length() < 5:
		linear_velocity = Vector2.ZERO
	var friction_force = linear_velocity * linear_damp
	var drag_force = linear_velocity * linear_velocity.length() * drag
	acceleration += drag_force + friction_force

func get_input(work):
	var input_vector = Vector2.ZERO
	var turn = 0
	
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
		apply_central_impulse(linear_velocity)
	if Input.is_action_pressed("back"):
		acceleration = transform.x * braking
		apply_central_impulse(linear_velocity)
	if Input.is_action_pressed("steer_left") and linear_velocity.length() > 0:
		turn -= 1
	if Input.is_action_pressed("steer_right") and linear_velocity.length() > 0:
		turn += 1
	steer_direction = turn * deg2rad(steering_angle)
	
	if Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and linear_velocity.length() > 140:
		wheel_base = drift_wheel_base
		linear_damp = drift_friction
	else:
		wheel_base = Global.wheel_base
		linear_damp = friction_

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2
	var front_wheel = position + transform.x * wheel_base/2
	rear_wheel += linear_velocity * delta
	front_wheel += linear_velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if linear_velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(linear_velocity.normalized())
	if d > 0:
		linear_velocity = linear_velocity.linear_interpolate(new_heading * linear_velocity.length(), traction)
	if d < 0:
		linear_velocity = -new_heading * min(linear_velocity.length(), max_speed_reverse)
	rotation = (new_heading.angle())

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight
	
func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
	
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation)
		rset_unreliable("puppet_velocity", linear_velocity)

sync func instance_sound_effect(id):
	var player_sound_effect_instance = Global.instance_node(load("res://Player_SoundEffects.tscn"), Players)
	player_sound_effect_instance.name = "SoundEffect" + name #+ str(Network.networked_object_name_index)
	player_sound_effect_instance.set_network_master(id)
	player_sound_effect_instance.player_owner = id
	Network.networked_object_name_index += 1
	
sync func instance_drift_skid(id):
	var player_drift_skid_instance = Global.instance_node(load("res://Player_DriftSkid.tscn"), Players)
	player_drift_skid_instance.name = "DriftSkid" + name# + str(Network.networked_object_name_index)
	player_drift_skid_instance.set_network_master(id)
	player_drift_skid_instance.player_owner = id
	Network.networked_object_name_index += 1
