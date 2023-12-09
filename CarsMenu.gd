extends Node2D

var car

func _ready():
	$ColorRect/Cars.rect_position.y = -73
	$ColorRect/Cars.rect_position.x = Global.carNum[0] * -288
	$BGM.play()

func _process(delta):
	if Input.is_action_pressed("turn"):
		car.rotation_degrees += 2

func _physics_process(delta):
	if $ColorRect/AnimationPlayer.is_playing():
		pass
	else:
		get_input()

func get_input():
	if Input.is_action_just_pressed("next_car"):
		Global.carNum[0] += 1
		if Global.carNum[0] > 3:
			Global.carNum[0] = 3
		else: $ColorRect/AnimationPlayer.play("next_{0}".format([Global.carNum[0]], "{_}"))
	elif Input.is_action_just_pressed("previous_car"):
		Global.carNum[0] -= 1
		if Global.carNum[0] < 0:
			Global.carNum[0] = 0
		else: $ColorRect/AnimationPlayer.play("previous_{0}".format([Global.carNum[0]], "{_}"))

func _on_Floor_body_entered(body):
	pass

func _on_Floor_body_exited(body):
	body.rotation_degrees = 0

func _on_Floor_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	car = body

func _on_Button_pressed():
	get_tree().change_scene("res://Loby.tscn")


func _on_LeftButton_pressed():
	if not $ColorRect/AnimationPlayer.is_playing():
		Global.carNum[0] -= 1
		if Global.carNum[0] < 0:
			Global.carNum[0] = 0
		else: $ColorRect/AnimationPlayer.play("previous_{0}".format([Global.carNum[0]], "{_}"))

func _on_RightButton_pressed():
	if not $ColorRect/AnimationPlayer.is_playing():
		Global.carNum[0] += 1
		if Global.carNum[0] > 3:
			Global.carNum[0] = 3
		else: $ColorRect/AnimationPlayer.play("next_{0}".format([Global.carNum[0]], "{_}"))

