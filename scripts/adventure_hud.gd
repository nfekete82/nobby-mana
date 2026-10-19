extends RefCounted
## Functional controls follow the reference layout; illustrations are bitmap art.

static func frame(color: String,border: String,width := 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color)
	style.border_color = Color(border)
	style.set_border_width_all(width)
	return style

static func label(parent: Node,text: String,at: Vector2,size: int) -> Label:
	var node := Label.new()
	node.text = text
	node.position = at
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_color",Color("f2ead1"))
	node.add_theme_color_override("font_outline_color",Color("101a1c"))
	node.add_theme_constant_override("outline_size",3)
	parent.add_child(node)
	return node

static func bar(parent: Node,at: Vector2,color: String,maximum: float) -> ProgressBar:
	var node := ProgressBar.new()
	node.position = at
	node.size = Vector2(152,16)
	node.max_value = maximum
	node.step = 0
	node.add_theme_font_size_override("font_size",1)
	node.show_percentage = false
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_stylebox_override("background",frame("111a1c","c8bea1",2))
	var fill := frame(color,color,0)
	fill.set_expand_margin_all(-3)
	node.add_theme_stylebox_override("fill",fill)
	parent.add_child(node)
	node.size = Vector2(152,16)
	return node

static func slot(parent: Node,at: Vector2,icon: String,caption: String,key: String,tooltip: String) -> Button:
	var button := Button.new()
	button.position = at
	button.size = Vector2(62,62)
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = tooltip
	button.add_theme_stylebox_override("normal",frame("152225ef","c1b697",2))
	button.add_theme_stylebox_override("hover",frame("243d40","f1d998",2))
	button.add_theme_stylebox_override("pressed",frame("314d4d","78d5fa",3))
	button.add_theme_stylebox_override("disabled",frame("121b1fda","69736a",2))
	parent.add_child(button)
	var art := TextureRect.new()
	art.texture = load("res://assets/compiled/hud-"+icon+".png")
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.position = Vector2(7,6)
	art.size = Vector2(48,48)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(art)
	label(button,key,Vector2(3,0),10)
	var name := label(parent,caption,at+Vector2(-8,64),12)
	name.size = Vector2(78,36)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

static func build(world: Node2D) -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	world.add_child(layer)
	var screen := Control.new()
	screen.name = "Screen"
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dock := Control.new()
	dock.name = "ResourceDock"
	dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(dock)
	dock.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	dock.offset_left = 12
	dock.offset_right = 458
	dock.offset_top = -180
	dock.offset_bottom = -10
	world.hud_dock = dock
	var backing := Panel.new()
	backing.position = Vector2(0,0)
	backing.size = Vector2(440,168)
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backing.add_theme_stylebox_override("panel",frame("071513c9","344b40",1))
	dock.add_child(backing)
	var portrait_frame := Panel.new()
	portrait_frame.position = Vector2(4,7)
	portrait_frame.size = Vector2(94,100)
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_theme_stylebox_override("panel",frame("152a29","d5b76d",3))
	dock.add_child(portrait_frame)
	var portrait := TextureRect.new()
	var crop := AtlasTexture.new()
	crop.atlas = load("res://assets/compiled/"+world.hero.asset_id+"-stand.png")
	crop.region = Rect2(70,59,58,58) if world.hero.character_class == "panda" else Rect2(75,59,48,56)
	portrait.texture = crop
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(4,4)
	portrait.size = Vector2(86,92)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(portrait)
	label(dock,"LP",Vector2(110,4),17)
	label(dock,"MP",Vector2(110,32),17)
	world.health_bar = bar(dock,Vector2(148,10),"c63732",world.hero.max_health)
	world.mana_bar = bar(dock,Vector2(148,38),"2189c3",world.hero.MAX_MANA)
	world.health_numbers = label(dock,"",Vector2(307,4),16)
	world.mana_numbers = label(dock,"",Vector2(307,32),16)
	world.shoot_button = slot(dock,Vector2(110,66),"attack","Angriff","J","Linksklick/J: Klassenangriff · Leertaste: Nahkampf")
	world.shoot_button.pressed.connect(func(): world.hero.primary_action(world.hero.aim_position(false)))
	world.heal_button = slot(dock,Vector2(190,66),"heal","Heilen","H","35 LP heilen · 20 Mana")
	world.heal_button.pressed.connect(world.hero.heal_self)
	world.summon_button = slot(dock,Vector2(270,66),"summon","Skelett\nerwecken","R","Skelett erwecken · 10 Mana · bis zu drei Begleiter")
	world.summon_button.pressed.connect(world.hero.summon_skeleton)
	world.item_button = slot(dock,Vector2(350,66),"item","Item\n(bald)","","Inventar ist noch nicht verfügbar")
	world.item_button.disabled = true
	world.item_button.modulate.a = 0.6
	world.party_label = label(dock,"",Vector2(6,118),10)
	world.party_label.size = Vector2(94,42)
	world.party_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world.party_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world.status = label(screen,"Waldpfad · Esc: Heldenwahl",Vector2.ZERO,13)
	world.status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	world.status.offset_left = -300
	world.status.offset_right = 300
	world.status.offset_top = 12
	world.status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world.summon_message = label(screen,"",Vector2.ZERO,12)
	world.summon_message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	world.summon_message.offset_left = -240
	world.summon_message.offset_right = 240
	world.summon_message.offset_top = -40
	world.summon_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world.summon_message.hide()
	world.message_timer = Timer.new()
	world.message_timer.one_shot = true
	world.message_timer.wait_time = 2.5
	world.message_timer.timeout.connect(world.summon_message.hide)
	layer.add_child(world.message_timer)
