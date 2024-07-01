extends Panel

var time: float = 0.0 
var minutos: int = 0
var segundos: int = 0
var mseg: int = 0

var running: bool = false  # Indica si el cronómetro está en marcha
var started: bool = false
"""
func _ready():
	get_node("/root/MapaPrincipal").fin_del_juego.connect(self.stop)
"""


func _process(delta) -> void:
	if running and started:
		time += delta
		mseg = fmod(time, 1) * 100
		segundos = fmod(time, 60)
		minutos = fmod(time, 3600) / 60
	
		$Minutos.text = "%02d:" % minutos
		$Segundos.text = "%02d." % segundos
		$Miliseg.text = "%03d" % mseg
	
func start():
	running = true
	started = true


func stop() -> void:
	running = false 
	#Global.tiempo_transcurrido = formateo_tiempo()

	
func formateo_tiempo() -> String:
	return "%02d:%02d.%03d" % [minutos, segundos, mseg]
	



#Boton prueba detener y almacenar tiempo transcurrido
func _on_button_pressed():
	stop()
	Global.tiempo_transcurrido = formateo_tiempo()
	#$tiempo_trans.text = Global.tiempo_transcurrido
	#$tiempo_trans.text = formateo_tiempo() #muestra tiempo pausado en label
	print("El tiempo se detuvo")
