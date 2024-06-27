extends Control

@onready var player_list = $VBoxContainer/PlayerList
@onready var round_result_label: Label = $RoundResultLabel

@onready var gui_controller: GameroomGuiController = $".."
var game_room: GameRoom
var game_round: GameRound

func clear_player_list():
	for c in player_list.get_children():
		player_list.remove_child(c)
		c.queue_free()
	
func _ready():
	game_room = gui_controller.game_room
	game_room.round.prep_started.connect(_prep_started)
	game_room.round.hero_picked.connect(_hero_picked)
	game_room.round.round_started.connect(_round_started)
	game_room.round.hero_died.connect(_hero_died)
	game_room.round.round_ended.connect(_round_ended)

func _prep_started(_game_seed):
	game_round = game_room.round
	update_player_list()
	round_result_label.hide()

func _hero_picked(hero_name, id):
	update_player_list()

func _round_started():
	print("Game round assigned")
	round_result_label.hide()
	update_player_list()

func _hero_died(_id_of_dead_hero):
	update_player_list()

func update_player_list():
	if game_room.game_phase == game_room.PHASE.HOLD:
		update_player_list_in_hold()
	elif game_room.game_phase == game_room.PHASE.PREP:
		update_player_list_in_prep()
	# maybe better to handle death separately
	# using move_child, instead of re-constructing the playerlist
	# but this is a small problem
	elif game_room.game_phase == game_room.PHASE.GAME:
		update_player_list_in_game()

func update_player_list_in_hold():
	clear_player_list()
	for id in game_room.players:
		var player = game_room.players[id]
		var p_name = player['username']
		var p_score = player['score']
		var item = scoreboard_object.new(p_name, p_score)
		player_list.add_child(item)

func update_player_list_in_prep():
	clear_player_list()
	for id in game_room.players:
		var player = game_room.players[id]
		var p_name = player['username']
		var p_score = player['score']
		var hero_choice = game_round.hero_choices[id]
		var texture = null
		if hero_choice:
			var asset_holder: HeroAssetHolder = Hero.get_hero_asset_holder(hero_choice)
			texture = asset_holder.portrait_icon if asset_holder else null
		var item = scoreboard_object.new(p_name, p_score, texture)
		player_list.add_child(item)

func update_player_list_in_game():
	clear_player_list()
	var alives = []
	var deads = []
	for id in game_room.players:
		if id in game_room.round.is_dead_dict:
			deads.append(id)
		else:
			alives.append(id)
	for i in range(len(alives)):
		var id = alives[i]
		var player = game_room.players[id]
		var p_name = player['username']
		var p_score = player['score']
		var asset_holder: HeroAssetHolder = \
			Hero.get_hero_asset_holder(game_round.hero_choices[id])
		var texture: Texture2D = \
			asset_holder.portrait_icon if asset_holder else null
		var item = scoreboard_object.new(p_name, p_score, texture)
		player_list.add_child(item)
	for i in range(len(deads)):
		var id = deads[i]
		var player = game_room.players[id]
		var p_name = player['username']
		var p_score = player['score']
		var asset_holder: HeroAssetHolder = \
			Hero.get_hero_asset_holder(game_round.hero_choices[id])
		var texture: Texture2D = \
			asset_holder.portrait_icon if asset_holder else null
		var item = scoreboard_object.new(p_name, p_score, texture, true)
		player_list.add_child(item)

func _round_ended(id):
	round_result_label.show()
	if id:
		var username = game_room.players[id]['username']
		round_result_label.set_text("%s Won!" % [username])
	else:
		round_result_label.set_text("DRAW!")
	if multiplayer.is_server():
		get_tree().create_timer(3).timeout.connect(
			func(): game_room.round.prep_started.emit(randi())
		)

class scoreboard_object extends PanelContainer:
	var hbox
	var hero_icon
	var score_label
	var stretch
	var username_label
	func _init(username, score, hero_texture: Texture2D = null, dead = false):
		var text_color = Color.DARK_RED if dead else Color.WEB_GREEN
		
		hbox = HBoxContainer.new()
		
		if hero_texture:
			hero_icon = TextureRect.new()
			hero_icon.set_texture(hero_texture)
			hero_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			hbox.add_child(hero_icon)
		
		score_label = Label.new()
		score_label.set_text(str(score))
		score_label.set("theme_override_colors/font_color",text_color)
		
		stretch = Control.new()
		stretch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		username_label = Label.new()
		username_label.set_text(username)
		username_label.set("theme_override_colors/font_color",text_color)
		
		hbox.add_child(username_label)
		hbox.add_child(stretch)
		hbox.add_child(score_label)
		
		add_child(hbox)
