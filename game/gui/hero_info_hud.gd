extends Control


@onready var spell_indicators_hbox = $Aligner/SpellIndicatorsHbox
@onready var health_bar = $Aligner/HealthBar
@onready var health_label = $Aligner/HealthBar/HealthLabel


var hero_displayed: Hero
var hero_assets: HeroAssetHolder
var spell_list: SpellList

func set_hero(h: Hero):
	hero_displayed = h
	hero_assets = hero_displayed.hero_assets
	spell_list = hero_assets.spell_list
	var spell_indicators = spell_indicators_hbox.get_children()
	spell_indicators[0].set_spell(hero_assets, 'atk')
	spell_indicators[1].set_spell(hero_assets, 'fst')
	spell_indicators[2].set_spell(hero_assets, 'scd')
	spell_indicators[3].set_spell(hero_assets, 'ult')
	
	var max_hp = hero_displayed.MAX_HEALTH
	health_bar.set_max(max_hp)
	health_bar.set_min(0)
	var hp = hero_displayed.health
	health_bar.set_value(hp)

func clear():
	hero_displayed = null
	hero_assets = null
	spell_list = null
	for indicator: SpellIndicator in spell_indicators_hbox.get_children():
		indicator.reset()

func _process(_delta):
	if not hero_displayed:
		return
	update_healthbar()
	update_spell_indicators()
	
func update_healthbar():
	var hp = hero_displayed.health
	health_bar.set_value(hp) 
	
	# 2 digits decimal
	var format_string = "HP: %2d"
	health_label.set_text(format_string % hp)

func update_spell_indicators():
	var cooldowns = spell_list.get_all_cooldowns()
	var spell_indicators = spell_indicators_hbox.get_children()
	for i in range(len(cooldowns)):
		var spell_indicator: SpellIndicator = spell_indicators[i]
		var full_cd = cooldowns[i][0]
		var current_cd = cooldowns[i][1]
		
		var spell_being_casted = null
		if current_cd == 0: # potentially casting
			var current_state = hero_displayed.state_manager.current_state
			if current_state is CastState:
				spell_being_casted = current_state.spell
		spell_indicator.render(full_cd, current_cd, spell_being_casted)
