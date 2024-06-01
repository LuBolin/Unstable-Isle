extends Node3D


# For now custom bullet
@onready var bullet_node = preload("res://entities/Bullet.tscn")
const CD = 60
var cd_time_left = 0

func create_bullet(target, frame):
	if cd_time_left + CD < frame:
		$"../../../UnitManager".create_bullet(target)
		cd_time_left = frame
