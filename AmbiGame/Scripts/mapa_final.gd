#@tool #Descomentar para ver vista previa
extends Node3D
#Init peticiones
var http_request = HTTPRequest.new()

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
var ciudades_to_num = {}


func _deteccion_area_ciudad(id, body):
	print("Se activo el area de " + id + " y entro un " + body.to_string())
	Global.ultima_ciudad = id
	
	if id == Global.objetivo_nivel:
		Global.gano = true
		_cargar_siguiente_nivel()
		destinosCorrectos += 1
		_calculoToleranciaAmbiguedad()
	else:
		destinosIncorrectos += 1		
		_calculoToleranciaAmbiguedad()

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
	
	#Cambia letreros e inicia indicaciones
	print("Nivel actual " + str(Global.numero_nivel_actual))
	Global.inicio_nivel = response.niveles[str(Global.numero_nivel_actual)]['inicia:'] 
	Global.objetivo_nivel = response.niveles[str(Global.numero_nivel_actual)]['objetivo']
	
	ciudades_to_num = {}
	#Cargar nombre ciudades y Vincula areas3D de las ci
	for i in range(1,13):	
		ciudades_to_num[response.ciudades[str(i)]] = str(i)
		get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Letrero_aereo/Label3D").text = response.ciudades[str(i)]
		get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Area3D").body_entered.connect(func(body):_deteccion_area_ciudad(response.ciudades[str(i)], body))
		#Recorre los letreros
		
		
	for interseccion in range(1,14):	
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/Area3D_left").body_entered.connect(_interseccion_area)
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/Area3D_right").body_entered.connect(_interseccion_area)
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/Area3D_center").body_entered.connect(_interseccion_area)
		for letrero in range(1,4):
			#Letrero izquierda
			get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/doble_signs_izq/left_signs/Label3D"+str(letrero)).text = response.niveles[str(Global.numero_nivel_actual)]["intersecciones"][str(interseccion)]["seniales_izq"]["izquierda"][str(letrero)]
			get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/doble_signs_izq/right_signs/Label3D"+str(letrero)).text = response.niveles[str(Global.numero_nivel_actual)]["intersecciones"][str(interseccion)]["seniales_izq"]["derecha"][str(letrero)]
			#Letrero derecha
			get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/doble_signs_der/left_signs/Label3D"+str(letrero)).text = response.niveles[str(Global.numero_nivel_actual)]["intersecciones"][str(interseccion)]["seniales_der"]["izquierda"][str(letrero)]
			get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/doble_signs_der/right_signs/Label3D"+str(letrero)).text = response.niveles[str(Global.numero_nivel_actual)]["intersecciones"][str(interseccion)]["seniales_der"]["derecha"][str(letrero)]
			#Letrero derecha
			get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/doble_signs_med/left_signs/Label3D"+str(letrero)).text = response.niveles[str(Global.numero_nivel_actual)]["intersecciones"][str(interseccion)]["seniales_med"]["izquierda"][str(letrero)]
			get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/doble_signs_med/right_signs/Label3D"+str(letrero)).text = response.niveles[str(Global.numero_nivel_actual)]["intersecciones"][str(interseccion)]["seniales_med"]["derecha"][str(letrero)]
		
	print("Mapa actualizado correctamente")
	
	# Reposicionar el vehículo al iniciador después del reinicio
	$player_car.set_global_position(get_node("Ciudades/Ciudad_" + str(ciudades_to_num[Global.inicio_nivel]) + "/Iniciador").get_global_position())
	# Reiniciar la velocidad lineal del vehículo a cero
	var carro = $player_car as VehicleBody3D
	carro.linear_velocity = Vector3(0, 0, 0)
	$player_car.set_global_rotation(Vector3(0, 0, 0))
	
	
func _interseccion_area(body):
	if Global.habia_entrado == false:
		print("INICIAR CONTADOR DECISION")		
		tiempoInicioDecicion = Time.get_ticks_msec()
		Global.habia_entrado = true
	else:
		print("DETENER CONTADOR DECISION")
		var tiempoDecision = Time.get_ticks_msec() - tiempoInicioDecicion
		tiempoTotalDeciciones += tiempoInicioDecicion
		numDecisiones += 1
		Global.habia_entrado = false
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	#_vista_desarrollador(1,false) #Descomentar para ver vista previa
	add_child(http_request)
	http_request.request_completed.connect(self._carga_nivel)
	_peticion_http("https://luisanyel.000webhostapp.com/mapa.json")
	
	
func _peticion_http(url):
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _vista_desarrollador(nivel,visible_):
	var json = JSON.new()
	var response
	
	var file = FileAccess.open("res://Scripts/mapa.json", FileAccess.READ)
	var content = file.get_as_text()
	json.parse(content)
	response = json.get_data()
	#print(response)
	#Cargar nombre ciudades y Vincula areas3D de las ci
	for i in range(1,13):	
		get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Letrero_aereo/Label3D").text = response.ciudades[str(i)]
		#get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Letrero_aereo/Label3D").visible = visible_
		#get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Letrero_terrestre/Label3D").text = response.ciudades[str(i)]
		#get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Letrero_terrestre/Label3D").visible = visible_
	
	for interseccion in range(1,14):	
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/nombre_interseccion").text = str(interseccion)
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/nombre_interseccion").visible = visible_
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/izquierda").text = "izquierda"
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/izquierda").visible = visible_
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/derecha").text = "derecha"
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/derecha").visible = visible_
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/medio").text = "medio"
		get_node("Tuneles/intersection_tunnel"+str(interseccion)+"/medio").visible = visible_
		
#n_ciudad_actual
func _reinicar():
	if Global.reiniciar == true:
		# Reposicionar el vehículo al iniciador después del reinicio
		$player_car.set_global_position(get_node("Ciudades/Ciudad_" + str(ciudades_to_num[Global.ultima_ciudad]) + "/Iniciador").get_global_position())
		Global.reiniciar = false
		# Reiniciar la velocidad lineal del vehículo a cero
		#var carro = $player_car as VehicleBody3D
		#carro.linear_velocity = Vector3(0, 0, 0)
		#$player_car.set_global_rotation(Vector3(0, 0, 0))
		
		
func _termino():
	if Global.termino == true:
		print("Calcula tolerancia")
		Global.tolerancia = _calculoToleranciaAmbiguedad()
		print("Tolerancia: " + str(Global.tolerancia))
		
func _process(delta):
	_reinicar()
	_termino()
	
	
func _cargar_siguiente_nivel():
	Global.gano = false
	if Global.numero_nivel_actual <= 4:
		Global.numero_nivel_actual += 1
		_peticion_http("https://luisanyel.000webhostapp.com/mapa.json")
	
		

func _carga_IA(gano):
	if gano:		
		destinosCorrectos += 1
		_calculoToleranciaAmbiguedad()
	else:		
		destinosIncorrectos += 1		
		_calculoToleranciaAmbiguedad()
func _calculoToleranciaAmbiguedad():	
	if destinosCorrectos > 0 || destinosIncorrectos > 0:
		velocidadPromedio = 10#vehicle.velocidad_promedio / 20 #normalizado sobre la velocidad maxima esperada		
		var toleranciaAmbiguedad = (destinosCorrectos/(destinosCorrectos+destinosIncorrectos))
		toleranciaAmbiguedad += velocidadPromedio/tiempoTotal		
		_guardarCalculoAmbiguedad()		
		return toleranciaAmbiguedad		
	else:		
		return null
func _guardarCalculoAmbiguedad():		
	var datos = ConfigFile.new()
	var resultado = datos.load("historialCalculosAmbiguedad.cfg")	
	if resultado == ERR_FILE_NOT_FOUND:		
		datos = ConfigFile.new()  # Crea un nuevo archivo de configuración            
	# Crea una sección única para cada partida
	var tiempo_actual = Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system()
	var seccion = "partida_" + tiempo_actual
	datos.set_value(seccion, "velocidadPromedio", velocidadPromedio)	
	datos.set_value(seccion, "tiempoTotal", tiempoTotal)
	datos.set_value(seccion, "destinosCorrectos", destinosCorrectos)
	datos.set_value(seccion, "destinosIncorrectos", destinosIncorrectos)
	# Guarda los datos en el archivo
	datos.save("historialCalculosAmbiguedad.cfg")	
	#_leerCalculosAmbiguedad()	
func _leerCalculosAmbiguedad():	
	var datos = ConfigFile.new()
	var resultado = datos.load("historialCalculosAmbiguedad.cfg")
	
	if resultado == OK:  # Si el archivo se cargó correctamente
		# Obtiene una lista de todas las secciones en el archivo
		var secciones = datos.get_sections()
		var json_array = []
		
		# Recorre cada sección
		for seccion in secciones:
			var velocidadPromedio = datos.get_value(seccion, "velocidadPromedio")
			var tiempoTotal = datos.get_value(seccion, "tiempoTotal")
			var destinosCorrectos = datos.get_value(seccion, "destinosCorrectos")
			var destinosIncorrectos = datos.get_value(seccion, "destinosIncorrectos")
			
			# Crea un diccionario para cada sección
			var dict = {
				"timestamp": seccion.replace("partida_", ""),
				"velocidadPromedio": velocidadPromedio,
				"tiempoTotal": tiempoTotal,
				"destinosCorrectos": destinosCorrectos,
				"destinosIncorrectos": destinosIncorrectos
			}
			
			# Agrega el diccionario al array
			json_array.append(dict)
		
		# Convierte el array a JSON
		var json_text = JSON.stringify(json_array)			
		#_enviar_datos(json_text, "http://localhost:5000/prediccionw")			
		var headers = ["Content-Type: application/json"]
		$HTTPRequest.request("http://localhost:5000/prediccion", headers, HTTPClient.METHOD_POST, json_text)		
func _enviar_datos(json_text: String, url: String):
	# Crea una nueva instancia de HTTPRequest
	var http_request_regresion_lineal = HTTPRequest.new()	
	# Añade el HTTPRequest al árbol de escena
	self.add_child(http_request_regresion_lineal)	
	# Conecta la señal request_completed a una función
	http_request_regresion_lineal.request_completed.connect( self._on_request_completed)
	# Prepara los datos de la solicitud
	var headers = ["Content-Type: application/json"]
	var body = PackedByteArray(Array(json_text.to_utf8_buffer()))	
	# Realiza la solicitud POST
	var error = http_request_regresion_lineal.request(url, headers, HTTPClient.METHOD_POST, body)	
	if error == OK:
		print("Solicitud enviada correctamente.")
	else:
		print("Error al enviar la solicitud: ", error)
func _on_request_completed(result, response_code, headers, body):
	print("Código de respuesta HTTP: ", response_code)
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("DEBUG RESPUESTA REGRESION: ",json)

