
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

func print_start_message():
	_print_message("Welcome, in this virtual experience you need to reach an objective city")
	await get_tree().create_timer(10).timeout 
	_print_message("Your first objective is: " + Global.level_objective)
	$UIPausa/Label/Label.text = $UIPausa/Label/Label.text + Global.level_objective
	await get_tree().create_timer(6).timeout 
	_print_message("You can pause the experience by pressing the B button")
	await get_tree().create_timer(10).timeout 
	_print_message("In the pause menu you can see your current objective, reset your car if you get stuck, or, leave the game")
	
func _ready():
	#await get_tree().create_timer(5).timeout
	textbox_container.visible = true
	print_start_message()
	
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
	if Global.won == true:
		Global.won = false
		await get_tree().create_timer(3).timeout 
		_print_message("Muy bien pasaste de nivel, ahora dirígete hacia: " + Global.level_objective)
		_print_message("Muy bien pasaste de nivel, ahora dirígete hacia: " + Global.level_objective)
		change_state(State.READY)
		

func change_state(next_state):
	Global.current_state = next_state
	match Global.current_state:
		State.READY:
			print("State changed to: State.READY")
		State.READING:
			print("State changed to: State.READING")
		State.FINISHED:
			print("State changed to: State.FINISHED")
		State.INACTIVE:
			print("State changed to: State.INACTIVE")


func _print_message(message):
	queue_text(message + "                ")
	display_text()
	
	
#-------------------------------------Menu Pausa-------------------------------------
@onready var ui_pause = $UIPausa

func set_is_paused():
	if Global.is_paused == true:
		$UIPausa.show()


func _on_resume_button_pressed():
	Global.is_paused = false
	$UIPausa.hide()


func _on_restart_button_pressed():
	Global.restart = true
	$UIPausa.hide()
	Global.is_paused = false


func _on_exit_button_pressed():
	$UIPausa.hide()
	Global.is_paused = false
	_print_message("Calculating...")
	await get_tree().create_timer(3).timeout
	$UIFinal.show()
	$UIFinal/Tolerancia.text = $UIFinal/Tolerancia.text + str(Global.tolerance)
