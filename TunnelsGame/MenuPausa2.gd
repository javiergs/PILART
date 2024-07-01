extends Control

var is_paused: bool = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused


func set_is_paused(value:bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func _on_reanudar_button_pressed():
	self.is_paused = false
	$".".hide()
	

func _on_salir_button_pressed():
	# Obtener una referencia al nodo padre
	var nodo_nivel = get_parent()
	# Acceder a la variable puntaje a través del nodo padre
	var calculoAmbiguedad = nodo_nivel._calculoToleranciaAmbiguedad()
	# Hacer algo con el puntaje obtenido
	print("AMBIGUEDAD PAUSE:", calculoAmbiguedad)

	var end_scene = preload("res://UI/GameOver.tscn").instantiate()  # Instanciar la escena
	end_scene.calculoAmbiguedad = calculoAmbiguedad  # Establecer la variable
	#get_tree().change_scene_to_packed(end_scene)  # Cambiar a la nueva escena
	get_tree().root.add_child(end_scene)

	#get_tree().quit()


func _on_reiniciar_button_pressed():
	pass
	#get_tree().change_scene_to_file("res://Scenes/prototipo_carro_2vr.tscn")
	#get_tree().change_scene_to_file("res://Scenes/MapaPrincipal.tscn")
