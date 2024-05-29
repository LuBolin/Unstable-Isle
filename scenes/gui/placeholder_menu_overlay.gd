extends Control

@onready var server_button = $VBoxContainer/Server/ServerButton
@onready var client_button = $VBoxContainer/Client/ClientButton
@onready var start_game_button = $VBoxContainer/Server/StartGameButton
@onready var ip_edit = $VBoxContainer/Client/IpEdit

func _ready():
	server_button.pressed.connect(_on_join_as_server)
	client_button.pressed.connect(_on_join_as_client)
	start_game_button.pressed.connect(_on_start_prep)
	ip_edit.text_changed.connect(_on_ip_editted)

func _on_join_as_server():
	Network.create_server()
	print(multiplayer.multiplayer_peer.get_unique_id())
	server_button.set_disabled(true)
	client_button.set_disabled(true)

func _on_join_as_client():
	Network.create_client()
	print(multiplayer.multiplayer_peer.get_unique_id())
	server_button.set_disabled(true)
	client_button.set_disabled(true)
	start_game_button.set_disabled(true)

func _on_start_prep():
	start_game_button.set_disabled(true)
	Network.start_prep_signal.emit(randi())
	#Network.start_game_signal.emit()

func _on_ip_editted(new_text: String):
	# some ip_parsing later, don't care for now
	Network.IP_ADDRESS = new_text
