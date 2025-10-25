extends Node

var current_level := 1
var disappear_platform_chance := 0.1
var moving_platform_chance := 0.1
var platform_speed := 100
var min_distance_between_platforms := 180
var max_distance_between_platforms := 240

func update_difficulty(score: int):
	#cada 1000 puntos sube la dificultad
	current_level = 1 + int(score / 1000)
	disappear_platform_chance = clamp(0.1 + current_level * 0.05, 0.1, 0.5)
	moving_platform_chance = clamp(0.1 + current_level * 0.7, 0.1, 0.7)
	platform_speed = 100 + current_level * 20
	min_distance_between_platforms = clamp(180 - current_level * 10, 100, 180)
	max_distance_between_platforms = clamp(240 - current_level * 10, 120, 240)
