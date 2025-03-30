extends Node2D

@onready var player = $Player
@onready var level_generator = $LevelGenerator

var camera_scene = preload("res://Scenes/game_camera.tscn")
var camera = null

func _ready():
	var camera_instance = camera_scene.instantiate()
	camera_instance.setup_camera(player)
	add_child(camera_instance)	
	
	if(player):
		level_generator.setup(player)
	
func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
