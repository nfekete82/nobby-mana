extends Control
const Art = preload("res://scripts/art_library.gd")
var choice_buttons: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("16242d")
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",18)
	center.add_child(box)
	var title := Label.new()
	title.text = "NOBBY MANA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",30)
	title.add_theme_color_override("font_color",Color("d2ad65"))
	box.add_child(title)
	var prompt := Label.new()
	prompt.text = "Wähle deinen Helden"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(prompt)
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation",24)
	box.add_child(cards)
	for id: String in ["mage","shaman","monkey"]:
		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(230,0)
		cards.add_child(card)
		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(192,192)
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		portrait.texture = Art.frames_for({"mage":"hero","shaman":"shaman","monkey":"monkey-shaman"}[id]).get_frame_texture("stand",0)
		card.add_child(portrait)
		var button := Button.new()
		button.text = {"mage":"Magier","shaman":"Schamane","monkey":"Affen-Schamane"}[id]
		button.custom_minimum_size = Vector2(220,42)
		button.pressed.connect(choose.bind(id))
		choice_buttons[id] = button
		card.add_child(button)
		var description := Label.new()
		description.text = "Arkane Pfeile · 6 Mana\n25 Schaden pro Treffer" if id == "mage" else "Pfeile werfen · kein Mana\nSkelette erwecken mit R"
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.add_theme_font_size_override("font_size",14)
		card.add_child(description)
	var help := Label.new()
	help.text = "WASD / Pfeile: laufen · Linksklick / J: Fernangriff\nLeertaste: Nahkampf · Esc: Klassenwahl · F5: neue Runde"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.add_theme_font_size_override("font_size",13)
	box.add_child(help)

func choose(id: String) -> void:
	if get_node("/root/Session").choose(id):
		get_tree().change_scene_to_file("res://scenes/clearing.tscn")
