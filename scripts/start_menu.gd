extends Control
const Art = preload("res://scripts/art_library.gd")
var choice_buttons: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := TextureRect.new()
	background.texture = load("res://assets/compiled/grove-grass.png")
	background.stretch_mode = TextureRect.STRETCH_TILE
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.025,0.065,0.045,0.88)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",18)
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("13251fed")
	style.border_color = Color("ae9455")
	style.set_border_width_all(2)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel",style)
	center.add_child(panel)
	panel.add_child(box)
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
	for id: String in ["monkey","panda"]:
		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(230,0)
		cards.add_child(card)
		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(192,192)
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		portrait.texture = Art.frames_for({"monkey":"monkey-shaman","panda":"panda"}[id]).get_frame_texture("stand",0)
		card.add_child(portrait)
		var button := Button.new()
		button.text = {"monkey":"Affen-Schamane","panda":"Panda-Kämpferin"}[id]
		button.custom_minimum_size = Vector2(220,42)
		button.pressed.connect(choose.bind(id))
		choice_buttons[id] = button
		card.add_child(button)
		var description := Label.new()
		description.text = "Holzschwert · 28 Schaden\nNahkampf · 125 Leben" if id == "panda" else "Pfeile werfen · kein Mana\nSkelette erwecken mit R"
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.add_theme_font_size_override("font_size",14)
		card.add_child(description)
	var help := Label.new()
	help.text = "WASD / Pfeile: laufen · Linksklick / J: Klassenangriff\nLeertaste: Nahkampf · H: Heilen · R: Skelette\nEsc: Heldenwahl · F5: neue Runde"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.add_theme_font_size_override("font_size",13)
	box.add_child(help)

func choose(id: String) -> void:
	if get_node("/root/Session").choose(id):
		get_tree().change_scene_to_file("res://scenes/clearing.tscn")
