
extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label

enum State{
	 READY,
	 READING,
	 FINISHED
}

var current_state = State.READY
var text_queue = []

#animacion letras
var current_text = ""
var current_char = 0
var char_timer = 0.0
var is_text_displayed = false 

func _ready():
	print("Iniciando: State.READY")
	hide_textbox()
	queue_text("ssssssssss texto es creado desde el script")
	queue_text("Texto2 colaaa")
	queue_text("Textooooo treees")
	
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
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if not is_text_displayed and current_char < current_text.length():
				char_timer += delta
				if char_timer > CHAR_READ_RATE:
					label.text += current_text[current_char]
					current_char += 1
					char_timer = 0.0
			else:
				# Detener el proceso cuando se haya mostrado todo el texto
				is_text_displayed = true  # Se ha mostrado todo el texto
				change_state(State.FINISHED)

		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"): #Al finalizar presionar enter para quitar textbox
				change_state(State.READY)
				hide_textbox()


func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Cambiando estado a: State.READY")
		State.READING:
			print("Cambiando estado a: State.READING")
		State.FINISHED:
			print("Cambiando estado a: State.FINISHED")
