class_name HeroBaseState
extends Node

@export
var animation_name: String
var gravity: int = ProjectSettings.get_setting("physics/3d/default_gravity")


func enter():
	#parent.animations.play(self.name)
	#parent.state_label.set_text(self.name)
	pass

func exit():
	pass

func process_input(event: InputEvent) -> HeroBaseState:
	return null

func process_physics(delta: float) -> HeroBaseState:
	return null

func process_frame(delta: float) -> HeroBaseState:
	return null
