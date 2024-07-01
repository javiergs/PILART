@tool
extends Node
class_name MyServer

#IMPORTANT - COPY AFTER HERE AND PASTE WHERE YOU NEED THIS LIBRARY

# Autoload named Lobby

# These custom signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

#Attributes
var _DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
var _PORT : int
var _MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var _players = {}

# This is the local player info.
var _player_info = {}

#Count of players
var _players_loaded = 0


#Constructors
func _init(server_ip, port, max_connections):
	_DEFAULT_SERVER_IP = server_ip
	_PORT = port
	_MAX_CONNECTIONS = max_connections
	
	
#Is called when the node and its children 
#have all added to the scene tree and are ready
func _ready():
	#Init. Links to calls
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


#Create a server 
func _create_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(_PORT, _MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	_players[1] = _player_info
	player_connected.emit(1, _player_info)


#Create a client a join in a server
func _create_client(address = ""):
	if address.is_empty():
		address = _DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, _PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func _set_player_info(nickname):
	_player_info = {"nickname": nickname}


func _get_players():
	return _players
	

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		_players_loaded += 1
		if _players_loaded == _players.size():
			$/root/Game.start_game()
			_players_loaded = 0
	
	
# When a peer connects, send them my player info.
func _on_player_connected(id):
	_register_player.rpc_id(id, _player_info)
	
	
# Call local is required if the server is also a player.
@rpc("any_peer", "call_local", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	_players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	_players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	_players[peer_id] = _player_info
	player_connected.emit(peer_id, _player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	_players.clear()
	server_disconnected.emit()
