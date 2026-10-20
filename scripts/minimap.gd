extends Panel
## Miniature of actual scene bitmaps; fog masks every unknown pixel.
const Art = preload("res://scripts/art_library.gd")
const Exploration = preload("res://scripts/exploration.gd")
const PIXELS := 3
const TILE := 64
const REVEAL_RADIUS := 6
var world: Node2D
var store: RefCounted
var map_id: String
var map_size: Vector2i
var base_image: Image
var fog_image: Image
var map_texture: ImageTexture
var map_view: TextureRect
var player_marker: Panel
var map_scale := 1.0
var last_cell := Vector2i(-999,-999)
var elapsed := 0.0
var save_elapsed := 0.0
var image_cache: Dictionary = {}

func _ready() -> void:
	name = "Minimap"
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	map_size = world.world_size
	map_id = world.level.scene_file_path+"|%dx%d"%[map_size.x,map_size.y]
	var session := world.get_node_or_null("/root/Session")
	store = session.exploration if session != null else Exploration.new()
	if world.level.scene_file_path == "res://scenes/levels/expanded_grove.tscn":
		store.inherit_area("res://scenes/levels/reference_grove.tscn|56x40",map_id,Vector2i(56,40),map_size)
	store.ensure_map(map_id,map_size)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0b1816ed")
	style.border_color = Color("b59d63")
	style.set_border_width_all(2)
	add_theme_stylebox_override("panel",style)
	tooltip_text = "Gebietskarte · Schwarz: unerforscht · heller Punkt: deine Position"
	var title := Label.new()
	title.text = "Gebiet"
	title.position = Vector2(7,2)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size",11)
	title.add_theme_color_override("font_color",Color("eee3c4"))
	add_child(title)
	base_image = Image.create(map_size.x*PIXELS,map_size.y*PIXELS,false,Image.FORMAT_RGBA8)
	base_image.fill(Color.BLACK)
	bake_scene()
	fog_image = Image.create(base_image.get_width(),base_image.get_height(),false,Image.FORMAT_RGBA8)
	fog_image.fill(Color.BLACK)
	for y in map_size.y:
		for x in map_size.x:
			var cell := Vector2i(x,y)
			if store.is_explored(map_id,cell):
				reveal_pixels(cell)
	map_texture = ImageTexture.create_from_image(fog_image)
	map_view = TextureRect.new()
	map_scale = minf(1.0,minf(168.0/base_image.get_width(),120.0/base_image.get_height()))
	map_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_view.size = Vector2(base_image.get_size())*map_scale
	map_view.position = Vector2(6+(168-map_view.size.x)/2,20+(120-map_view.size.y)/2)
	map_view.texture = map_texture
	map_view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	map_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map_view)
	player_marker = Panel.new()
	player_marker.name = "PlayerMarker"
	player_marker.size = Vector2(5,5)
	player_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var marker_style := StyleBoxFlat.new()
	marker_style.bg_color = Color("fff5c8")
	marker_style.border_color = Color("4b311e")
	marker_style.set_border_width_all(1)
	player_marker.add_theme_stylebox_override("panel",marker_style)
	add_child(player_marker)
	update_exploration()
	# No source-file access after baking this level snapshot.
	image_cache.clear()

func bitmap(texture: Texture2D) -> Image:
	var key := texture.get_instance_id()
	if not image_cache.has(key):
		# Imported textures also work in exported games without raw source PNGs.
		var image := texture.get_image()
		assert(image != null and not image.is_empty(),"Cannot sample minimap texture")
		if image.is_compressed():
			assert(image.decompress() == OK)
		image.convert(Image.FORMAT_RGBA8)
		image_cache[key] = image
	return image_cache[key]

func bake_scene() -> void:
	# Named layers define visual order independently of editor tree order.
	for title in ["Ground","River","Paths","CliffFaces"]:
		var layer := world.level.get_node_or_null(title) as TileMapLayer
		if layer == null:
			continue
		var tile_cache: Dictionary = {}
		for cell: Vector2i in layer.get_used_cells():
			var source_id := layer.get_cell_source_id(cell)
			var atlas := layer.tile_set.get_source(source_id) as TileSetAtlasSource
			if atlas == null:
				continue
			var coord := layer.get_cell_atlas_coords(cell)
			var key := Vector3i(source_id,coord.x,coord.y)
			if not tile_cache.has(key):
				var image := bitmap(atlas.texture)
				var region := atlas.get_tile_texture_region(coord)
				var tile := image.get_region(region)
				tile.resize(PIXELS,PIXELS,Image.INTERPOLATE_NEAREST)
				tile_cache[key] = tile
			var point := layer.to_global(layer.map_to_local(cell))-Vector2(TILE/2,TILE/2)
			var at := Vector2i((point*PIXELS/TILE).floor())
			base_image.blend_rect(tile_cache[key],Rect2i(0,0,PIXELS,PIXELS),at)
	var scenery: Node = world.level.get_node_or_null("Scenery")
	if scenery == null:
		return
	var props: Array = scenery.get_children()
	props.sort_custom(func(a: Node2D,b: Node2D): return a.z_index < b.z_index if a.z_index != b.z_index else a.global_position.y < b.global_position.y)
	var registry: Dictionary = Art.registry().assets
	for prop: Node2D in props:
		var id: Variant = prop.get("asset_id")
		if id == null or not registry.has(id):
			continue
		var data: Dictionary = registry[id]
		var animation: Dictionary = data.animations.stand
		var folder := "res://assets/compiled/" if animation.get("compiled",false) else "res://assets/licensed/"
		var piece := bitmap(load(folder+str(animation.file)) as Texture2D).get_region(Rect2i(0,0,data.frame[0],data.frame[1]))
		piece.resize(maxi(1,roundi(float(data.frame[0])*PIXELS/TILE)),maxi(1,roundi(float(data.frame[1])*PIXELS/TILE)),Image.INTERPOLATE_NEAREST)
		var at := Vector2i(((prop.global_position-Vector2(data.foot[0],data.foot[1]))*PIXELS/TILE).round())
		base_image.blend_rect(piece,Rect2i(Vector2i.ZERO,piece.get_size()),at)

func reveal_pixels(cell: Vector2i) -> void:
	var rect := Rect2i(cell*PIXELS,Vector2i(PIXELS,PIXELS))
	fog_image.blit_rect(base_image,rect,rect.position)

func update_exploration() -> void:
	if not is_instance_valid(world.hero):
		return
	var hero_position: Vector2 = world.hero.global_position
	var cell := Vector2i((hero_position/TILE).floor())
	if cell != last_cell:
		last_cell = cell
		var added: Array[Vector2i] = store.reveal(map_id,cell,REVEAL_RADIUS)
		if not added.is_empty():
			for at in added:
				reveal_pixels(at)
			map_texture.update(fog_image)
	var marker_position := Vector2i((hero_position*PIXELS/TILE).round())
	marker_position = marker_position.clamp(Vector2i(2,2),base_image.get_size()-Vector2i(3,3))
	player_marker.position = map_view.position+(Vector2(marker_position)*map_scale).round()-Vector2(2,2)

func _process(delta: float) -> void:
	elapsed += delta
	save_elapsed += delta
	if elapsed >= 0.1:
		elapsed = 0
		update_exploration()
	if save_elapsed >= 5.0:
		save_elapsed = 0
		store.flush()

func _exit_tree() -> void:
	if store != null:
		store.flush()
