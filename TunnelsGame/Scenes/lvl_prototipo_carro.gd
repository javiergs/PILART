extends Node3D
@onready var target1 = get_node("../salida1")
@onready var target2 = get_node("../salida2")
@onready var target3 = get_node("../salida3")
@onready var targets = [target1, target2, target3]
var destino = 0
var salida_destino = ""


var pause_menu: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():

	set_process_input(true)
	pause_menu = preload("res://UI/menu_pausa_2.tscn")
	
	hide_textbox()
	queue_text("Haz ganado ...")
	queue_text("Continua yendo hacia ... ")
	queue_text("Textooooo treees")
	
	destino = randi() % targets.size()
	if(destino == 0):
		salida_destino = "salida1"
	elif (destino == 1):
		salida_destino = "salida2"
	elif (destino == 2):
		salida_destino = "salida3"
	print("destino: " + salida_destino)

	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request("https://luisanyel.000webhostapp.com/crearUsuario.json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	"""	
	var road = get_node("NavigationRegion3D/laberintoTuneles/road_tunnel")
	var area = road.get_node("Area3D") as Area3D
	area.body_entered.connect(_entro)
	"""
	"""
	$salida1/Area3D.body_entered.connect(func(body): _entro(body, $salida1/Area3D))
	$salida2/Area3D.body_entered.connect(func(body): _entro(body, $salida2/Area3D))
	$salida3/Area3D.body_entered.connect(func(body): _entro(body, $salida3/Area3D))
	"""
			
func _entro(body, area):
	if(body == $car):		
		if(salida_destino == area.get_parent().name):
			print("Entro123 " + body.to_string())
			print("El objeto entró en el área: " + area.name)
			print("El nodo padre del área es: " + area.get_parent().name)
	$NavigationRegion3D/laberintoTuneles/road_tunnel/Area3D.body_entered.connect(_entro)
	
	var a = $NavigationRegion3D/laberintoTuneles/road_tunnel2/Area3D as Area3D 


func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print(response.glossary['title'])
	#$NavigationRegion3D/laberintoTuneles/road_tunnel/Label3D.text = response.glossary['title']
	$Label3D.text = response.glossary['title']


#########################################################

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		match current_state:
			State.INACTIVE:
				pass
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
	


const CHAR_READ_RATE = 0.02

@onready var textbox_container = $Textbox/TextboxContainer
@onready var start_symbol = $Textbox/TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $Textbox/TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $Textbox/TextboxContainer/MarginContainer/HBoxContainer/Label

enum State{
	 READY,
	 READING,
	 FINISHED,
	 INACTIVE
}

var current_state = State.INACTIVE
var text_queue = []

#animacion letras
var current_text = ""
var current_char = 0
var char_timer = 0.0
var is_text_displayed = false 

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
	#if current_state == State.READY:
		var next_text = text_queue.pop_front()
		current_text = next_text
		change_state(State.READING)
		label.text = ""
		show_textbox()
		current_char = 0
		char_timer = 0.0
		is_text_displayed = false  # Reiniciar is_text_displayed cuando se agrega nuevo texto


func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Cambiando estado a: State.READY")
		State.READING:
			print("Cambiando estado a: State.READING")
		State.FINISHED:
			print("Cambiando estado a: State.FINISHED")
		State.INACTIVE:
			print("Cambiando estado a: State.INACTIVE")

func _on_area_3d_body_entered(body):
	print("ooooo") 
	change_state(State.READY)

func _on_area_3d_body_exited(body):
	change_state(State.FINISHED)
	hide_textbox()
	

############# PAUSA ##################################

func _input(event):
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.keycode == KEY_P and key_event.pressed:
			$MenuPausa3.show()
			#toggle_pause()
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE and key_event.pressed:
			$MenuPausa3.hide()
