extends Area2D

class_name	Platform

@onready var sprite = $Sprite2D  
@onready var collision_shape = $CollisionShape2D

var platform_type = "normal"
var base_position: Vector2
var amplitude: float = 100.0
var movement_speed: float = 0.5
var platform_width: float = 135.0
var screen_width: float = 0.0

# Variables para plataformas que desaparecen
var is_disappearing := false
var disappear_timer := 0.0
var disappear_delay := 0.3  # Segundos antes de desaparecer

# Variables para efectos visuales
var original_modulate: Color
var time_offset: float = 0.0

func _ready():
	base_position = position
	original_modulate = modulate
	time_offset = randf() * 1000.0
	update_visual_by_type()

func set_screen_width(width: float, _platform_width: float):
	platform_width = _platform_width
	screen_width = width
	amplitude = min((screen_width - platform_width) * 0.3, 150.0)

func set_type(type:String):
	platform_type = type
	update_visual_by_type()

func update_visual_by_type():
	"""Actualiza el aspecto visual según el tipo de plataforma"""
	if not sprite:
		return

	match platform_type:
		"disappear":
			modulate = Color(1.0, 0.7, 0.7)  # Tono rojizo
		"moving":
			modulate = Color(0.7, 0.7, 1.0)  # Tono azulado
		"spring":
			modulate = Color(0.7, 1.0, 0.7)  # Tono verdoso
		"normal":
			modulate = Color(1.0, 1.0, 1.0)  # Normal

func set_movement_speed(speed: int):
	movement_speed = speed

func _physics_process(delta):
	if platform_type == "moving":
		# Movimiento sinusoidal horizontal
		var time_factor = (Time.get_ticks_msec() + time_offset) * 0.001 # Convertir a segundos
		position.x = base_position.x + amplitude * sin(time_factor * movement_speed)
		position.x = clampf(position.x, 0.0, screen_width - platform_width)
	
	# Manejo de desaparición gradual
	if is_disappearing:
		disappear_timer += delta
		# Efecto visual de parpadeo
		modulate.a = 1.0 - (disappear_timer / disappear_delay)
		
		if disappear_timer >= disappear_delay:
			queue_free()

func _on_body_entered(body):
	if body is Player:
		# Solo rebotar si está cayendo
		if body.velocity.y > 0:
			body.jump()
			
			# Efecto específico según tipo
			match platform_type:
				"disappear":
					start_disappear()
				"spring":
					# Salto extra alto (implementar después)
					body.velocity.y *= 1.5
				"moving":
					# Feedback visual de rebote
					var tween = create_tween()
					tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.1)
					tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func start_disappear():
	"""Inicia el proceso de desaparición de la plataforma"""
	if not is_disappearing:
		is_disappearing = true
		disappear_timer = 0.0
		# Desactivar colisión inmediatamente para evitar rebotes múltiples
		collision_shape.set_deferred("disabled", true)
