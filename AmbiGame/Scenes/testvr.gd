extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var interface = XRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		# turn the main viewport into an ARVR viewport:
		get_viewport().use_xr = true

		# turn off v-sync
		#OS.vsync_enabled = false

		# put our physics in sync with our expected frame rate:
		#Engine.iterations_per_second= 90


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
