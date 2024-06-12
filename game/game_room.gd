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

var mutiplayer: SceneMultiplayer = SceneMultiplayer.new()

enum PHASE{
	HOLD,
	PREP,
	GAME
}

var game_phase: PHASE = PHASE.HOLD

# 'owner': id
# id: ['name', score]
var owner_id: int
var players = {}:
	set(v):
		players = v
		gui.round_info.update_player_list()
		gui.menu_overlay.update_player_list()
const MAX_PLAYERS = 6

func _enter_tree():
	get_tree().set_multiplayer(mutiplayer, self.get_path())

func create_room(port: int):
	network.create_server(port)
	
	# turn off _process
	propagate_call('set_process',[false])
	for c in client_specifics.get_children():
		c.queue_free()

func join_room(ip: String, port: int):
	print("%s joining %s:%s" % [multiplayer.get_unique_id(),ip, port])
	network.create_client(ip, port)

# for lobby_room
func serialize():
	var v = {}
	v['port'] = network.port
	return v
