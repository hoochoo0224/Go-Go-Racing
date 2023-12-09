extends Node

var levelNum = 0

var nickname = "User123"

var ms = 0
var s = 0
var m = 0

onready var times = [
	"00:00:00", "00:00:00",
	"00:00:00", "00:00:00",
	"00:00:00", "00:00:00",
	"00:00:00", "00:00:00"
]

var ranking = []

var mode = "레벨 깨기"
var finished

var volume = [0]

var carNum = [0]

var onlineRacingFinished = false
var onlineRacingStart = false
var onlineRacingBody
var join = false
var server_close = false

var player_rotation = 0
var player_position = Vector2.ZERO
var player_velocity = Vector2.ZERO
var player_work = true

var skid = true
var max_speed
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

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

var players = []

func time_calc(argA: String, argB: String):
	var a = argA.split(":")
	var b = argB.split(":")
	if int(a[0]) == 0 and int(a[1]) == 0 and int(a[2]) == 0:
		return true
	if int(a[0]) > int(b[0]):
		return true
	elif int(b[0]) > int(a[0]):
		return false
	elif int(a[0]) == int(b[0]):
		if int(a[1]) > int(b[1]):
			return true
		elif int(b[1]) > int(a[1]):
			return false
		elif int(a[1]) == int(b[1]):
			if int(a[2]) > int(b[2]):
				return true
			elif int(b[2]) >= int(a[2]):
				return false

func fsave(fileName, content: Array):
	var file = File.new()
	file.open(fileName, file.WRITE)
	for i in range(content.size()):
		file.store_line(var2str(content[i]))
	file.close()

func fload(fileName):
	var content = []
	var file = File.new()
	file.open(fileName, file.READ)
	while !file.eof_reached():
		var line = str2var(file.get_line())
		content.append(line)
	file.close()
	return content
	
func _ready():
	#var content = times
	#fsave("res://data/time_record.dat", content)
	for i in range(times.size()):
		times[i] = fload("res://data/time_record.dat")[i]
	carNum[0] = int(fload("res://data/last_car.dat")[0])
	volume[0] = int(fload("res://data/volume.dat")[0])
	
func _process(_delta):
	times[levelNum-1] = "{0}:{1}:{2}".format([str(m).pad_zeros(2), str(s).pad_zeros(2), str(ms).pad_zeros(2)], "{_}")
	
	var content = []
	for i in times:
		if time_calc(fload("res://data/time_record.dat")[times.find(i)], i):
			content.append(i)
		else:
			content.append(fload("res://data/time_record.dat")[times.find(i)])
	fsave("res://data/time_record.dat", content)
	fsave("res://data/last_car.dat", carNum)
	fsave("res://data/volume.dat", volume)
	
	if carNum[0] == 0:
		skid = true
		max_speed = 1200
		wheel_base = 280
		drift_wheel_base = 90
		steering_angle = 20
		engine_power = 2000
		friction = -0.3
		drift_friction = -2.5
		drag = -0.001
		braking = -700
		max_speed_reverse = 900
		slip_speed = 400
		traction_fast = 0.1
		traction_slow = 1
	elif carNum[0] == 1:
		skid = true
		max_speed = 900
		wheel_base = 250
		drift_wheel_base = 150
		steering_angle = 30
		engine_power = 1400
		friction = -0.1
		drift_friction = -0.1
		drag = -0.001
		braking = -700
		max_speed_reverse = 700
		slip_speed = 450
		traction_fast = 0.07
		traction_slow = 1
	elif carNum[0] == 2:
		skid = false
		max_speed = 950
		wheel_base = 250
		drift_wheel_base = 70
		steering_angle = 35
		engine_power = 1650
		friction = -0.3
		drift_friction = -1.5
		drag = -0.001
		braking = -1200
		max_speed_reverse = 1200
		slip_speed = 400
		traction_fast = 0.1
		traction_slow = 1
	elif carNum[0] == 3:
		skid = true
		max_speed = 1300
		wheel_base = 450
		drift_wheel_base = 57
		steering_angle = 10
		engine_power = 2300
		friction = -0.15
		drift_friction = -3.2
		drag = -0.001
		braking = -700
		max_speed_reverse = 600
		slip_speed = 400
		traction_fast = 0.1
		traction_slow = 1

