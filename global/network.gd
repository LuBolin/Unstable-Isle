extends Node

## Server constants
const MAX_PLAYERS : int = 6
const POLL_PER_FRAME: float = 5

# effectively a constant
var IP_ADDRESS : String = "127.0.0.1"
# var IP_ADDRESS : String = "192.168.1.17"
# var IP_ADDRESS : String = "116.14.251.190"
const PORT : int = 22322


# never contains server
var player_list = {}


func _ready():
	multiplayer.peer_connected.connect(_on_client_connected)
	multiplayer.peer_disconnected.connect(_on_client_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_success)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_client() -> void:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	print(IP_ADDRESS)
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func create_server() -> void:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer

func terminate_multiplayer() -> void:
	multiplayer.multiplayer_peer = null


## Server connections
func _on_client_connected(id):
	if multiplayer.is_server():
		player_list[id] = id
		print(str(id) + " connected to " + str(multiplayer.get_unique_id()))
	else:
		if not id == 1:
			player_list[id] = id

func _on_client_disconnected(id):
	player_list.erase(id)
	print(str(id) + " disconnect")
	print(player_list.values())

func _on_connected_success():
	print("connect success")
	player_list[multiplayer.get_unique_id()] = multiplayer.get_unique_id()

func _on_connected_fail():
	print("connect fail")

func _on_server_disconnected():
	print("disconnect")


## TODO game state functions
signal start_prep_signal
signal pick_hero_signal

signal start_game_signal
signal receive_server_frame
signal receive_client_input


@rpc("authority", "call_remote", "reliable", 0)
func start_prep(seed):
	print("Start prep rpc on %s" % [str(multiplayer.get_unique_id())])
	start_prep_signal.emit(seed)

@rpc("any_peer", "call_remote", "reliable", 1)
func pick_hero(hero_choice, sender_id = null):
	# print("Sending input of %s, %s" % [player_input['frame'], player_input['target']])
	if sender_id == null:
		sender_id = multiplayer.get_remote_sender_id()
	pick_hero_signal.emit(hero_choice, sender_id)



@rpc("authority", "call_local", "reliable", 0)
func start_game():
	print("Start game rpc on %s" % [str(multiplayer.get_unique_id())])
	start_game_signal.emit()

# @rpc("authority", "call_remote", "unreliable", 0)
@rpc("authority", "call_remote", "unreliable_ordered", 0)
func send_frame(frame):
	receive_server_frame.emit(frame)

func receive_state():
	pass


@rpc("any_peer", "call_remote", "unreliable", 1)
func send_input(player_input):
	var sender_id = multiplayer.get_remote_sender_id()
	receive_client_input.emit(player_input, sender_id)

func receive_input():
	pass
