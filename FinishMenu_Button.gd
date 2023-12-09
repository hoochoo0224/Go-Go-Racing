extends Button

func _ready():
	if Global.finished == "LevelsMenu":
		self.text = "Menu"
	else:
		self.text = Global.finished

func _on_Button_pressed():
	get_tree().change_scene("res://{0}.tscn".format([Global.finished], "{_}"))
