class_name LobbyLogin
extends Control

@onready var username_edit = $Positioning/LogIn/HBoxContainer/UsernameEdit
@onready var start_button = $Positioning/LogIn/StartButton

var username = ""

signal logged_in(username)

func _ready():
	username_edit.clear()
	start_button.set_disabled(true)
	username_edit.text_changed.connect(_on_username_editted)
	start_button.pressed.connect(_on_start)

func _on_username_editted(text: String):
	username = text
	var valid = username.length() > 0
	start_button.set_disabled(not valid)

func _on_start():
	logged_in.emit(username)
