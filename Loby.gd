extends Node2D

func _ready():
	$ColorRect/Car.texture = load("res://Cars/car_{0}.png".format([Global.carNum[0]], "{_}"))
	$ColorRect/ModeButton.text = Global.mode
	$ColorRect/WindowDialog/HSlider.value = Global.volume[0]
	$BGM.play()

func _process(_delta):
	if Input.is_action_pressed("turn"):
		$ColorRect/Car.rotation_degrees += 2
		
	if Input.is_action_just_pressed("Booster!!"):
		$BGM.stop()
		$BOOSTer.play()
	elif Input.is_action_just_pressed("NormalBGM"):
		$BOOSTer.stop()
		$BGM.play()


func _on_CarsButton_pressed():
	get_tree().change_scene("res://CarsMenu.tscn")

func _on_StartButton_pressed():
	if Global.mode == "레벨 깨기":
		get_tree().change_scene("res://LevelsMenu.tscn")
	elif Global.mode == "도망쳐! 모드":
		get_tree().change_scene("res://RunAway.tscn")
	elif Global.mode == "온라인 경주":
		get_tree().change_scene("res://Network_setup.tscn")

func _on_ModeButton_pressed():
	get_tree().change_scene("res://ModeMenu.tscn")

func _on_SettingButton_pressed():
	$ColorRect/WindowDialog.show()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_HSlider_value_changed(value):
	Global.volume[0] = value
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.volume[0])
	
	if $ColorRect/WindowDialog/HSlider.value == -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		
func _on_LineEdit_text_changed(new_text):
	if new_text == "" or new_text == " ":
		Global.nickname = "User123"
	else:
		Global.nickname = new_text
