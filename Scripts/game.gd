extends Node2D

signal player_died(score, scoreList, isHighScore)

@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroudSprite

@onready var parallax1 = $ParallaxBackground/ParallaxLayer
@onready var parallax2 = $ParallaxBackground/ParallaxLayer2
@onready var parallax3 = $ParallaxBackground/ParallaxLayer3
@onready var hud = $UILayer/HUD

var save_file_path = "user://highscore.save"
var camera_scene = preload("res://Scenes/game_camera.tscn")
var player_scene = preload("res://Scenes/player.tscn")
var camera = null
var player: Player = null
var player_spawn_position: Vector2
var viewport_size: Vector2
var score: int = 0
var highScore: int = 0
var scores = []
var new_skin = false

func _ready():
	viewport_size = get_viewport_rect().size
	var player_spawn_pos_y_offset = 40
	player_spawn_position.x = viewport_size.x / 2.0
	player_spawn_position.y = viewport_size.y - player_spawn_pos_y_offset

	ground_sprite.global_position.x = viewport_size.x / 2.0
	ground_sprite.global_position.y = viewport_size.y + 90 #margen para mostrar el suelo no tan alejado
	#de las plataformas que conforman el suelo
	print("view port size:", viewport_size.y)
	print("ground position: ", ground_sprite.global_position.y)

	setup_parralax_layer(parallax1)
	setup_parralax_layer(parallax2)
	setup_parralax_layer(parallax3)

	hud.visible = false
	ground_sprite.visible = false
	hud.set_score(0)
	load_score()
	#new_game()

func get_parallax_sprite_scale(parallax_sprite: Sprite2D):
	var parallax_texture = parallax_sprite.get_texture()
	var parallax_texture_width = parallax_texture.get_width()

	var _scale = viewport_size.x / parallax_texture_width
	var result = Vector2(_scale, _scale)
	return result

func setup_parralax_layer(parallax_layer: ParallaxLayer):
	var parallax_sprite = parallax_layer.find_child("Sprite2D")
	if parallax_sprite != null:
		parallax_sprite.scale = get_parallax_sprite_scale(parallax_sprite)
		var my = parallax_sprite.scale.y * parallax_sprite.get_texture().get_height()
		parallax_layer.motion_mirroring.y = my
		print("paralax scale: " + str(parallax_sprite.scale))
		print("paralax mirroring: " + str(parallax_layer.motion_mirroring.y))


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

	if player:
		if score < int(viewport_size.y - player.global_position.y):
			score = int(viewport_size.y - player.global_position.y)
			hud.set_score(score)
			level_generator.set_player_score(score)

func new_game():
	reset_game()

	player = player_scene.instantiate()
	player.global_position = player_spawn_position
	player.die.connect(_on_player_died)
	add_child(player)
	#new_skin = true
	if(new_skin):
		player.use_new_skin()

	camera = camera_scene.instantiate()
	camera.setup_camera(player)
	add_child(camera)

	if(player):
		level_generator.setup(player)
		level_generator.start_generation()

	hud.visible = true
	ground_sprite.visible = true

	score = 0

func _on_player_died():
	hud.visible = false
	var isHighScore = is_high_score(score)

	player_died.emit(score, scores, isHighScore)

func reset_game():
	ground_sprite.visible = false
	hud.set_score(0)
	hud.visible = false
	level_generator.reset_level()
	if(player != null):
		player.queue_free()
		player = null
		level_generator.player = null

	if (camera != null):
		camera.queue_free()
		camera = null

func is_high_score(playerScore: int):
	if scores.size() < 10:
		return true
	else:
		var min_score = scores[-1]["score"]
		return playerScore > int(min_score)

func save_player_name(player_name, player_score):
	scores.append({"name": player_name, "score": str(player_score)})
	scores.sort_custom(func(a, b): return b["score"] < a["score"])
	print("sorted scores:", scores)
	if scores.size() > 10:
		scores = scores.slice(0, 10)
	save_score()
	return scores

func save_score():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(scores))
	file.close()

func load_score():
	if(FileAccess.file_exists(save_file_path)):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		var content = file.get_as_text()
		if(content != ""):
			var result = JSON.parse_string(content)
			if(typeof(result) == TYPE_ARRAY):
				scores = result
		file.close()
	else:
		scores = []
