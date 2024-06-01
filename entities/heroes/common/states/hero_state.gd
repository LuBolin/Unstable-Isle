class_name HeroState
extends Node3D

@export var animation_name: String

const PlayerInput = Serializables.PlayerInput

var hero: Hero
var sm: StateManager
var pending_state: HeroState = null

func enter():
	#parent.animations.play(self.name)
	#parent.state_label.set_text(self.name)
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroState:
	return null

func clean_up():
	pass

func process_physics(delta: float) -> HeroState:
	return null

func process_frame(delta: float) -> HeroState:
	return null

func simulate_input(input: PlayerInput):
	pass

func serialize():
	pass
