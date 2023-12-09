extends Node2D

onready var server_ip_text_edit = $Background_panel/Server_ip_text_edit

func _on_Join_server_pressed():
	Network.ip_address = server_ip_text_edit.text
	hide()
	Network.join_server()
	Global.join = true
	
	

func _on_Go_back_pressed():
	get_tree().reload_current_scene()
