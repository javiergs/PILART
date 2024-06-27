extends VehicleBody3D

var draggin = false
var control
var volante 
var rotacion_inicial 
var max_rotacion = 145  # El máximo ángulo de rotación permitido
# Called when the node enters the scene tree for the first time.
func _ready():
	print("lo que sea")
	#volante = get_node("volante")
	volante = get_parent().get_node("Wheel/InteractableHinge") as XRToolsInteractableHinge
	rotacion_inicial = volante.rotate_z
	volante.hinge_moved.connect(_print_move)
	control = get_owner().get_node("playerXR").get_node("left_hand") as XRController3D
	control.input_float_changed.connect(_print_float)
	

func _print_move(angle):
	steering = -angle / 200.0
	print(str(angle))
	
func _print_float(action,value):
	if action == "trigger":
		engine_force = clamp(value,0,100) * 100
		print(str(action) + str(value))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	pass
	#steering = Input.get_axis("right", "left") * .4
	#steering = -volante.rotation_degrees.z / 200.0
	#engine_force = Input.get_axis("back", "forward") * 100
	
	
	
	
