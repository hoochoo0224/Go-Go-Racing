extends Button

func _on_Button_pressed():
	get_tree().change_scene("res://{0}.tscn".format([$Label.text], "{_}"))

func _ready():
	$Label2.text = Global.fload("res://data/time_record.dat")[int($Label.text)-1]
