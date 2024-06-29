extends Control

@export var hero_assets_list: Array[HeroAssetHolder]

@onready var hero_grid = $RegionControl/HeroList/VBoxContainer/HeroGrid
@onready var hero_name_inspector = $"RegionControl/HeroInfo/Portrait/Hero Name"
@onready var hero_portrait_inspector = $"RegionControl/HeroInfo/Portrait/Hero Portrait"
@onready var hero_spells_inspector = $RegionControl/HeroInfo/Spells
@onready var time_left_label = $RegionControl/HeroList/VBoxContainer/TimeLeftLabel
@onready var random_button = $RegionControl/HeroList/VBoxContainer/HBoxContainer/RandomButton
@onready var confirm_button = $RegionControl/HeroList/VBoxContainer/HBoxContainer/ConfirmButton
@onready var gui_controller: GameroomGuiController = $".."

var game_room: GameRoom
var hero_pick_time_left = 0
var choice = null

func _ready():
	game_room = gui_controller.game_room
	random_button.pressed.connect(_on_random_clicked)
	confirm_button.pressed.connect(_on_confirm_clicked)
	game_room.round.prep_started.connect(_prep_started)
	
	for hero_assets in hero_assets_list:
		var button = Button.new()
		button.set_button_icon(hero_assets.portrait_icon)
		button.pressed.connect(
			_on_hero_button_clicked.bind(button, hero_assets))
		hero_grid.add_child(button)

func _process(delta):
	if game_room.game_phase != game_room.PHASE.PREP:
		return
	if game_room.multiplayer.is_server():
		return
	hero_pick_time_left -= delta
	var string = "Time Left: %s"
	var time_left = int(max(0, hero_pick_time_left))
	string = string % [time_left]
	time_left_label.set_text(string)

func _on_hero_button_clicked(
	button: Button, hero_choice: HeroAssetHolder):
	for b in hero_grid.get_children():
		if b == button:
			b.set_modulate(Color.GREEN)
		else:
			b.set_modulate(Color.BLACK)
	choice = hero_choice.hero_name
	
	for child in hero_spells_inspector.get_children():
		# remember that queue_free does not remove immediately
		# it just removes ASAP
		hero_spells_inspector.remove_child(child)
		child.queue_free()
	
	hero_name_inspector.set_text(hero_choice.hero_name)
	hero_portrait_inspector.set_texture(hero_choice.portrait_icon)
	var spells = [
		["atk_icon", "atk_description"],
		["fst_icon", "fst_description"],
		["scd_icon", "scd_description"],
		["ult_icon", "ult_description"],
		]
	for spell in spells:
		var icon = TextureRect.new()
		icon.set_texture(hero_choice.get(spell[0]))
		hero_spells_inspector.add_child(icon)
		
		var label = Label.new()
		label.set_text(hero_choice.get(spell[1]))
		hero_spells_inspector.add_child(label)

func _on_random_clicked():
	var rng = RandomNumberGenerator.new()
	var rdm_range = len(hero_grid.get_children())
	# inclusive
	var rdm = rng.randi_range(0, rdm_range-1)
	hero_grid.get_child(rdm).pressed.emit()

func _on_confirm_clicked():
	if not choice:
		return
	game_room.network.pick_hero.rpc_id(1, choice)

func _prep_started(_seed):
	choice = null
	hero_pick_time_left = Settings.PICK_PHASE_DURATION
	for b in hero_grid.get_children():
		if b is Button:
			# default color is white
			b.set_modulate(Color.WHITE)
