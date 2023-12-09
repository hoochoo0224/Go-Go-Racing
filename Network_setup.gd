extends Node2D

var player = load("res://Player.tscn")

onready var multiplayer_config_ui = $Mulitplayer_configure

onready var device_ip_address = $CanvasLayer/Device_ip_address
onready var loby = $Loby
onready var start_game = $Loby/Start_game
onready var left_game = $Loby/Left_game
onready var left_game2 = $Loby/Left_game2

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address
	
	if get_tree().network_peer != null:
		pass
	else:
		start_game.disabled = true

func _process(delta: float):
	if get_tree().network_peer != null:
		if get_tree().is_network_server():
			start_game.show()
			left_game.hide()
			left_game2.show()
			$Loby/Map_button.show()
		else:
			start_game.hide()
			left_game.show()
			left_game2.hide()
			$Loby/Map_button.hide()
			
		if get_tree().get_network_connected_peers().size() >= 1:
			start_game.disabled = false
		else:
			start_game.disabled = true
			
	if !multiplayer_config_ui.visible and !has_node("Server_browser"):
		loby.show()
	elif Global.join:
		loby.show()
	else:
		loby.hide()

func _player_connected(id):
	print("Player " + str(id) + " has connected")
	
	instance_player(id)
	
func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	
	if Players.has_node(str(id)):
		Players.get_node(str(id)).username_text_instance.queue_free()
		Players.get_node(str(id)).queue_free()
		#Players.get_node("SoundEffect" + str(id)).queue_free()
		#Players.get_node("DriftSkid" + str(id)).queue_free()

func _on_Create_server_pressed():
	Network.current_player_username = Global.nickname
	multiplayer_config_ui.hide()
	Network.create_server()
		
	instance_player(get_tree().get_network_unique_id())
	Global.server_close = false

func _on_Join_server_pressed():
	multiplayer_config_ui.hide()
	
	Global.instance_node(load("res://Server_browser.tscn"), self)

func _on_Back_button_pressed():
	get_tree().change_scene("res://Loby.tscn")


func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())

var place = [
	Vector2(205, 195), Vector2(510, 195), Vector2(815, 195),
	Vector2(205, 370), Vector2(510, 370), Vector2(815, 370)
]



func instance_player(id) -> void:
	var rand = randi() % 6
	print(rand)
	var player_instances = Global.instance_node_at_location(player, Players, place[rand])
	player_instances.name = str(id)
	player_instances.set_network_master(id)
	print(id)
	player_instances.username = Global.nickname
	Global.players.append(id)

func _on_Start_game_pressed():
	rpc("switch_to_game")

var map = "OnlineRacing1"

sync func switch_to_game() -> void:
	get_tree().change_scene("res://"+map+".tscn")
	Global.onlineRacingStart = true

func _on_Left_game_pressed():
	rpc("left_game")

func _on_Left_game2_pressed():
	rpc("left_game2")

	
sync func left_game():
	print(get_tree().get_network_unique_id())
	Network.disconnect_player(get_tree().get_network_unique_id())
		
sync func left_game2():
	if is_network_master():
		print(get_tree().get_network_unique_id())
		Network.stop_server()
		Global.server_close = true
	else:
		print(get_tree().get_network_unique_id())
		Network.disconnect_player(get_tree().get_network_unique_id())

func _on_Map_button_pressed():
	$Loby/Node2D/WindowDialog.show()
	$CanvasLayer/Device_ip_address.hide()
	$"/root/Players".hide()

sync func change_map(map_name):
	map = map_name
	
func _on_Level_4_pressed():
	rpc("change_map", "OnlineRacing1")
	$Loby/Node2D/WindowDialog.hide()

func _on_Level_5_pressed():
	rpc("change_map", "OnlineRacing2")
	$Loby/Node2D/WindowDialog.hide()
	
func _on_PlayGround_pressed():
	rpc("change_map", "PlayGround")
	$Loby/Node2D/WindowDialog.hide()

func _on_WindowDialog_hide():
	$CanvasLayer/Device_ip_address.show()
	$"/root/Players".show()
