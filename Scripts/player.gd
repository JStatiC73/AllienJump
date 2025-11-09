extends CharacterBody2D

class_name Player
signal die

@onready var animator = $AnimatedSprite2D
@onready var shape = $CollisionShape2D
@export var speed = 300
@export var accelerometer_speed = 130.0
@export var gravity = 15.0
@export var jump_velocity = -800
@export var gravity_factor = 1.0
var max_fall_velocity = 1000.0
var viewport_size
var use_accelerometer = false
var dead = false
var idle_animation = "idle_1"
var jump_animation = "jump"
var fall_animation = "fall"

func _ready():
	animator.play(idle_animation)
	viewport_size = get_viewport_rect().size
	var os_name = OS.get_name()
	if (os_name == "Android" || os_name == "iOS"):
		use_accelerometer = true


func _process(_delta):
	if velocity.y > 0:
		if animator.animation != fall_animation:
			animator.play(fall_animation)
			#print(animator.animation)
	else:
		if animator.animation != jump_animation:
			animator.play(jump_animation)
			#print(animator.animation)

func _physics_process(_delta):
	velocity.y += gravity * gravity_factor
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity

	if (!dead):
		if(use_accelerometer):
			var mobile_input = Input.get_accelerometer()
			velocity.x = mobile_input.x * accelerometer_speed
		else:
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	var margin = 45
	if global_position.x > viewport_size.x + margin:
		global_position.x = -margin


	if global_position.x < -margin:
		global_position.x = viewport_size.x + margin


func jump():
	velocity.y = jump_velocity
	SoundFX.play("Jump")
	MyUtility.add_log_msg("Player jumped!")


func _on_visible_on_screen_notifier_2d_screen_exited():
		player_die()


func player_die():
	if(!dead):
		SoundFX.play("Fall")
		#set_deferred("disabled", true) es lo mismo que disabled = true, pero aveces
		#a godot no le gusta que se setee el disable a la mitad de un frame, por lo que es mas recomendable
		#utilizar set_deferred, ya que lo ejecuta en el ultimo frame
		shape.set_deferred("disabled", true)
		dead = true
		die.emit()

func use_new_skin():
	idle_animation = "idle_pink"
	jump_animation = "jump_pink"
	fall_animation = "fall_pink"
