extends KinematicBody2D

var wheel_base
var drift_wheel_base
var steering_angle
var engine_power
var friction_
var drift_friction
var drag
var braking
var max_speed_reverse
var slip_speed
var traction_fast
var traction_slow

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction = deg2rad(0)

var username_text = load("res://Username_text.tscn")

var username setget username_set
var username_text_instance = null

puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_rotation = 0
puppet var puppet_velocity = Vector2()
puppet var puppet_username = "" setget puppet_username_set

onready var tween = $Tween

onready var defaultCollision = $DefaultCollision
onready var miniCarCollision = $MiniCarCollision
onready var motocycleCollision = $MotocycleCollision

func _ready():
	wheel_base = Global.wheel_base
	drift_wheel_base = Global.drift_wheel_base
	steering_angle = Global.steering_angle
	engine_power = Global.engine_power
	friction_ = Global.friction
	drift_friction = Global.drift_friction
	drag = Global.drag
	braking = Global.braking
	max_speed_reverse = Global.max_speed_reverse
	slip_speed = Global.slip_speed
	traction_fast = Global.traction_fast
	traction_slow = Global.traction_slow
	
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
	
	username_text_instance = Global.instance_node_at_location(username_text, Players, global_position)
	username_text_instance.player_following = self

var work = false
var canRpc = true
var anim_not_played = true

sync func random_spawn(r1, r2):
	$Camera2D.position = Vector2(0, RandomNumberGenerator.new().randi_range(r1, r2)*45)
	

func _physics_process(delta: float):	
	if is_network_master():
		Global.player_rotation = rotation
		Global.player_position = position
		Global.player_velocity = velocity
		Global.player_work = work
		
		if !Global.onlineRacingStart:
			work = false
			$Camera2D.rotating = false
			$Camera2D.current = false
			$Camera2D.position = Vector2.ZERO
		elif Global.onlineRacingStart:
			#work = true
			$Camera2D.rotating = true
			$Camera2D.current = true
			rpc("random_spawn", -3, 3)
			$Camera2D.make_current()
		
		if $Camera2D/AnimationPlayer.is_playing():
			work = false
			get_input(work)
		elif !$Camera2D/AnimationPlayer.is_playing():
			work = true
			$Camera2D/CanvasLayer/Countdown.text = ""
			
		if Global.onlineRacingStart and anim_not_played:
			$Camera2D/AnimationPlayer.play("Timer")
			position.y = 0
			position.x = 0
			anim_not_played = false
		
		acceleration = Vector2.ZERO
		get_input(work)
		apply_friction()
		calculate_steering(delta)
		velocity += acceleration * delta
		velocity = move_and_slide(velocity)
		
		if (Input.is_action_just_pressed("accelerate") or Input.is_action_just_pressed("back")) and canRpc:
			rpc("instance_sound_effect", get_tree().get_network_unique_id())
			rpc("instance_drift_skid", get_tree().get_network_unique_id())
			canRpc = false
		
		if Global.onlineRacingFinished:
			rpc("finished_the_online_racing", Global.onlineRacingBody)
		
	else:
		$Camera2D/CanvasLayer/Countdown.text = ""
		rotation = lerp_angle(rotation, puppet_rotation, delta*8)
		
		if not tween.is_active():
			move_and_slide(puppet_velocity)
		
		if Global.server_close:
			get_tree().quit()
			
func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction_
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

func get_input(work):
	if work:
		var turn = 0
		
		if Input.is_action_pressed("steer_right"):
			turn += 1
		if Input.is_action_pressed("steer_left"):
			turn -= 1
			
		steer_direction = turn * deg2rad(steering_angle)
		
		if Input.is_action_pressed("accelerate"):
			acceleration = transform.x * engine_power
			print(transform.x)
		if Input.is_action_pressed("back"):
			acceleration = transform.x * braking
			
		if Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and velocity.length() > 140:
			wheel_base = drift_wheel_base
			friction_ = drift_friction
		else:
			wheel_base = Global.wheel_base
			friction_ = Global.friction

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2
	var front_wheel = position + transform.x * wheel_base/2
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


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

func username_set(new_value):
	username = new_value
	
	if is_network_master() and username_text_instance != null:
		username_text_instance.text = username
		rset("puppet_username", username)
		
func puppet_username_set(new_value):
	puppet_username = new_value
	
	if not is_network_master() and username_text_instance != null:
		username_text_instance.text = puppet_username

func _network_peer_connected(id):
	rset_id(id, "puppet_username", username)

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation)
		rset_unreliable("puppet_velocity", velocity)

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

var rank = 1

sync func finished_the_online_racing(body):
	get_tree().reload_current_scene()
	#if Global.ranking.empty():
	#	Global.ranking.pop_front()
	#	Global.ranking.append(body)
	#	rank += 1
	#elif body != Global.ranking[rank-2]:
	#	Global.ranking.append(body)
	#	rank += 1
	#print(Global.ranking)
