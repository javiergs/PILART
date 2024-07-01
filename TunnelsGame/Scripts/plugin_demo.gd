
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var busqueda = find_children('PluginDemo')
	if busqueda != null:
		print("Se encontro")
	else:
		print("No se encontro")		
	"""
	var busqueda = find_children ('MeshInstance3D')
	if busqueda != null:
		print("Se encontro")
		print(busqueda)
		print(busqueda.size())
		if busqueda.size() > 1:
			print("mas")
			var last = busqueda[busqueda.size()-1]
			last.queue_free()
			await last.tree_exited
			print(get_tree_string_pretty())
	else:
		print("No se encontro")		
	"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
