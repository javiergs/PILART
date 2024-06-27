extends VehicleBody3D

#variables velocidad promedio
var distancia_total = 0.0
var tiempo_total = 0.0
var velocidad_promedio 
var posicion_inicial 


var draggin = false
var volante 
var rotacion_inicial 
var max_rotacion = 145  # El máximo ángulo de rotación permitido
# Called when the node enters the scene tree for the first time.
func _ready():
	volante = get_node("volante")
	rotacion_inicial = volante.rotate_z
	posicion_inicial = self.global_transform.origin
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
	
func _physics_process(delta):
	#steering = Input.get_axis("right", "left") * .4
	"""
	if(draggin):
		steering = -volante.rotation_degrees.z / 200.0
	else:
		steering = 0"""
	steering = lerp(steering, Input.get_axis("right", "left") * .2, 5 * delta)
	var porcentaje = (Input.get_axis("back", "forward") - (-1)) / (1 - (-1))
	engine_force = lerp(-1000, 1000, porcentaje)	
	#engine_force = Input.get_axis("back", "forward") * 100
	
	#calculo velocidad promedio
	var posicion_actual = self.global_transform.origin
	var distancia = posicion_inicial.distance_to(posicion_actual)

	distancia_total += distancia
	tiempo_total += delta

	if tiempo_total != 0:
		velocidad_promedio = distancia_total / tiempo_total  # Velocidad = Distancia / Tiempo

	#print("La velocidad promedio es: ", velocidad_promedio, " unidades por segundo")

	# Actualizar para el próximo cálculo
	posicion_inicial = posicion_actual

	
func _on_volante_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("el jugador hizo clic en el colante")
		
func _input(event):
	if(event is InputEventMouseButton):
		if event.is_pressed():
			draggin = true
		else:			
			draggin = false
			volante.rotation_degrees.z = 0
	elif event is InputEventMouseMotion and draggin:
		var rotacion = volante.rotation_degrees.z + deg_to_rad(event.relative.x)
		volante.rotation_degrees.z = clamp(rotacion, -max_rotacion, max_rotacion)
		volante.rotate_z(deg_to_rad(event.relative.x))	
		# El jugador está arrastrando el mouse, gira el volante
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.keycode == KEY_B and key_event.pressed:
			Global.is_paused = true
