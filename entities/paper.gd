@tool
extends Node3D

func set_sprite(texture: Texture):
	print("Setting sprite as ")
	print(texture)
	$Render/Sprite.set_texture(texture)
	pass
