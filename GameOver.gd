extends Node2D



func _on_RetryButton_pressed():
	get_tree().change_scene("res://RunAway.tscn")


func _on_ExitButton_pressed():
	get_tree().change_scene("res://Loby.tscn")
