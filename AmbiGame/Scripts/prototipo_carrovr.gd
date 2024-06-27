extends Node3D
# Called when the node enters the scene tree for the first time.
#variables IA ;D
var tiempoTotalDeciciones = 0.0
var numDecisiones = 0
var tiempoInicioDecicion = 0.0
var tiempoTotal = 0.0
var destino = 0
var salida_destino = ""
var destinosCorrectos = 0
var destinosIncorrectos = 0
var velocidadPromedio = 0
var tiempoPartida = 0
var tiempoDeciciones = 0
var vehicle 
var promedio_tiempo_decision = 0

#Variables nivel
var objetivo_nivel
var num_nivel = 1
var mapa_json
var reiniciar = false

var pause_menu: PackedScene


func _ready():	
	set_process_input(true)
	pause_menu = preload("res://UI/menu_pausa_2.tscn")
	
	#hide_textbox()

	_leerCalculosAmbiguedad()
	
	$MenuPausa3/CenterContainer/VBoxContainer/Reiniciar_Button.pressed.connect(func():reiniciar=true)	

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._carga_nivel)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request("https://luisanyel.000webhostapp.com/mapa_antiguo.json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	vehicle = get_node("car")
	#_carga_nivel()
	
	
# Función para mostrar el texto de inicio



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if reiniciar:
			#get_node("car").position = Vector3(10,8,0)
			for i in range (1,13):
				get_node("$player_car").position = get_node("Ciudades/Ciudad_" + str(i) + "/Iniciador").position
			
			reiniciar = false
		
		tiempoTotal += delta
		#print("Normal:" + str(current_state))
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
					hide_textbox()
					change_state(State.FINISHED)

			State.FINISHED:
				if Input.is_action_just_pressed("ui_accept"): #Al finalizar presionar enter para quitar textbox
					#hide_textbox()
					change_state(State.READY)
					hide_textbox()	
	
func _carga_nivel(result, response_code, headers, body):
	var json = JSON.new()
	var response
	
	#Obtiene el json del mapa, mediante http y en caso de error por archivo local
	if response_code != 200:
		print("Leido por local")
		var file = FileAccess.open("res://Scripts/mapa.json", FileAccess.READ)
		var content = file.get_as_text()
		json.parse(content)
		response = json.get_data()
	else:
		print("Leido por http")
		json.parse(body.get_string_from_utf8())
		response = json.get_data()
	
	mapa_json = response
	objetivo_nivel = response.niveles[str(num_nivel)]['objetivo']
	$MenuPausa3/Label/Label.text = "Tu objetivo es: " + objetivo_nivel
	Global.objetivo_nivel = objetivo_nivel
	mostrar_texto_inicio()
	
	#Nombra las ciudades, intersecciones y activa señales
	for laberinto in range(1,5):
		for interseccion in range(1,7):
			if interseccion != 6:
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/Area3D_left").body_entered.connect(_interseccion_salida)
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/Area3D_right").body_entered.connect(_interseccion_salida)
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/Area3D_center").body_entered.connect(_interseccion_entrada)
			#Para el caso interseccion izquierda
			else:
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/Area3D_left").body_entered.connect(_interseccion_salida)
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/Area3D_right").body_entered.connect(_interseccion_entrada)
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/Area3D_center").body_entered.connect(_interseccion_salida)
			
			#Recorre los letreros
			for label in range(1,9):
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/doble_sign/left_signs/Label3D" + str(label)).text = response.niveles["1"]["intersecciones"][str(laberinto)+"_"+str(interseccion)]["seniales"]["izquierda"][str(label)]
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/doble_sign/right_signs/Label3D" + str(label)).text = response.niveles["1"]["intersecciones"][str(laberinto)+"_"+str(interseccion)]["seniales"]["derecha"][str(label)]

	print("Termino")
	



	
func mostrar_texto_inicio():
	queue_text("Bienvenido. Tu primer objetivo es: " + objetivo_nivel +"     ")
	# Obtener el primer mensaje en la cola
	var next_text = text_queue.pop_front()
	# Agregar el mensaje de nuevo al final de la cola para iniciar el ciclo
	text_queue.push_back(next_text)
	
	# Mostrar el primer mensaje en la cola
	queue_text(next_text)
	display_text()
	change_state(State.READY)
	
				
				
func _reiniciar_jugador():
	print("entro")
	var p_car = get_node("car") as Node3D	
	print(str(p_car.global_position))
	p_car.position = Vector3(15,15,0)
	print(str(p_car.global_position))
		
		
func _cargar_siguiente_nivel():
	num_nivel += 1
	objetivo_nivel = mapa_json.niveles[str(num_nivel)]['objetivo']
	#Nombra las ciudades, intersecciones y activa señales
	for laberinto in range(1,5):
		for interseccion in range(1,7):
			#Recorre los letreros
			for label in range(1,9):
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/doble_sign/left_signs/Label3D" + str(label)).text = mapa_json.niveles[str(num_nivel)]["intersecciones"][str(laberinto)+"_"+str(interseccion)]["seniales"]["izquierda"][str(label)]
				get_node("laberintoTuneles"+str(laberinto)+"/intersection_tunnel_señal"+str(interseccion)+"/doble_sign/right_signs/Label3D" + str(label)).text = mapa_json.niveles[str(num_nivel)]["intersecciones"][str(laberinto)+"_"+str(interseccion)]["seniales"]["derecha"][str(label)]			
				
			

func _deteccion_area_ciudad(id, body):
	print("Se activo el area de " + id + " y entro un " + body.to_string())

	if id == objetivo_nivel:
		gano = true
		Global.gano = true
		_cargar_siguiente_nivel()
		$MenuPausa3/Label/Label.text = "Tu objetivo es: " + objetivo_nivel
	else:
		perdio = true
		Global.perdio = true
		
	reiniciar = true
	_carga_UI(gano)
	_carga_IA(gano)
	

var gano = false	
var perdio = false


func _carga_UI(gano):
	if gano:
		queue_text("Muy bien, ahora dirígete hacia : " + objetivo_nivel + "        ")
		# Obtener el primer mensaje en la cola
		var next_text = text_queue.pop_front()
		
		# Agregar el mensaje de nuevo al final de la cola para iniciar el ciclo
		text_queue.push_back(next_text)
		
		# Mostrar el primer mensaje en la cola
		queue_text(next_text)
		display_text()
		change_state(State.READY)
		gano = false
		Global.gano = false
	
	if perdio:
		queue_text("Lo siento, has perdido. Tu destino era: " + objetivo_nivel + "        ")
		var next_text = text_queue.pop_front()
		
		# Agregar el mensaje de nuevo al final de la cola para iniciar el ciclo
		text_queue.push_back(next_text)
		
		# Mostrar el primer mensaje en la cola
		queue_text(next_text)
		display_text()
		change_state(State.READY)
		perdio = false
		Global.perdio = false


"""
=======
				
>>>>>>> Stashed changes
func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	return response
<<<<<<< Updated upstream
"""
const CHAR_READ_RATE = 0.2

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
		#label.text = ""
		show_textbox()
		current_char = 0
		char_timer = 0.0
		is_text_displayed = false  # Reiniciar is_text_displayed cuando se agrega nuevo texto


func change_state(next_state):
	current_state = next_state
	Global.current_state = next_state
	match current_state:
		State.READY:
			print("Cambiando estado a: State.READY")
		State.READING:
			print("Cambiando estado a: State.READING")
		State.FINISHED:
			print("Cambiando estado a: State.FINISHED")
		State.INACTIVE:
			print("Cambiando estado a: State.INACTIVE")

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
			
	

	
func _carga_IA(gano):
	if gano:
		print("DEBUG GANASTE")
		destinosCorrectos += 1
		_calculoToleranciaAmbiguedad()
	else:
		print("DEBUG PERDISTE")
		destinosIncorrectos += 1		
		_calculoToleranciaAmbiguedad()
		
		
func _calculoToleranciaAmbiguedad():
	if destinosCorrectos > 0 || destinosIncorrectos > 0:
		#print("La velocidad promedio del vehículo es desde el scrpt del NIVEL: ", vehicle.velocidad_promedio, " unidades por segundo")
		velocidadPromedio = vehicle.velocidad_promedio	
		if numDecisiones > 0:
			promedio_tiempo_decision = tiempoTotalDeciciones / numDecisiones
			promedio_tiempo_decision = promedio_tiempo_decision/1000
		print("Promedio de tiempo de decisión: " + str(promedio_tiempo_decision) + " ms")
		print("El tiempo total de la partida es: ", tiempoTotal, " segundos")	
		print("velocidad promedio = ", velocidadPromedio)
		print("puntos correctos = ", destinosCorrectos)
		print("puntos incorrectos = ", destinosIncorrectos)
		var toleranciaAmbiguedad = (destinosCorrectos/(destinosCorrectos+destinosIncorrectos))
		toleranciaAmbiguedad -= promedio_tiempo_decision/tiempoTotal
		toleranciaAmbiguedad += velocidadPromedio/tiempoTotal
		print("LA TOLERANCIA A LA AMBIGUEDAD ES DE: " , toleranciaAmbiguedad)
		_guardarCalculoAmbiguedad()
		return toleranciaAmbiguedad
	else:
		print("SIN DATOS")	
		return null
func _guardarCalculoAmbiguedad():	
	print("DEBUG GUARDAR CALCULOS AMBIGUEDAD")
	var datos = ConfigFile.new()
	var resultado = datos.load("historialCalculosAmbiguedad.cfg")
	print("RESULTADO GUARDAR CALCULOS AMBIGUEDAD ", resultado)
	# Si el archivo no existe, resultado será ERR_FILE_NOT_FOUND
	if resultado == ERR_FILE_NOT_FOUND:
		print("DEBUG GUARDAR IF")      
		datos = ConfigFile.new()  # Crea un nuevo archivo de configuración            
	# Crea una sección única para cada partida
	var tiempo_actual = Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system()
	var seccion = "partida_" + tiempo_actual

	datos.set_value(seccion, "velocidadPromedio", velocidadPromedio)
	datos.set_value(seccion, "tiempoDecicion", promedio_tiempo_decision)
	datos.set_value(seccion, "tiempoTotal", tiempoTotal)
	datos.set_value(seccion, "destinosCorrectos", destinosCorrectos)
	datos.set_value(seccion, "destinosIncorrectos", destinosIncorrectos)
	# Guarda los datos en el archivo
	datos.save("historialCalculosAmbiguedad.cfg")

func _leerCalculosAmbiguedad():
	print("DEBUG LEER CALCULOS")
	var datos = ConfigFile.new()
	var resultado = datos.load("historialCalculosAmbiguedad.cfg")
	print("RESULTADO DEBUG LEER CALCULOS: ", resultado)
	if resultado == OK:  # Si el archivo se cargó correctamente
		print("OK DEBUG LEER CALCULOS")
		# Obtiene una lista de todas las secciones en el archivo
		var secciones = datos.get_sections()
		# Recorre cada sección
		for seccion in secciones:
			var velocidadPromedio = datos.get_value(seccion, "velocidadPromedio")
			print("CONFIG VELOCIDAD: ", velocidadPromedio)
			var tiempoTotal = datos.get_value(seccion, "tiempoTotal")
			print("CONFIG TIEMPOTOTAL: ", tiempoTotal)
			var destinosCorrectos = datos.get_value(seccion, "destinosCorrectos")
			print("CONFIG DESTINOSC: ",destinosCorrectos)
			var destinosIncorrectos = datos.get_value(seccion, "destinosIncorrectos")
			print("CONFIG DESTINOSI: ", destinosIncorrectos)	
func _interseccion_entrada(body):
	print("INICIAR CONTADOR DECICION")		
	tiempoInicioDecicion = Time.get_ticks_msec()	
func _interseccion_salida(body):
	print("DETENER CONTADOR DECICION")
	var tiempoDecision = Time.get_ticks_msec() - tiempoInicioDecicion
	tiempoTotalDeciciones += tiempoInicioDecicion
	numDecisiones += 1


func _on_area_3d_body_exited(body):
	var carro = $car as VehicleBody3D
	$car.set_global_position($Iniciador.get_global_position())
	$car.set_global_rotation(Vector3(0,0,0))
	carro.linear_velocity = Vector3(0,0,0)
