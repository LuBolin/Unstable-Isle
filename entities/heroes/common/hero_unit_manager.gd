class_name UnitManager
extends Node3D

const PlayerInput = Serializables.PlayerInput

var hero : Hero

func init(h: Hero):
	print("init %s", h)
	hero = h

@onready var bullet_node = preload("res://entities/Bullet.tscn")
func simulate(unit_states, input: PlayerInput):
	var end_states = {}
	for child in get_children():
		if not child.id in unit_states:
			print(child.id)
			child.queue_free()
	for id in unit_states:
		var unit_state = unit_states[id]
		var exists = false
		for child in get_children():
			if child.id == unit_state['id']:
				var end_state = child.simulate(unit_state, input)
				if end_state:
					end_states[unit_state['id']] = end_state
				exists = true
		if not exists:
			var bullet = bullet_node.instantiate()
			bullet.init(unit_state['id'], unit_state['lifespan'])
			add_child(bullet)
			var end_state = bullet.simulate(unit_state, input)
			if end_state:
				end_states[unit_state['id']] = end_state
	while not bullet_queue.is_empty():
		var unit_state = bullet_queue.pop_front()
		var bullet = bullet_node.instantiate()
		add_child(bullet)
		bullet.init(unit_state['id'], unit_state['lifespan'])
		var end_state = bullet.simulate(unit_state, input)
		if end_state:
			end_states[unit_state['id']] = end_state
	print(end_states)
	return end_states


var bullet_count = 0
var bullet_queue = []
func create_bullet(target):
	bullet_queue.append({'id' : bullet_count,\
						'direction' : target - Vector2(hero.position.x, hero.position.z),\
						'position' : hero.position + Vector3(20, 20, 0), 'lifespan' : 120})
	bullet_count += 1
