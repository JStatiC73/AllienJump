extends Node2D

@onready var platformParent = $PlatformParent
var platform_scene = preload("res://Scenes/platform.tscn")
# var powerup_scene = preload("res://Scenes/powerup.tscn")

var start_platform_y
var level_size = 1
var generated_platform_count = 0
var viewport_size

var player: Player = null
var max_x_position
var player_score = 0

# Variables para generación más inteligente
var last_platform_y := 0.0
var last_platform_x := 0.0
var platforms_since_safe := 0  # Contador para garantizar plataformas seguras

# Constantes de diseño de nivel
const PLATFORM_WIDTH := 135.0
const PLATFORM_HEIGHT := 30.0
const MIN_VERTICAL_SPACING := 100.0 # Espacio mínimo para evitar superposición

func _ready():
	viewport_size = get_viewport_rect().size
	generated_platform_count = 0
	start_platform_y = viewport_size.y - 215

func start_generation():
	generate_level(start_platform_y, true)

func _process(_delta):
	if(player):
		var player_y_possition = player.global_position.y
		var end_of_level_pos = start_platform_y - (generated_platform_count * get_average_distance())
		var threshold = end_of_level_pos + (get_average_distance() * 4)
		if(player_y_possition <= threshold):
			generate_level(end_of_level_pos, false)

func get_average_distance() -> float:
	"""Obtiene la distancia promedio entre plataformas según dificultad"""
	return (DificultyManager.min_distance_between_platforms + 
			DificultyManager.max_distance_between_platforms) / 2.0

func setup(_player: Player):
	if(_player):
		player = _player

func create_platform(location: Vector2):
	var platform_instance = platform_scene.instantiate()
	platform_instance.global_position = location
	platformParent.add_child(platform_instance)
	return platform_instance

func generate_level(start_y: float, generate_ground: bool):
	DificultyManager.update_difficulty(player_score)

	#region Generate the ground
	if(generate_ground):
		var platform_y_position = (viewport_size.y - PLATFORM_HEIGHT)
		var ground_layer_platform_count = int(viewport_size.x / PLATFORM_WIDTH) + 1

		for i in range(ground_layer_platform_count):
			var ground_location = Vector2((i * PLATFORM_WIDTH), platform_y_position)
			var platform_instance = create_platform(ground_location)
			platform_instance.set_type("normal")

		last_platform_y = platform_y_position
		last_platform_x = viewport_size.x / 2.0
	#endregion

	#region Level generate
	max_x_position = viewport_size.x - PLATFORM_WIDTH
	var current_y = start_y

	for i in range(level_size):
		# Usar distancias dinámicas del DifficultyManager
		var y_distance = randf_range(
			DificultyManager.min_distance_between_platforms,
			DificultyManager.max_distance_between_platforms
		)

		# Asegurar espacio mínimo vertical para evitar superposición
		y_distance = max(y_distance, MIN_VERTICAL_SPACING)

		var location: Vector2
		current_y -= y_distance
		location.y = current_y

		# Generación mas inteligente de posición x
		location.x = generate_smart_x_position()

		# Determinar tipo de plataforma
		var platform_type = determine_platform_type()

		var platform_instance = create_platform(location)
		platform_instance.set_type(platform_type)

		if platform_type == "moving":
			platform_instance.set_screen_width(viewport_size.x, PLATFORM_WIDTH)
			platform_instance.set_movement_speed(
				DificultyManager.get_platform_movement_speed()
			)

		# Actualizar último estado
		last_platform_y = location.y
		last_platform_x = location.x
		generated_platform_count += 1

		# TODO: Generar power-ups ocasionalmente
		# if randf() < DificultyManager.powerup_spawn_chance:
		#	spawn_powerup(location)
	#endregion

func generate_smart_x_position() -> float:
	"""Genera posiciones X que garantizan que sean alcanzables"""
	var max_horizontal_jump = DificultyManager.PLAYER_MAX_HORIZONTAL_REACH  # Distancia máxima horizontal que el jugador puede saltar
	
	# Asegurar que no esté demasiado lejos horizontalmente
	var min_x = max(0, last_platform_x - max_horizontal_jump)
	var max_x = min(max_x_position, last_platform_x + max_horizontal_jump)

	# Si el rango es demasiado pequeño, expandirlo
	if max_x - min_x < PLATFORM_WIDTH * 2:
		min_x = 0
		max_x = max_x_position
	
	return randf_range(min_x, max_x)

func determine_platform_type() -> String:
	"""Determina el tipo de plataforma basado en probabilidades y lógica de juego"""
	
	# Cada 5 plataformas, garantizar una normal para no hacer el juego imposible
	platforms_since_safe += 1
	if platforms_since_safe >= 4:
		platforms_since_safe = 0
		return "normal"
	
	var rand_val = randf()
	var cumulative_chance = 0.0
	
	# Plataformas que desaparecen
	cumulative_chance += DificultyManager.disappear_platform_chance
	if rand_val < cumulative_chance:
		return "disappear"
	
	# Plataformas móviles
	cumulative_chance += DificultyManager.moving_platform_chance
	if rand_val < cumulative_chance:
		return "moving"
	
	# Plataformas trampolín (spring) - para el futuro
	cumulative_chance += DificultyManager.spring_platform_chance
	if rand_val < cumulative_chance:
		return "spring"
	
	return "normal"

func set_player_score(_player_score):
	player_score = _player_score

func reset_level():
	for platform in platformParent.get_children():
		platform.queue_free()

	generated_platform_count = 0
	platforms_since_safe = 0
	last_platform_y = 0.0
	last_platform_x = 0.0
	DificultyManager.reset()
