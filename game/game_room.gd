class_name GameRoom
extends Node3D

var round: GameRound:
	get: round = round if round else get_node("GameRound"); return round
var controller: GameController:
	get: controller = controller if controller else get_node("GameController"); return controller
var network: GameNetwork:
	get: network = network if network else get_node("GameNetwork"); return network
var gui: GameroomGuiController:
	get: gui = gui if gui else get_node("ClientSpecifics/GUI"); return gui
var poller: InputPoller:
	get: poller = poller if poller else get_node("ClientSpecifics/InputPoller"); return poller
var client_specifics: Node:
	get: client_specifics = client_specifics if client_specifics else get_node("ClientSpecifics"); return client_specifics

var username: String
var mutiplayer: SceneMultiplayer = SceneMultiplayer.new()

signal self_disconnected
signal room_closed
signal room_started
signal game_ended

enum PHASE{
	HOLD, # game have not started, clients can still join as player
	PREP, # picking phase
	GAME # game phase
}

const PHASE_NAMES = {
	PHASE.HOLD: "Waiting",
	PHASE.PREP: "Preparing",
	PHASE.GAME: "In Game",
}

var game_phase: PHASE = PHASE.HOLD

var owner_id: int
var players = {}:
	# id: {'username', 'score', 'connected'}
	set(v):
		players = v
		gui.round_info.update_player_list()
		gui.menu_overlay.update_player_list()
const MAX_PLAYERS = 6

func get_connected_players():
	var connecteds = {}
	for p_id in players:
		if players[p_id]['connected']:
			connecteds[p_id] = players[p_id]
	return connecteds

func _enter_tree():
	get_tree().set_multiplayer(mutiplayer, self.get_path())

func create_room(port: int):
	network.create_server(port)
	
	self.set_visible(false)
	# turn off _process
	propagate_call('set_process',[false])
	for c in client_specifics.get_children():
		c.queue_free()

func join_room(ip: String, port: int, username: String):
	# print("%s joining %s:%s" % [multiplayer.get_unique_id(),ip, port])
	self.set_visible(true)
	self.username = username
	network.create_client(ip, port)

func request_start_game(requester_id):
	if not mutiplayer.is_server():
		return
	if not requester_id == owner_id:
		return
	if players.size() <= 1:
		return
	var game_seed = randi()
	network.start_prep.rpc(game_seed)
	room_started.emit()

func request_close_room(requester_id):
	print("Requested to close, by ", requester_id)
	if not mutiplayer.is_server():
		return
	if not requester_id == owner_id:
		return
	close_room()

func close_room():
	if not mutiplayer.is_server():
		return
	for p in players:
		if players[p]['connected']:
			multiplayer.multiplayer_peer.disconnect_peer(p)
	room_closed.emit()

func disconnect_self():
	multiplayer.multiplayer_peer.close()
	self_disconnected.emit()

# for lobby_room
func serialize():
	var v = {}
	v['port'] = network.port
	v['player_count'] = players.size()
	v['phase'] = PHASE_NAMES[game_phase]
	return v
