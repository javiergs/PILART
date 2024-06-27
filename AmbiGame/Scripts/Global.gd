extends Node

#var cronometro_scene = preload("../UI/cronometro.tscn")
#var cronometro = null 

var objetivo_nivel : String
var inicio_nivel : String
var ultima_ciudad : String
var numero_nivel_actual = 1
var current_state = State.INACTIVE
var habia_entrado = false
var reiniciar = false
var is_paused: bool = false
var termino: bool = false
var tolerancia = 0.7245

enum State{
	 READY,
	 READING,
	 FINISHED,
	 INACTIVE
}

var gano = false	
var perdio = false

func _ready():
	pass
	#numero_nivel_actual = 1
	#cronometro = cronometro_scene.instantiate()
	#get_tree().root.add_child(cronometro)


