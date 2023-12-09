extends KinematicBody2D

var wheel_base
var drift_wheel_base
var steering_angle
var engine_power
var friction
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

func _ready():
	wheel_base = Global.wheel_base
	drift_wheel_base = Global.drift_wheel_base
	steering_angle = Global.steering_angle
	engine_power = Global.engine_power
	friction = Global.friction
	drift_friction = Global.drift_friction
	drag = Global.drag
	braking = Global.braking
	max_speed_reverse = Global.max_speed_reverse
	slip_speed = Global.slip_speed
	traction_fast = Global.traction_fast
	traction_slow = Global.traction_slow
	
	$DefaultCollision.disabled = true
	$MiniCarCollision.disabled = true
	$MotocycleCollision.disabled = true
	
	if Global.carNum[0] == 0 or Global.carNum[0] == 1:
		$DefaultCollision.disabled = false
	elif Global.carNum[0] == 2:
		$MiniCarCollision.disabled = false
	elif Global.carNum[0] == 3:
		$MotocycleCollision.disabled = false
	
	$Engine_SE.play()
	$Acceleration_SE.play()
	$Sprite.texture = load("res://Cars/car_{0}.png".format([Global.carNum[0]], "{_}"))

var work = true

var ms = 0
var s = 0
var m = 0

func _physics_process(delta):
	if $Camera2D/AnimationPlayer.is_playing():
		work = false
		get_input(work)
	else: work = true
	
	if work:
		ms += int(delta*100)
		if ms >= 100:
			s += int(ms/100)
			ms = ms%100
		if s >= 60:
			m += int(s/60)
			s = s%60
		$Camera2D/CanvasLayer/Time.text = "{0}:{1}:{2}".format([str(m).pad_zeros(2),
																str(s).pad_zeros(2),
																str(ms).pad_zeros(2)],
																"{_}")
	
	acceleration = Vector2.ZERO
	get_input(work)
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	
	$Acceleration_SE.pitch_scale = velocity.length() / 1200 + 0.00001
	
	if velocity.length() / 600 > 1:
		$Drift_SE.pitch_scale = 1
	elif velocity.length() / 600 < 0.4:
		$Drift_SE.pitch_scale = 0.4
	else:
		$Drift_SE.pitch_scale = velocity.length() / 600

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
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
			
		if Input.is_action_just_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")):
			$Drift_SE.play()
		elif Input.is_action_pressed("drift") and (Input.is_action_just_pressed("steer_left") or Input.is_action_just_pressed("steer_right")):
			$Drift_SE.play()
		elif Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and Input.is_action_just_pressed("accelerate"):
			$Drift_SE.play()
			
		if Input.is_action_pressed("drift") and (Input.is_action_pressed("steer_left") or Input.is_action_pressed("steer_right")) and velocity.length() > 140:
			wheel_base = drift_wheel_base
			friction = drift_friction
			
			if Global.skid:
				$Particles2D.emitting = true
				$Particles2D.process_material.angle = -(rad2deg(rotation)-90)
		else:
			wheel_base = Global.wheel_base
			friction = Global.friction
			
			$Drift_SE.stop()
			if Global.skid:
				$Particles2D.emitting = false
				
		if Input.is_action_just_pressed("Booster!!"):
			$BGM.stop()
			$BOOSTer.play()
		elif Input.is_action_just_pressed("NormalBGM"):
			$BOOSTer.stop()
			$BGM.play()
	
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

func _on_Finish_body_entered(body):
	get_tree().change_scene("res://FinishMenu.tscn")
	
	Global.ms = ms
	Global.s = s
	Global.m = m

func _on_Level_tree_entered():
	$Camera2D/AnimationPlayer.play("Timer")
	$BGM.play()

func _on_BigTruck_body_entered(body):
	get_tree().change_scene("res://GameOver.tscn")

func _on_Finish1_body_entered(body):
	Global.finished = "LevelsMenu"
	Global.levelNum = int(get_tree().current_scene.name[-1])

func _on_Finish2_body_entered(body):
	Global.finished = "Loby"
