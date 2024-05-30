extends Node

class ArenaState:
	# k, v: index, state
	var chunks: Array # [GroundChunk.CHUNK_STATE]
	
	# type hint breaks here for some reason
	func _init(c: Array):
		chunks = c
	
	# type hint breaks here for some reason
	static func decode(arr: Array):
		var enum_array = arr.map(
			func(i):
				return GroundChunk.CHUNK_STATE.values()[i])
		return ArenaState.new(enum_array)
	
	func serialize():
		return chunks

class PlayerState:
	var position: Vector3
	# temporary variable, will be wrapped in MoveState later
	var target: Vector2
	var hero_state: HeroState
	# derived entities
	# e.g.: projectiles, remnants
	var derivatives: Dictionary
	
	# Hero State still W.I.P.
	# Derivates still W.I.P.
	func _init(p: Vector3, t: Vector2, hs: HeroState, d: Dictionary):
		position = p
		target = t
		hero_state = hs
		derivatives = d
	
	static func decode(dict: Dictionary):
		return PlayerState.new(
			dict['position'],
			dict['target'],
			dict['hero_state'],
			dict['derivatives']
		)
	
	func serialize():
		return {
			'position': position, 
			'target': target,
			'hero_state': null,
			'derivatives': {},
		}


class GameState:
	var arena: ArenaState
	# k, v: id, PlayerState
	var players: Dictionary
	
	func _init(a: ArenaState, p: Dictionary):
		arena = a
		players = p
	
	static func decode(dict: Dictionary):
		var t = dict['arena']
		var a = ArenaState.decode(dict['arena'])
		var p = dict['players']
		for p_id in p:
			p[p_id] = PlayerState.decode(p[p_id])
		return GameState.new(a, p)
	
	func serialize():
		var p_to_send = {}
		for p_id in self.players:
			p_to_send[p_id] = players[p_id].serialize()
		return {
			'arena': self.arena.serialize(),
			'players': p_to_send,
		}

## Class for polled player input
## Used standalone, or wrapped in FrameState
class PlayerInput:
	var frame: int
	var key: Key
	var target: Vector2
	
	func _init(f: int, k: Key, t: Vector2):
		frame = f
		key = k
		target = t
	
	static func decode(dict: Dictionary):
		if len(dict) != 3 \
			or not 'frame' in dict \
			or not 'key' in dict \
			or not 'target' in dict :
				return null
		var player_input = PlayerInput.new(
			dict['frame'], dict['key'], dict['target'])
		return player_input
	
	func serialize():
		return {
			'frame': self.frame,
			'key': self.key,
			'target': self.target,
		}

class FrameState:
	var frame: int
	var states: GameState
	# k, v: index, PlayerInput
	var inputs: Dictionary
	
	func _init(f: int, s: GameState, i: Dictionary):
		frame = f
		states = s
		inputs = {}
		for id in i:
			var input = i[id]
			input = PlayerInput.decode(input)
			inputs[id] = input
	
	static func decode(dict: Dictionary):
		if len(dict) != 3 \
			or not 'frame' in dict \
			or not 'states' in dict \
			or not 'inputs' in dict :
				return null
		var states = GameState.decode(dict['states'])
		var inputs = dict['inputs']
		var frame_state = FrameState.new(
			dict['frame'], states, inputs)
		return frame_state
		
	func serialize():
		var serialized_inputs = {}
		for id in inputs:
			var input = inputs[id]
			serialized_inputs[id] = input.serialize()
		return {
			"frame" : self.frame,
			"states" : self.states.serialize() if self.states else null,
			"inputs" : serialized_inputs,
		}
