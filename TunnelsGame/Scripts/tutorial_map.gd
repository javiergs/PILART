#@tool #uncomment to see preview
extends Node3D
#Init request
var http_request = HTTPRequest.new()

#AI variables
var total_decision_time = 0.0
var number_decisions = 0
var start_decision_time = 0.0
var total_time = 0.0
var target = 0
var target_exit = ""
var correct_targets = 0
var incorrect_targets = 0
var average_speed = 0
var game_time = 0
var decision_time = 0
var vehicle 
var average_decision_time = 0
var cities_to_num = {}


func _city_area_detection(id):
	print("Entered " + id)
	Global.last_city = id
	
	if id == Global.level_objective:
		Global.won = true
		#_load_next_level()
		#correct_targets += 1
		#_calculate_tolerance_ambiguity()
		Global.won = false
		#print("TUT ENDED")
		get_tree().change_scene_to_file("res://Scenes/prototipo_mapa_final_normal.tscn")
	else:
		incorrect_targets += 1		
		_calculate_tolerance_ambiguity()

func _load_level(result, response_code, headers, body):
	'''
	var json = JSON.new()
	var response
	#Obtains the json of the map, via http and in case of error by local file
	if response_code != 200:
		print("Local read")
		var file = FileAccess.open("res://Scripts/mapa.json", FileAccess.READ)
		var content = file.get_as_text()
		json.parse(content)
		response = json.get_data()
	else:
		print("Read through http")
		json.parse(body.get_string_from_utf8())
		response = json.get_data()
	'''
	Global.last_city = Global.start_level
	#Change signs and initiate directions
	print("Current level " + str(Global.current_level_number))
	Global.start_level = "Troya" #response.niveles[str(Global.current_level_number)]['inicia:'] 
	Global.level_objective = "Lima" #response.niveles[str(Global.current_level_number)]['objetivo']
	
	cities_to_num = {"York" : "1", "Lima" : "2", "Troya" : "3"}
	var tutorial_cities = ["York", "Lima", "Troya"]
	#Load the city names and link their respective 3D areas
	for i in range(1,3):	
		cities_to_num[tutorial_cities[i - 1]] = str(i)
		get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Letrero_aereo/Label3D").text = tutorial_cities[i - 1]
		get_node("Ciudades/Ciudad_" + str(i) + "/LowPolyCITY/Area3D").body_entered.connect(func(body):_city_area_detection(tutorial_cities[i - 1]))
		#Recorre los letreros
		
	'''
	for intersection in range(1,14):	
		get_node("Tunnels/intersection_tunnel"+str(intersection)+"/Area3D_left").body_entered.connect(_intersection_area)
		get_node("Tunnels/intersection_tunnel"+str(intersection)+"/Area3D_right").body_entered.connect(_intersection_area)
		get_node("Tunnels/intersection_tunnel"+str(intersection)+"/Area3D_center").body_entered.connect(_intersection_area)
		for sign in range(1,4):
			#Left sign
			get_node("Tunnels/intersection_tunnel"+str(intersection)+"/doble_signs_izq/left_signs/Label3D"+str(sign)).text = response.niveles[str(Global.current_level_number)]["intersecciones"][str(intersection)]["seniales_izq"]["izquierda"][str(sign)]
			get_node("Tunnels/intersection_tunnel"+str(intersection)+"/doble_signs_izq/right_signs/Label3D"+str(sign)).text = response.niveles[str(Global.current_level_number)]["intersecciones"][str(intersection)]["seniales_izq"]["derecha"][str(sign)]
			#Front sign
			get_node("Tunnels/intersection_tunnel"+str(intersection)+"/doble_signs_der/left_signs/Label3D"+str(sign)).text = response.niveles[str(Global.current_level_number)]["intersecciones"][str(intersection)]["seniales_der"]["izquierda"][str(sign)]
			get_node("Tunnels/intersection_tunnel"+str(intersection)+"/doble_signs_der/right_signs/Label3D"+str(sign)).text = response.niveles[str(Global.current_level_number)]["intersecciones"][str(intersection)]["seniales_der"]["derecha"][str(sign)]
			#Right sign
			get_node("Tunnels/intersection_tunnel"+str(intersection)+"/doble_signs_med/left_signs/Label3D"+str(sign)).text = response.niveles[str(Global.current_level_number)]["intersecciones"][str(intersection)]["seniales_med"]["izquierda"][str(sign)]
			get_node("Tunnels/intersection_tunnel"+str(intersection)+"/doble_signs_med/right_signs/Label3D"+str(sign)).text = response.niveles[str(Global.current_level_number)]["intersecciones"][str(intersection)]["seniales_med"]["derecha"][str(sign)]
	'''
	print("Map updated correctly")
	
	#Repositioning the vehicle to the starting area after restarting
	$player_car.set_global_position(get_node("Ciudades/Ciudad_" + str(cities_to_num[Global.start_level]) + "/Iniciador").get_global_position())
	print("car position: " + str($player_car.get_global_position()))
	
	#Reset the car's speed to zero
	var car = $player_car as VehicleBody3D
	car.linear_velocity = Vector3(0, 0, 0)
	$player_car.set_global_rotation(Vector3(0, 0, 0))
	
	if (Global.current_level_number > 1): 
		$Textbox._print_message("Tutorial!")
		#$Textbox._print_message("Good job, you passed the level! Your next goal is: " + Global.level_objective)
		#$Textboc/UIPausa/Label/Label.text = "Your next goal is: " + Global.level_objective
	
func _intersection_area(body):
	if Global.has_entered == false:
		print("START COUNTER DECISION")		
		start_decision_time = Time.get_ticks_msec()
		Global.has_entered = true
	else:
		print("STOP COUNTER DECISION")
		var decision_time = Time.get_ticks_msec() - start_decision_time
		total_decision_time += start_decision_time
		number_decisions += 1
		Global.has_entered = false
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	#_developer_view(1,false) #Uncomment to see preview
	add_child(http_request)
	http_request.request_completed.connect(self._load_level)
	_http_request("https://luisanyel.000webhostapp.com/mapa.json")
	
	
func _http_request(url):
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _developer_view(level, visible_):
	var json = JSON.new()
	var response
	
	var file = FileAccess.open("res://Scripts/mapa.json", FileAccess.READ)
	var content = file.get_as_text()
	json.parse(content)
	response = json.get_data()
	#print(response)
	#Upload name cities and Link 3D areas of the cities
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
		
#current city
func _restart():
	if Global.restart == true:
		#reposition the vehicle to the start point after a restart
		$player_car.set_global_position(get_node("Ciudades/Ciudad_" + str(cities_to_num[Global.last_city]) + "/Iniciador").get_global_position())
		Global.restart = false
		#Reset the car's speed to zero
		var car = $player_car as VehicleBody3D
		car.linear_velocity = Vector3(0, 0, 0)
		$player_car.set_global_rotation(Vector3(0, 0, 0))
		
		
func _finish():
	if Global.finished == true:
		print("Calculation finished")
		Global.tolerance = _calculate_tolerance_ambiguity()
		print("Tolerance: " + str(Global.tolerance))
		
func _process(delta):
	_restart()
	_finish()
	
	
func _load_next_level():
	Global.won = false
	if Global.current_level_number <= 4:
		Global.current_level_number += 1
		_http_request("https://luisanyel.000webhostapp.com/mapa.json")
	
		

func _load_AI(won):
	if won:		
		correct_targets += 1
		_calculate_tolerance_ambiguity()
	else:		
		incorrect_targets += 1		
		_calculate_tolerance_ambiguity()
		
		
func _calculate_tolerance_ambiguity():	
	if correct_targets > 0 || incorrect_targets > 0:
		average_speed = 10 #vehicle.average_speed/20  #normalized over the expected maximum speed
		var ambiguity_tolerance = (correct_targets/(correct_targets + incorrect_targets))
		ambiguity_tolerance += average_speed/total_time		
		_save_ambiguity_tolerance()		
		return ambiguity_tolerance		
	else:		
		return null
		
func _save_ambiguity_tolerance():		
	var data = ConfigFile.new()
	var result = data.load("historialCalculosAmbiguedad.cfg")	
	if result == ERR_FILE_NOT_FOUND:		
		data = ConfigFile.new()  #Create a new configuration file         
	# Create a unique section for each game
	var current_time = Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system()
	var session = "partida_" + current_time
	data.set_value(session, "velocidadPromedio", average_speed)	
	data.set_value(session, "tiempoTotal", total_time)
	data.set_value(session, "destinosCorrectos", correct_targets)
	data.set_value(session, "destinosIncorrectos", incorrect_targets)
	# Save the data to the archive
	data.save("historialCalculosAmbiguedad.cfg")	
	#_read_ambiguity_calculation()	
	
func _read_ambiguity_calculation():	
	var data = ConfigFile.new()
	var result = data.load("historialCalculosAmbiguedad.cfg")
	
	if result == OK:  # If the file was successfully uploaded
		# Gets a list of all the sections in the file
		var sessions = data.get_sections()
		var json_array = []
		
		# Go through each section
		for session in sessions:
			var average_speed = data.get_value(session, "velocidadPromedio")
			var total_time = data.get_value(session, "tiempoTotal")
			var correct_targets = data.get_value(session, "destinosCorrectos")
			var incorrect_targets = data.get_value(session, "destinosIncorrectos")
			
			# Create a dictionary for each section
			var dict = {
				"timestamp": session.replace("partida_", ""),
				"velocidadPromedio": average_speed,
				"tiempoTotal": total_time,
				"destinosCorrectos": correct_targets,
				"destinosIncorrectos": incorrect_targets
			}
			
			# Add the dictionary to the array
			json_array.append(dict)
		
		# Convert the array to JSON
		var json_text = JSON.stringify(json_array)			
		#_send_data(json_text, "http://localhost:5000/prediccionw")			
		var headers = ["Content-Type: application/json"]
		$HTTPRequest.request("http://localhost:5000/prediccion", headers, HTTPClient.METHOD_POST, json_text)		
		
func _send_data(json_text: String, url: String):
	# Create a new HTTPRequest instance
	var http_request_linear_regression = HTTPRequest.new()	
	# Add the HTTPRequest to the scene tree
	self.add_child(http_request_linear_regression)	
	# Connect the request_completed signal to a function
	http_request_linear_regression.request_completed.connect( self._on_request_completed)
	# Prepare application details
	var headers = ["Content-Type: application/json"]
	var body = PackedByteArray(Array(json_text.to_utf8_buffer()))	
	# Make the POST request
	var error = http_request_linear_regression.request(url, headers, HTTPClient.METHOD_POST, body)	
	if error == OK:
		print("Request Successfully Submitted.")
	else:
		print("Error sending request: ", error)
		
		
func _on_request_completed(result, response_code, headers, body):
	print("HTTP Response Code: ", response_code)
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("DEBUG REGRESSION RESPONSE: ",json)

