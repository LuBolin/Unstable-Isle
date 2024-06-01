extends Node

signal prep_started
signal hero_picked(hero_name, id)
signal round_started
signal hero_died(id)
signal round_ended

signal received_server_frame
signal received_client_input

var hero_choices = {
	# id: "hero_name"
}

var is_dead_dict = {
	# id: dead_or_alive_boolean
}

func _ready():
	hero_died.connect(
		func(id): is_dead_dict[id] = true)

func reset():
	hero_choices.clear()
	is_dead_dict.clear()
	for id in Game.players:
		hero_choices[id] = null
		is_dead_dict[id] = false
