extends Node

# Configuración de dificultad mejorada con curvas más balanceadas
var current_level := 1
var score_per_level := 1000 # Puntos necesarios para subir de nivel

# Probabilidades de plataformas especiales
var disappear_platform_chance := 0.1
var moving_platform_chance := 0.1
var spring_platform_chance := 0.0 # Para power-ups

# Velocidad y movimiento
var platform_base_speed := 0.5
var platform_speed_multiplier := 1.0

# Distancias entre plataformas (afecta dificultad)
var min_distance_between_platforms := 180
var max_distance_between_platforms := 240

# Nuevas variables para power-ups
var powerup_spawn_chance := 0.0 

func update_difficulty(score: int):
	# Calcular nivel actual
	var previous_level = current_level
	current_level = 1 + int(float(score) / score_per_level)
	
	# Si subió de nivel, hacer una transición suave
	if current_level > previous_level:
		print("¡Nivel ", str(current_level) + " alcanzado!")

	# Aumentar probabilidad de plataformas que desaparecen gradualmente
	disappear_platform_chance = clamp(0.1 + current_level * 0.03, 0.1, 0.45)

	# Aumentar plataformas móviles más gradualmente
	moving_platform_chance = clamp(0.1 + current_level * 0.04, 0.1, 0.5)

	# Velocidad de plataformas móviles aumenta con el nivel
	platform_speed_multiplier = 1.0 + (current_level -1) * 0.15

	# Reducir distancia entre plataformas gradualmente (más dificil)
	min_distance_between_platforms = clamp(180 + current_level * 5, 180, 280)
	max_distance_between_platforms = clamp(240 + current_level * 8, 240, 300)

	# Aumentar aparición de power-ups con el nivel
	powerup_spawn_chance = clamp(0.02 + current_level * 0.01, 0.02, 0.15)

	# Plataformas especiales (trampolines) aparecen despueés del nivel 3
	if current_level >= 3:
		spring_platform_chance = clamp(0.05 + (current_level -3) * 0.02, 0.05, 0.2)
	
func reset() -> void:
	""" Reinicia la dificultad a los valores iniciales"""
	current_level = 1
	disappear_platform_chance = 0.1
	moving_platform_chance = 0.1
	spring_platform_chance = 0.0
	platform_speed_multiplier = 1.0
	min_distance_between_platforms = 180
	max_distance_between_platforms = 240
	powerup_spawn_chance = 0.0

func get_difficulty_info() -> Dictionary:
	"""Retorna información sobre la dificultad actual"""
	return {
		"level": current_level,
		"disappear_platform_chance": disappear_platform_chance,
		"moving_platform_chance": moving_platform_chance,
		"spring_platform_chance": spring_platform_chance,
		"platform_speed_multiplier": platform_speed_multiplier,
		"min_distance_between_platforms": min_distance_between_platforms,
		"max_distance_between_platforms": max_distance_between_platforms,
		"powerup_spawn_chance": powerup_spawn_chance
	}
