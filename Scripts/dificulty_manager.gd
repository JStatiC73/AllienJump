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
var min_distance_between_platforms := 180.0
var max_distance_between_platforms := 240.0

# Límites de salto del jugador
const PLAYER_MAX_JUMP_HEIGHT := 350.0 # Altura máxima alcanzable por el jugador
const PLAYER_MAX_HORIZONTAL_REACH := 250.0 # Distancia horizontal máxima

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
	disappear_platform_chance = clamp(0.05 + current_level * 0.03, 0.05, 0.4)

	# Aumentar plataformas móviles más gradualmente
	moving_platform_chance = clamp(0.1 + current_level * 0.04, 0.05, 0.45)

	# Velocidad de plataformas móviles aumenta con el nivel
	# En nivel 1: 1.0, nivel 5: 1.2, nivel 10: 1.45
	platform_speed_multiplier = 1.0 + (current_level -1) * 0.05

	# AUMENTAR distancia entre plataformas (más dificil)
	# Las plataformas se alejan pero nunca superan el alcance del jugador
	# Nivel1: 180-240
	# Nivel 5: 212 - 272
	# Nivel 10: 244-304
	# Nivel 15: 260-320 (Límite)
	var distance_increase = (current_level - 1) * 8.0
	min_distance_between_platforms = clamp(180.0 + distance_increase, 180.0, 260.0)
	max_distance_between_platforms = clamp(240.0 + distance_increase, 240.0, 320.0)

	# Asegurar que nunca supere el alcance del jugador
	if max_distance_between_platforms > PLAYER_MAX_JUMP_HEIGHT:
		max_distance_between_platforms = PLAYER_MAX_JUMP_HEIGHT
		min_distance_between_platforms = PLAYER_MAX_JUMP_HEIGHT - 60.0

	# Aumentar aparición de power-ups con el nivel
	powerup_spawn_chance = clamp(0.02 + current_level * 0.01, 0.02, 0.12)

	# Plataformas especiales (trampolines) aparecen despueés del nivel 3
	if current_level >= 3:
		spring_platform_chance = clamp(0.03 + (current_level -3) * 0.01, 0.03, 0.15)
	
func reset() -> void:
	""" Reinicia la dificultad a los valores iniciales"""
	current_level = 1
	disappear_platform_chance = 0.1
	moving_platform_chance = 0.1
	spring_platform_chance = 0.0
	platform_speed_multiplier = 1.0
	min_distance_between_platforms = 180.0
	max_distance_between_platforms = 240.0
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

func get_platform_movement_speed() -> float:
	"""Retorna la velocidad final para plataformas móviles"""
	return platform_base_speed * platform_speed_multiplier