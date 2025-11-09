extends Area2D

class_name	Platform

var movingPlatform
var disapearPlatform
var counterPlatform
var platform_type = "normal"
var base_position: Vector2
var amplitude: float = 100.0
var movement_speed: float = 1.0
var platform_width: float = 135.0
var screen_width: float = 0.0

func _ready():
	base_position = position

func set_screen_width(width, _platform_width):
	platform_width = _platform_width
	screen_width = width
	amplitude = (screen_width - platform_width)

func set_type(type:String):
	platform_type = type

func set_movement_speed(speed: int):
	movement_speed = speed

func _physics_process(_delta):
	if platform_type == "moving":
		position.x = base_position.x + amplitude * sin(Time.get_ticks_msec() / 500.0)
		position.x = clampf(position.x, (platform_width/2), screen_width - (platform_width / 2))

func _on_body_entered(body):
	if body is Player:
		if body.velocity.y > 0:
			body.jump()
			if platform_type == "disappear":
				queue_free() #Se elimina la plataforma al tocarla
