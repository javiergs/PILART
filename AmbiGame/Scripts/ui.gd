extends CanvasLayer

class_name  ui 
signal game_started

@onready var pantalla_previa = $pantalla_previa
@onready var pantalla_instrucciones = $pantalla_instrucciones

@onready var cronometro = Global.cronometro

#Hacerlo compatible con XR 
#Usar ViewPort2Din3D

#Definir instrucciones e imprimirlas 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#Al presionar boton Inicio
func _on_iniciar_pressed():
	#cronometro.start()
	game_started.emit()
	pantalla_previa.visible = false 
	

#Al precionar boton Salir
func _on_salir_pressed():
	get_tree().quit()

#Al presionar boton de Instrucciones 
func _on_instrucciones_pressed():
	pantalla_instrucciones.visible = true
	pantalla_previa.visible = false
	

#Boton salir de menu instrucciones
func _on_salir_instru_pressed():
	pantalla_instrucciones.visible = false
	pantalla_previa.visible = true
	
