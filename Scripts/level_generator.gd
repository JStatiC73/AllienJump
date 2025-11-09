extends Node2D

@onready var platformParent = $PlatformParent
var platform_scene = preload("res://Scenes/platform.tscn")

var start_platform_y
var y_distance_between_platforms = 215
var level_size = 25
var generated_platform_count = 0
var viewport_size

var player: Player = null
var max_x_position
var player_score = 0

func _ready():
	viewport_size = get_viewport_rect().size
	generated_platform_count = 0
	start_platform_y = viewport_size.y - (y_distance_between_platforms)

func start_generation():
	generate_level(start_platform_y, true)

func _process(_delta):
	if(player):
		var player_y_possition = player.global_position.y
		var end_of_level_pos = start_platform_y - (generated_platform_count * y_distance_between_platforms)
		var threshold = end_of_level_pos + (y_distance_between_platforms * 4)
		if(player_y_possition <= threshold):
			generate_level(end_of_level_pos, false)

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
	var platform_width = 135
	var platform_height = 30
	#region Generate the ground
	if(generate_ground):
		var platform_y_position = (viewport_size.y - platform_height)

		var ground_layer_platform_count = (viewport_size.x / platform_width) + 1

		for i in range(ground_layer_platform_count):
			var ground_location = Vector2((i * platform_width), platform_y_position)
			create_platform(ground_location)
	#endregion

	#region Level generate

	max_x_position = viewport_size.x - platform_width
	for i in range(level_size):
		var location: Vector2
		location.x = randf_range(0.0, max_x_position)
		location.y = start_y - (i * y_distance_between_platforms)

		var platform_type = "normal"
		var rand_val = randf()
		if rand_val < DificultyManager.disappear_platform_chance:
			platform_type = "disappear"
		elif rand_val < DificultyManager.disappear_platform_chance + DificultyManager.moving_platform_chance:
			platform_type = "moving"

		var platform_instance = create_platform(location)
		platform_instance.set_type(platform_type)
		if platform_type == "moving":
			platform_instance.set_screen_width(viewport_size.x, platform_width)
			#platform_instance.set_movement_speed(DificultyManager.platform_speed)
		generated_platform_count += 1
	#endregion

func set_player_score(_player_score):
	player_score = _player_score

func reset_level():
	for platform in platformParent.get_children():
		platform.queue_free()

	generated_platform_count = 0
