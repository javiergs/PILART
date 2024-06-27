@tool
extends Control

# These custom signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal scene_update

#Attributes
var _DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
var _PORT = 135
var _MAX_CONNECTIONS = 20

#Paths for temp files
var _SEND_PATH = "res://sendtemp.tscn"
var _RECEIVE_PATH = "res://receivetemp.tscn"
var _RECEIVE_CACHE = []


# This will contain player info for every player,
# with the keys being each player's unique IDs.
var _players = {}

# This is the local player info.
var _player_info = {}

#Count of players
var _players_loaded = 0

var real = false

var _global_scene# = EditorInterface.get_edited_scene_root() #Cambiar por export en UI
	
#Is called when the node and its children 
#have all added to the scene tree and are ready
func _ready():
	#Links to calls editor plugin
	scene_update.connect(_on_scene_update_modify)
	_global_scene = EditorInterface.get_edited_scene_root()
	#_global_scene.get_tree().node_added.connect(_on_scene_update_add)
	#_global_scene.get_tree().node_removed.connect(_on_scene_update_remove)
	EditorInterface.get_selection().selection_changed.connect(_on_is_selected_change)
	#Init. Links to calls
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	
	print("carga: " + _global_scene.scene_file_path.get_file())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
@rpc("any_peer", "call_local", "reliable")
func _process(delta):
	#Reducir a cada dos frames
	if Engine.get_process_frames() % 300 == 0:
		if real == true:
			if Engine.is_editor_hint():
				if multiplayer.multiplayer_peer != null:
					_update_player_transform.rpc()


#-------------------------Library Server---------------------------
#Create a server 
func _create_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(_PORT, _MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	_players[1] = _player_info
	player_connected.emit(1, _player_info)
	print("Servidor creado con exito en el puerto:" + str(_PORT) + " en la direccion: " + str(IP.get_local_addresses()) )


#Create a client a join in a server
func _create_client(address = ""):
	if address.is_empty():
		address = _DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, _PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	print("Cliente creado con exito en el puerto:" + str(_PORT) + " en la direccion:" + str(address))


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
	print("Usuario creado con el id:" + str(new_player_id))


func _on_player_disconnected(id):
	_players.erase(id)
	player_disconnected.emit(id)
	print("Jugador desconectado")


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	_players[peer_id] = _player_info
	player_connected.emit(peer_id, _player_info)
	print("Conexion exitosa")


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	print("Conexion fallida")


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	print("Remueve peer")
	

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	_players.clear()
	server_disconnected.emit()
	print("Server desconectado")


#------------------------------Buttons-------------------------------
func _on_btn_start_host_pressed():
	_player_info = {"nickname":$vbx_nickname/ln_nickname.text}
	_create_server()
	# Get automatically host scene. Try to create select export scene in gui
	_global_scene = EditorInterface.get_edited_scene_root()
	

func _on_btn_stop_host_pressed():
	_on_server_disconnected()


func _on_btn_join_client_pressed():
	_player_info = {"nickname":$vbx_nickname/ln_nickname.text}
	print($ln_client_ip.text)
	_create_client($ln_client_ip.text)


func _on_btn_disconnect_client_pressed():
	remove_multiplayer_peer()


func _on_btn_update_peer_list_pressed():
	if _get_players() == {}:
		$txe_peers.text = "Vacio"
	else:
		$txe_peers.text = _get_players()


func _on_btn_test_pressed():
	if real == false:
		real = true
	else:
		real = false

func _on_btn_test_2_pressed():
	#_create_copy(_global_scene.find_child("MeshInstance3D"),_SEND_PATH)
	#var h = load(_RECEIVE_PATH).instantiate()
	var h = ResourceLoader.load(_RECEIVE_PATH,"",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
	h.scene_file_path = ""
	_global_scene.add_child(h)
	h.set_owner(_global_scene)
	print(_global_scene.get_tree_string_pretty())
	
	

	
	
#----------------------Signal_functions-----------------------------
func _on_is_selected_change():
	if multiplayer.multiplayer_peer != null:
		var selected = EditorInterface.get_selection().get_selected_nodes()
		if selected != []:
			selected = selected.front().name
			print("Elemento seleccionado:" + selected)
			if selected in _RECEIVE_CACHE:
				_RECEIVE_CACHE.erase(selected)
				EditorInterface.save_scene()#Try use EditorInterface.call_deferred("save_scene")
			
	
	

#Se ejecuta cuando se modifica
func _on_scene_update_modify():
	if multiplayer.multiplayer_peer != null:
		print("Entro modify")
		var data_selected = _get_selected_object()
		if data_selected == null:
			print("No tienes nada seleccionado")
		else:
			_create_copy(data_selected['node'], _SEND_PATH)
			var data = {'data':readFile(_SEND_PATH),'parent':data_selected['parent']}
			_peer_on_scene_update_modify.rpc(data)


@rpc("any_peer", "call_local", "reliable")
func _peer_on_scene_update_modify(data):
	if data != null:
		print("Entro modify peer")
		if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
			print("Llamada a si mismo, no hace nada")
		else:
			print("Llamada desde otro, si hace")
			#print(data['data'])
			await writeFile(data['data'],_RECEIVE_PATH)
			#print(readFile(_RECEIVE_PATH))
			#Create instance
			var instance = ResourceLoader.load(_RECEIVE_PATH,"",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
			instance.scene_file_path = ""
			#EditorInterface.get_edited_scene_root().set_editable_instance(instance,true)
			var original_instance_name = instance.name
			#Replace node
			var search_replace = EditorInterface.get_edited_scene_root().find_child(instance.name)
			if search_replace != null:
				print()
				#search_replace.replace_by(instance)
				search_replace.name = "temp"
				print(search_replace)
				search_replace.queue_free() 
				#await search_replace.tree_exited
				#EditorInterface.get_edited_scene_root().remove_child(search_replace)
				print(EditorInterface.get_edited_scene_root().get_tree_string_pretty())
				print("Padre:" + str(data['parent']))
				var search_parent_replace
				if data['parent'] != EditorInterface.get_edited_scene_root().name:
					print("Entro1")
					search_parent_replace = EditorInterface.get_edited_scene_root().find_child(data['parent'])
				else:
					print("Entro2")
					search_parent_replace = EditorInterface.get_edited_scene_root()
				if search_parent_replace != null:
					print("Se buscara el padre modificar replace: " + data['parent'])
					print("Se modificara la instancia:" + instance.name)
					search_parent_replace.add_child(instance)
					instance.set_owner(EditorInterface.get_edited_scene_root())
					print("Se modifico hijo existente.")
					print(EditorInterface.get_edited_scene_root().get_tree_string_pretty())
					print(EditorInterface.get_edited_scene_root().find_child(instance.name).to_string())
			else:
				print("Se buscara el padre modificar: " + data['parent'])
				if data['parent'] == EditorInterface.get_edited_scene_root().name:
					EditorInterface.get_edited_scene_root().add_child(instance)
					instance.set_owner(EditorInterface.get_edited_scene_root())
					print("Se agrego en modificar raiz")
				else:
					var search_parent = EditorInterface.get_edited_scene_root().find_child(data['parent'])
					if search_parent != null:
						search_parent.add_child(instance)
						instance.set_owner(EditorInterface.get_edited_scene_root())
						print("Se agrego en modificar hijo.")
			#Append peer change to array cache
			_RECEIVE_CACHE.append(instance.name)
		
		
		
#Se ejecuta cuando se agrega o elimina nodo
func _on_scene_update_add(node):
	if node != null:
		if multiplayer.multiplayer_peer != null:
			if node is Node3D:
				print("Entro add")
				var search = _global_scene.find_child(node.name)
				print("Antes de entrar busqueda add")
				print(node.name)
				if search == null:
					print("Llamara peer add")
					_create_copy(node, _SEND_PATH)
					var data = {'data':readFile(_SEND_PATH),'parent':node.get_parent().name}
					_peer_on_scene_update_add.rpc(data)
		
			
			
@rpc("any_peer", "call_local", "reliable")
func _peer_on_scene_update_add(data):
	if data != null:
		print("Entro add peer")
		if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
			print("Llamada a si mismo, no hace nada")
		else:
			print("Llamada desde otro, si hace")
			writeFile(data['data'],_RECEIVE_PATH)
			#Create instance
			var new_node = load(_RECEIVE_PATH)
			var instance = new_node.instantiate()
			instance.scene_file_path = ""
			#Replace node
			print("Se buscara el padre agregar: " + data['parent'])
			if data['parent'] == EditorInterface.get_edited_scene_root().name:
				EditorInterface.get_edited_scene_root().add_child(instance)
				instance.set_owner(EditorInterface.get_edited_scene_root())
				print("Se agrego en modificar raiz")
			else:
				var search = EditorInterface.get_edited_scene_root().find_child(data['parent'])
				if search != null:
					search.add_child(instance)
					instance.set_owner(EditorInterface.get_edited_scene_root())
					print("Se agrego en modificar hijo.")
		
		
func _on_scene_update_remove(node):
	if node != null:
		if multiplayer.multiplayer_peer != null:
			if node is Node3D:
				print("Entro remove" + node.name)
				var search_remove = EditorInterface.get_edited_scene_root().find_child(node.name)
				if search_remove:
					print("Llamara a remove peer")
					_peer_on_scene_update_remove.rpc(node.name)
			
			
@rpc("any_peer", "call_local", "reliable")
func _peer_on_scene_update_remove(nameNode):
	#Remove old node
	print("Entro remove peer")
	print("Se buscara el nodo a remover: " + nameNode)
	var search = EditorInterface.get_edited_scene_root().find_child(nameNode)
	if search != null:
		search.queue_free()
		await search.tree_exited



	
#--------------------------Peer_functions-----------------------
# Call local is required if the server is also a player.
@rpc("any_peer", "call_local", "reliable")
func _update_player_transform():
	var current_scene = EditorInterface.get_edited_scene_root()
	if current_scene is Node3D:
		#Get camera position
		var position = EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_transform
		print("La ubicacion del id: " + str(multiplayer.get_remote_sender_id()) + " es: " + str(position))


@rpc("any_peer", "call_local", "reliable")
func _peer_send_data(value = "Nada"):
	print("ID: " + str(multiplayer.get_remote_sender_id()) + " sent: " + str(value))

	
#---------------------Local_Functions-------------------------

func readFile(path_file):
	var file = FileAccess.open(path_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content
	

func writeFile(content,path_file):
	var file = FileAccess.open(path_file, FileAccess.WRITE)
	file.store_string(content)
	file.close()


func _get_selected_object():
	var selected = EditorInterface.get_selection().get_selected_nodes()
	if selected == []:
		return null
	else:
		selected = selected.front()
		var parent = EditorInterface.get_selection().get_selected_nodes().front().get_parent().name
		var selected_reply = {'node':selected, 'parent':parent}
		return selected_reply

	
func _create_copy(node,path):
	var scene = PackedScene.new()
	var result = scene.pack(node)
	
	if result == OK:
		var error = ResourceSaver.save(scene, path) 
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
			
	print("Node copy: " + node.name + " created successfully") #return path_copy
	
	
	


	"""
	#print(EditorInterface.get_edited_scene_root().get_tree().tree_changed)
	#_create_copy(_get_selected_object())
	
	var text = readFile("res://ambi.tscn")
	
	writeFile("res://temp.tscn",text)
	var new_node = load("res://temp.tscn")
	var instance = new_node.instantiate()# as MeshInstance3D
	instance.name = "Hola"
	EditorInterface.get_edited_scene_root().find_child("Floor").add_child(instance)
	instance.set_owner(EditorInterface.get_edited_scene_root())


	#var abc = EditorInterface.get_edited_scene_root().find_child("MeshInstance3D")
	#var data_scene = _get_text_current_scene()
	#_peer_compare_scenes.rpc_id(1,data_scene['content'], data_scene['time'])
	#var file1 = FileAccess.open("res://name.tscn", FileAccess.READ)
	#var content1 = file1.get_as_text()
	#_local_update_scene(content1)
	#var abc = preload("res://obj.tscn").instantiate()
	#EditorInterface.get_edited_scene_root().find_child("MeshInstance3D").position
	#print(abc.position)
	
	print(EditorInterface.get_edited_scene_root().find_child("MeshInstance3D").position)
	print(EditorInterface.get_edited_scene_root().find_child("MeshInstance3D").get_property_list())
	
	var abc = preload("res://obj.tscn").instantiate()
	var bcd = ResourceLoader.load("res://obj.tscn")
	#print(abc.transform)
	#print(bcd.get_state())
	
	#_mandar_datos(content1)

	

	compare_scene_files(EditorInterface.get_edited_scene_root().scene_file_path, "res://name.tscn")
	_create_copy_curent_scene()
	
	var envio = EditorInterface.get_selection().get_selected_nodes().front()
	print("Envio")
	print([str(envio.name), envio.position])
	_mover_cuadro.rpc([str(envio.name), envio.position])
	"""
	
	#var posicion_local = current_scene_root.find_child("Floor").position
	#_mover_cuadro.rpc(EditorInterface.get_selection().get_selected_nodes())
	#_mandar_datos.rpc(str(EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_transform))
	#_mover_cuadro().rpc()
	#_update_player_transform.rpc()
	#print(_global_scene)
	#_get_scene_transform()
	#Obtiene objetos seleccionados	
	#print(EditorInterface.get_selection().get_selected_nodes())

"""
var scene = PackedScene.new()
	var envio = EditorInterface.get_selection().get_selected_nodes().front()
	#var my_o = envio.get_owner()
	var my_p = envio.get_parent()
	#print("Owner")
	#print(my_o)
	print("Parent")
	print(my_p)
	var result = scene.pack(envio)
	#var path_copy = EditorInterface.get_edited_scene_root().scene_file_path

	if result == OK:
		var error = ResourceSaver.save(scene, "res://obj.tscn")  # ResourceSaver.FLAG_CHANGE_PATH|ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")

	var new_node = load("res://obj.tscn")
	# o tambien con este var new_node = ResourceLoader.load("res://obj.tscn")
	var instance = new_node.instantiate() as MeshInstance3D
	instance.name = instance.name+"1"
	
	#print()
	#print(instance.name)
	#EditorInterface.get_edited_scene_root().add_child(instance)
	EditorInterface.get_edited_scene_root().find_child(my_p.name).add_child(instance)
	instance.set_owner(EditorInterface.get_edited_scene_root())
	
	#copia.set_name("AA")
	#copia.set_owner(my_o)
	
	#instance.set_owner(my_o)
	#print(EditorInterface.get_edited_scene_root().find_child("Test3d"))
	#print(find_child("MeshInstance3D"))
	#remove_child(find_child("MeshInstance3D"))
	#EditorInterface.get_edited_scene_root().find_child("_MeshInstance3D_25253").queue_free()
	#print(EditorInterface.get_edited_scene_root().find_child("_MeshInstance3D_23226"))
	#print(EditorInterface.get_edited_scene_root().find_child(EditorInterface.get_edited_scene_root().get_children()[1].name))
	#EditorInterface.get_edited_scene_root().get_children()[1].position.x = 5
	#print(EditorInterface.get_edited_scene_root().find_child("Test3d"))
	#print(EditorInterface.get_edited_scene_root().owner)
	print(EditorInterface.get_edited_scene_root().get_tree_string_pretty())
	#instance.queue_free()
	print("Exito")
"""
