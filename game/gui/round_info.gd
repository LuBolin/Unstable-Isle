extends Control

@onready var player_list = $VBoxContainer/PlayerList
@onready var round_result_label: Label = $RoundResultLabel

@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom

func _ready():
	game_room = gui_controller.game_room
	game_room.round.prep_started.connect(_prep_started)
	game_room.round.round_started.connect(_round_started)
	game_room.round.hero_died.connect(_hero_died)
	game_room.round.round_ended.connect(_round_ended)

func _prep_started(_game_seed):
	player_list.clear()
	round_result_label.hide()

func _round_started():
	round_result_label.hide()
	update_player_list()
	
	# for debug with single player lobbies
	check_round_should_end()

func _hero_died(_id_of_dead_hero):
	update_player_list()
	check_round_should_end()

func update_player_list():
	if game_room.game_phase == game_room.PHASE.HOLD:
		update_player_list_in_hold()
	elif game_room.game_phase == game_room.PHASE.GAME:
		update_player_list_in_game()

func update_player_list_in_hold():
	player_list.clear()
	var count = 0
	for id in game_room.players:
		var p_name = game_room.players[id][0]
		# text, icon, selectable
		player_list.add_item(p_name, null, false)
		player_list.set_item_custom_fg_color(count, Color.GREEN)
		count += 1

func update_player_list_in_game():
	player_list.clear()
	var alives = []
	var deads = []
	for id in game_room.players:
		var p_name = game_room.players[id][0]
		# var score = Game.players[id][1]
		if game_room.round.is_dead_dict[id]:
			deads.append(p_name)
		else:
			alives.append(p_name)
	for i in range(len(alives)):
		var p_name = alives[i]
		# text, icon, selectable
		player_list.add_item(p_name, null, false)
		player_list.set_item_custom_fg_color(i, Color.GREEN)
	for i in range(len(deads)):
		var p_name = deads[i]
		# text, icon, selectable
		player_list.add_item(p_name, null, false)
		player_list.set_item_custom_fg_color(i+len(alives), Color.RED)

func check_round_should_end():
	var alive_ids = []
	for id in game_room.round.is_dead_dict:
		var dead = game_room.round.is_dead_dict[id]
		if not dead:
			alive_ids.append(id)
	if len(alive_ids) > 1:
		return
	get_tree().create_timer(5).timeout.connect(
		func():
			var winner = alive_ids[0] if not alive_ids.is_empty() else null
			game_room.round.round_ended.emit(winner)
	)

func _round_ended(id):
	round_result_label.show()
	if id:
		round_result_label.set_text("%s Won!" % [id])
	else:
		round_result_label.set_text("DRAW!")
	if multiplayer.is_server():
		get_tree().create_timer(3).timeout.connect(
			func(): game_room.round.prep_started.emit(randi())
		)
