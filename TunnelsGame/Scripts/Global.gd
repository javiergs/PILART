extends Node

#var cronometro_scene = preload("../UI/cronometro.tscn")
#var cronometro = null 

var objective_level : String
var start_level : String
var last_city : String
var current_level_number = 1
var current_state = State.INACTIVE
var has_entered = false
var restart = false
var is_paused: bool = false
var finished: bool = false
var tolerance = 0.7245

enum State{
	 READY,
	 READING,
	 FINISHED,
	 INACTIVE
}

var won = false	
var lost = false

func _ready():
	pass
	#numero_nivel_actual = 1
	#cronometro = cronometro_scene.instantiate()
	#get_tree().root.add_child(cronometro)


