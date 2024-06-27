extends Panel

@onready var avanzar = $avanzar
@onready var frenar = $frenar
@onready var volante = $volante
@onready var movimiento = $movimiento

var speed = Vector2(50,0)
var current_label = null
var fade_out_duration = 1.0  # Duración del efecto de desvanecimiento en segundos
var fade_out_timer = 0.0  # Temporizador para el efecto de desvanecimiento
var fading_out = false  # Indica si la etiqueta actual está desvaneciéndose

func _ready():
	avanzar.visible = true
	frenar.visible = false
	volante.visible = false
	movimiento.visible = false
	current_label = avanzar

func _process(delta):
	if current_label.position.x < get_viewport().size.x / 100:
		current_label.position += speed * delta
	else:
		if not fading_out:
			fading_out = true
			fade_out_timer = 0.0  # Reinicia el temporizador de desvanecimiento cuando se cambia de etiqueta
		else:
			if fade_out_timer < fade_out_duration:
				fade_out_timer += delta
				var t = fade_out_timer / fade_out_duration
				current_label.modulate.a = 1.0 - t  # Cambia la transparencia de la etiqueta actual
			else:
				current_label.visible = false
				fading_out = false
				speed = Vector2(50, 0)
				if current_label == avanzar:
					current_label = frenar
					current_label.visible = true
					get_tree().create_timer(0.001).timeout.connect(self._on_avanzar_timeout)
				elif current_label == frenar:
					current_label = volante
					current_label.visible = true
					get_tree().create_timer(5.0).timeout.connect(self._on_frenar_timeout)
				elif current_label == volante:
					current_label = movimiento
					current_label.visible = true
					get_tree().create_timer(5.0).timeout.connect(self._on_volante_timeout)

func _on_avanzar_timeout():
	avanzar.visible = false

func _on_frenar_timeout():
	frenar.visible = false

func _on_volante_timeout():
	volante.visible = false

func _on_movimiento_timeout():
	movimiento.visible = false

