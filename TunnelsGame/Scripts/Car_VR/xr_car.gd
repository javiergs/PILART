extends VehicleBody3D

@onready var player: XROrigin3D = get_node("playerXR")
@onready var left_controller: XRController3D = player.get_node("left_hand")
@onready var right_controller: XRController3D = player.get_node("right_hand")
@onready var steering_mesh: XRToolsInteractableHinge = get_node("steering_wheel/interactable")

var init_rotation

# Called when the node enters the scene tree for the first time.
func _ready():	
	#Init XR
	var interface = XRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		print("OpenXR initialized successfully")
		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		# turn the main viewport into an ARVR viewport:
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	#Other Init
	init_rotation = steering_mesh.rotate_z
	
	#Signals Init
	steering_mesh.hinge_moved.connect(_direccion_volante)
	left_controller.input_float_changed.connect(_frenar)
	right_controller.input_float_changed.connect(_acelerar)
	right_controller.button_pressed.connect(_botones_derecho)

	
func _botones_derecho(button):
	if button == "by_button":
		Global.is_paused = true
		$playerXR/right_hand/FunctionPointer.enabled = true
		#$playerXR/right_hand/FunctionPointer.show_laser = 0
		#var h = $playerXR/right_hand/FuctionPointer as XRToolsFunctionPointer
		#h.show_laser


func _direccion_volante(angle):
	steering = angle / 200.0
	
	
func _frenar(action,value):
	if action == "trigger":
		var porcentaje = (value - 0) / (1 - 0)
		engine_force = lerp(-3400, -4000, porcentaje)
		#print("Acelerador: " + str(engine_force))
		#print("Velocidad: " + str(round(linear_velocity.length())))
		
		
func _acelerar(action,value):
	if action == "trigger":
		var porcentaje = (value - 0) / (1 - 0)
		engine_force = lerp(3400, 4500, porcentaje) #3400-4500
		#print("Acelerador: " + str(engine_force))
		print("Velocidad y: " + str(round(linear_velocity.y)))
		print("Velocidad x: " + str(round(linear_velocity.x)))
		print("Velocidad y: " + str(round(linear_velocity.z)))
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.is_paused == false:
		$playerXR/right_hand/FunctionPointer.enabled = false
	if (linear_velocity.x * -1) > 10:
		if linear_velocity.x < 0:
			linear_velocity.x = -10
		else:
			linear_velocity.x = 10 
	if (linear_velocity.y * -1) > 10:
		if linear_velocity.y < 0:
			linear_velocity.y = -10
		else:
			linear_velocity.y = 10 




"""
#intento de mover
var movement = left_controller.get_node("MovementDirect") as XRToolsMovementDirect
var player_body = player.get_node("PlayerBody") as XRToolsPlayerBody
movement.enabled = false
#player_body.enabled = false
var point = get_node("point_camera")
#player.reparent(point, false)
player.global_transform = point.global_transform
print(str(button))
"""

