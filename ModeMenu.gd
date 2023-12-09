extends Node2D

func _ready():
	$BGM.play()

func _on_Button_pressed():
	get_tree().change_scene("res://Loby.tscn")

func _on_Button1_pressed():
	Global.mode = $ColorRect/Button1.text

func _on_Button2_pressed():
	Global.mode = $ColorRect/Button2.text

func _on_Button3_pressed():
	Global.mode = $ColorRect/Button3.text



func _on_BackButton_pressed():
	get_tree().change_scene("res://Loby.tscn")
