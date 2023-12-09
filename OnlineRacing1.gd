extends Node2D


func _player_disconnected(id):
	if Players.has_node(str(id)):
		Players.get_node(str(id)).username_text_instance.queue_free()
		Players.get_node(str(id)).queue_free()


#func _on_FinishLine_body_entered(body):
#	rpc("switch_to_server")
	
#sync func switch_to_server():
#	get_tree().change_scene("res://Network_setup.tscn")
#	Global.onlineRacingStart = false
