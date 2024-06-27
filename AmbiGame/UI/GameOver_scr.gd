
extends CanvasLayer
var calculoAmbiguedad
func _ready():
	# Obtener el dato enviado desde la escena anterior
	var dato_recibido = calculoAmbiguedad
	print("Dato recibido:", dato_recibido)	
	var label = $TextureRect2/tolerancia_ambiguedad
	if(dato_recibido == null):
		label.text = "SIN DATOS"
	else:
		label.text = str(dato_recibido)
	#$tiempo_trans.text = Global.tiempo_transcurrido
	#print(Global.tiempo_transcurrido)



func _on_reiniciar_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/prototipo_carro_2normal.tscn")
	


func _on_salir_button_pressed():
	get_tree().quit()


"""
extends CanvasLayer

# Variable global para indicar el modo de juego
var modo_vr = false

func _ready():
	var escena_actual = get_tree().get_current_scene()
	
# Verificar si la escena actual está configurada para VR
	if escena_actual.vr_mode_enabled:
		modo_vr = true

func _on_reiniciar_button_pressed():
	if modo_vr:
		# Si estamos en modo de VR, cargar la escena de VR
		get_tree().change_scene_to_file("res://Scenes/escena_vr.tscn")
	else:
		get_tree().change_scene_to_file()"res://Scenes/prototipo_carro_2normal.tscn"

func _on_salir_button_pressed():
	get_tree().quit()
"""
