extends Node2D

var random = RandomNumberGenerator.new()

func _ready():
	$BigTruck/TruckAccelerating.play()
	$AnimationPlayer.play("BigTruck")
	
	var block1_clone1 = []
	var block1_clone2 = []
	var block2_clone1 = []
	var block2_clone2 = []
	
	var ranBool = random.randi_range(0, 1)
	var ranN1
	var ranN2
	if !ranBool:
		ranN1 = 0
		ranN2 = 300
	else:
		ranN1 = 300
		ranN2 = 0
	
	for i in range(1, 34):
		block1_clone1.append($Block1.duplicate())
		block1_clone1[i-1].position.x = 600*i - ranN1
		block1_clone1[i-1].position.y = -170*random.randi_range(-1, 1)
		add_child(block1_clone1[i-1])
	for i in range(1, 34-17):
		block1_clone2.append($Block1.duplicate())
		block1_clone2[i-1].position.x = 600*i - ranN1-150 + 600*17
		block1_clone2[i-1].position.y = -170*random.randi_range(-1, 1)
		add_child(block1_clone2[i-1])
	
	for i in range(1, 34):
		block2_clone1.append($Block2.duplicate())
		block2_clone1[i-1].position.x = 600*i - ranN2
		block2_clone1[i-1].position.y = -256*random.randi_range(-1, 1)
		add_child(block2_clone1[i-1])
	for i in range(1, 34-7):
		block2_clone2.append($Block2.duplicate())
		block2_clone2[i-1].position.x = 600*i - ranN2 + 600*7
		block2_clone2[i-1].position.y = -256*random.randi_range(-1, 1)
		add_child(block2_clone2[i-1])

func _process(delta):
	pass


func _on_Finish2_body_entered(body):
	Global.finished = "Loby"
