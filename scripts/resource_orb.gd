extends Range
## Compact, vertically filled resource meter. Native UI, no external artwork.
const OrbShader = preload("res://shaders/resource_orb.gdshader")
var mana_style := false
var value_label: Label
var fill_material: ShaderMaterial

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(96,96)
	fill_material = ShaderMaterial.new()
	fill_material.shader = OrbShader
	fill_material.set_shader_parameter("pixel_size",96.0)
	if mana_style:
		fill_material.set_shader_parameter("liquid",Color("285fa8"))
		fill_material.set_shader_parameter("light_liquid",Color("5797d1"))
		fill_material.set_shader_parameter("dark_liquid",Color("193856"))
	var face := ColorRect.new()
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.material = fill_material
	face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(face)
	face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	value_label = Label.new()
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_label.position = Vector2(0,38)
	value_label.size = Vector2(96,20)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size",14)
	value_label.add_theme_color_override("font_color",Color("eee2c3"))
	value_label.add_theme_color_override("font_outline_color",Color("16242d"))
	value_label.add_theme_constant_override("outline_size",4)
	add_child(value_label)
	value_changed.connect(func(_value: float): refresh())
	changed.connect(refresh)
	refresh()

func refresh() -> void:
	if fill_material == null:
		return
	fill_material.set_shader_parameter("amount",(value-min_value)/maxf(1,max_value-min_value))
	value_label.text = "%d/%d" % [int(value),int(max_value)]
	tooltip_text = ("Mana" if mana_style else "Leben") + ": " + value_label.text
