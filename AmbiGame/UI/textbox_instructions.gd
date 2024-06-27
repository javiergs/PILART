
extends CanvasLayer

#-------------------------------------Mensajes-------------------------------------
const CHAR_READ_RATE = 0.1

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label

enum State{
	 INACTIVE,
	 READY,
	 READING,
	 FINISHED
}

#var current_state = State.READY
var text_queue = []

#animacion letras
var current_text = ""
var current_char = 0
var char_timer = 0.0
var is_text_displayed = false 

func mostrar_texto_inicio():
	_agregar_mensaje("Bienvendo, en esta experiencia virtual tendras que llegar a una ciudad objetivo")
	await get_tree().create_timer(10).timeout 
	_agregar_mensaje("Tu primer objetivo es: " + Global.objetivo_nivel)
	$UIPausa/Label/Label.text = $UIPausa/Label/Label.text + Global.objetivo_nivel
	await get_tree().create_timer(6).timeout 
	_agregar_mensaje("Al presionar el boton B, podras acceder a pausa")
	
	
func _ready():
	#await get_tree().create_timer(5).timeout
	textbox_container.visible = true
	mostrar_texto_inicio()
	
func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()

func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	current_text = next_text
	change_state(State.READING)
	label.text = ""
	show_textbox()
	current_char = 0
	char_timer = 0.0
	is_text_displayed = false  # Reiniciar is_text_displayed cuando se agrega nuevo texto

func _process(delta):
	#print("VR estado:" + str(Global.current_state))
	deteccion()
	set_is_paused()
	
	match Global.current_state:
		Global.State.INACTIVE:
			pass
		Global.State.READY:
			if !text_queue.is_empty():
				display_text()
		Global.State.READING:
			if not is_text_displayed and current_char < current_text.length():
				char_timer += delta
				if char_timer > CHAR_READ_RATE:
					label.text += current_text[current_char]
					current_char += 1
					char_timer = 0.0
			else:
				# Detener el proceso cuando se haya mostrado todo el texto
				is_text_displayed = true  # Se ha mostrado todo el texto
				hide_textbox()
				change_state(State.FINISHED)
				

		Global.State.FINISHED:
			print("Entro finish")
			change_state(State.READY)
			#if Input.is_action_just_pressed("ui_accept"): #Al finalizar presionar enter para quitar textbox
			#	hide_textbox()
				


func deteccion():
	if Global.gano == true:
		Global.gano = false
		await get_tree().create_timer(3).timeout 
		_agregar_mensaje("Muy bien pasaste de nivel, ahora dirígete hacia: " + Global.objetivo_nivel)
		_agregar_mensaje("Muy bien pasaste de nivel, ahora dirígete hacia: " + Global.objetivo_nivel)
		change_state(State.READY)
		

func change_state(next_state):
	Global.current_state = next_state
	match Global.current_state:
		State.READY:
			print("Cambiando estado a: State.READY")
		State.READING:
			print("Cambiando estado a: State.READING")
		State.FINISHED:
			print("Cambiando estado a: State.FINISHED")
		State.INACTIVE:
			print("Cambiando estado a: State.INACTIVE")


func _agregar_mensaje(mensaje):
	queue_text(mensaje + "                ")
	display_text()
	
	
#-------------------------------------Menu Pausa-------------------------------------
@onready var ui_pause = $UIPausa

func set_is_paused():
	if Global.is_paused == true:
		$UIPausa.show()

func _on_reanudar_button_pressed():
	Global.is_paused = false
	$UIPausa.hide()

func _on_reiniciar_button_pressed():
	Global.reiniciar = true
	$UIPausa.hide()

func _on_terminar_button_pressed():
	_agregar_mensaje("Calculando...")
	await get_tree().create_timer(3).timeout
	$UIFinal.show()
	$UIFinal/Tolerancia.text = $UIFinal/Tolerancia.text + str(Global.tolerancia)

