extends CharacterBody3D

const PlayerInput = Serializables.PlayerInput

const SPEED = 50.0
const JUMP_VELOCITY = 4.5
var direction = Vector2(0, 0)
var id
var lifespan = 120

func init(b_id, ls):
	id = b_id
	lifespan = ls


func simulate(unit_states, input: PlayerInput):
	position = unit_states['position']
	var d = unit_states['direction']
	var dirn: Vector3 = Vector3(d.x, 0, d.y)
	lifespan = unit_states['lifespan']
	velocity = dirn.normalized() * SPEED
	move_and_slide()
	lifespan -= 1
	if lifespan < 0:
		return null
	return {'id' : id,\
						'direction' : d,\
						'position' : position, 'lifespan' : lifespan}
