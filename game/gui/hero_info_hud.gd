extends Control

@onready var spell_indicators_hbox = $Spells

var hero_displayed: Hero
var hero_assets: HeroAssetHolder
var spell_list: SpellList

func set_hero(h: Hero):
	hero_displayed = h
	hero_assets = hero_displayed.hero_assets
	spell_list = hero_assets.spell_list
	var spell_indicators = spell_indicators_hbox.get_children()
	spell_indicators[0].set_texture(hero_assets.atk_icon)
	spell_indicators[1].set_texture(hero_assets.fst_icon)
	spell_indicators[2].set_texture(hero_assets.scd_icon)
	spell_indicators[3].set_texture(hero_assets.ult_icon)

func clear():
	hero_displayed = null
	hero_assets = null
	spell_list = null
	for indicator in spell_indicators_hbox.get_children():
		indicator.set_texture(null)

func _process(delta):
	if not hero_displayed:
		return
	var cooldowns = spell_list.get_all_cooldowns()
	var spell_indicators = spell_indicators_hbox.get_children()
	for i in range(len(cooldowns)):
		var cooldown = cooldowns[i][0]
		var current_cooldown = cooldowns[i][1]
		
		var spell_icon = spell_indicators[i]
		var icon_shader = spell_icon.get_material()
		icon_shader.set_shader_parameter("cooldown", cooldown)
		icon_shader.set_shader_parameter("current_cooldown", current_cooldown)

		var spell_cd_overlay = spell_icon.get_node("CooldownOverlay")
		var overlay_shader = spell_cd_overlay.get_material()
		overlay_shader.set_shader_parameter("cooldown", cooldown)
		overlay_shader.set_shader_parameter("current_cooldown", current_cooldown)
		
		var spell_cd_label = spell_icon.get_node("CooldownLabel")
		var cd_to_show = current_cooldown if current_cooldown > 0.0 else cooldown
		cd_to_show = "%.2f" % [cd_to_show]
		spell_cd_label.set_text(cd_to_show)
