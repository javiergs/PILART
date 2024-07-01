@tool
extends EditorPlugin
 
#------------------MAIN PANEL---------------------------------
const MainPanel = preload("res://addons/realtimecollaboration/mainscreen/main_screen.tscn")

var main_panel_instance
 
func _enter_tree():
	# Initialization of the plugin goes here.
	#multiplayer.multiplayer_peer = null
	
	# Init main panel
	main_panel_instance = MainPanel.instantiate()
	
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)
	
	#Connect signal on change
	get_undo_redo().history_changed.connect(func():main_panel_instance.scene_update.emit())
	

func _exit_tree():
	# Clean-up of the plugin goes here.
	if main_panel_instance:
		main_panel_instance.queue_free()
	
	
func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Main Screen Plugin"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
	
	
	
	
"""
# Get name of editor current scene 
	var player_scene = get_editor_interface().get_edited_scene_root()
	if player_scene != null:
		print(player_scene.scene_file_path.get_file())	
	else:
		print("La escena es nula")	


INIT VARIABLES
# A class member to hold the dock during the plugin life cycle.
var dock

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
const AUTOLOAD_NAME = "SomeAutoload"
"""



"""
	ENTER TREE
	Create custom node
	# Add the new type with a name, a parent type, a script and an icon. (New node)
	add_custom_type("MyButton", "Button", preload("my_button.gd"), preload("res://icon.svg"))
	
	Create autoload
	# The autoload can be a scene or script file.
	#add_autoload_singleton(AUTOLOAD_NAME, "res://Scenes/MapaPrincipal.tscn")
	
	Create a dock
	# Load the dock scene and instantiate it.
	dock = preload("res://addons/realtimecollaboration/my_dock.tscn").instantiate()
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	# Note that LEFT_UL means the left of the editor, upper-left dock.
	"""
	
"""
	EXITTREE
	# Always remember to remove it from the engine when deactivated. (New node)
	remove_custom_type("MyButton")
	
	
	#Remove autoload
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
	"""
