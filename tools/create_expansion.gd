extends SceneTree
## One-time additive authored district. Never loads or saves forest.tscn.
const OUT := "res://scenes/levels/woodland_village.tscn"
const Prop = preload("res://scripts/level_prop.gd")
var scene: Node2D
var props: Node2D

func _initialize() -> void:
	call_deferred("create")

func owned(node: Node,parent: Node) -> void:
	parent.add_child(node)
	node.owner = scene

func atlas(file: String,columns: int,rows: int) -> TileSet:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(64,64)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/licensed/"+file+".png")
	source.texture_region_size = Vector2i(64,64)
	tiles.add_source(source,0)
	for y in rows:
		for x in columns:
			source.create_tile(Vector2i(x,y))
	return tiles

func prop(id: String,point: Vector2,title: String) -> void:
	var body := StaticBody2D.new()
	body.name = title
	body.set_script(Prop)
	body.asset_id = id
	body.position = point
	owned(body,props)

func create() -> void:
	if FileAccess.file_exists(OUT):
		push_error("Expansion already exists. Edit the authored scene in Godot.")
		quit(1)
		return
	scene = Node2D.new()
	scene.name = "WoodlandVillage"
	scene.y_sort_enabled = true
	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.z_index = -10
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.tile_set = atlas("grass",9,6)
	owned(ground,scene)
	# One-cell overlap closes the ground seam even if the older layer was moved.
	for y in 40:
		for x in 56:
			if x >= 39 or y >= 27:
				ground.set_cell(Vector2i(x,y),0,Vector2i(1,1))
	var paths := TileMapLayer.new()
	paths.name = "Paths"
	paths.z_index = -8
	paths.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paths.tile_set = atlas("path",3,3)
	owned(paths,scene)
	var cells: Dictionary = {}
	for rectangle in [Rect2i(35,11,11,2),Rect2i(44,10,3,14),Rect2i(42,13,11,8),Rect2i(42,11,11,2),Rect2i(42,21,11,2),Rect2i(51,12,2,10),Rect2i(30,23,3,13),Rect2i(31,33,16,3),Rect2i(44,23,3,12),Rect2i(33,28,6,2)]:
		for y in range(rectangle.position.y,rectangle.end.y):
			for x in range(rectangle.position.x,rectangle.end.x):
				cells[Vector2i(x,y)] = true
	for y in range(14,18):
		for x in range(47,51):
			cells.erase(Vector2i(x,y))
	for cell: Vector2i in cells:
		var ax := 0 if not cells.has(cell+Vector2i.LEFT) else (2 if not cells.has(cell+Vector2i.RIGHT) else 1)
		var ay := 0 if not cells.has(cell+Vector2i.UP) else (2 if not cells.has(cell+Vector2i.DOWN) else 1)
		# Continuous joins to the existing eastern glade and south trail.
		if cell.x == 35 and cell.y in [11,12]:
			ax = 1
		if cell.y == 23 and cell.x in [30,31]:
			ay = 1
		paths.set_cell(cell,0,Vector2i(ax,ay))
	props = Node2D.new()
	props.name = "Scenery"
	props.y_sort_enabled = true
	owned(props,scene)
	# Houses face onto the paths. Ground-level collision does not fill the roofs.
	for item in [["house",Vector2(512,512),"TrailCottage"],["house",Vector2(2752,832),"CottageWest"],["house-large",Vector2(3008,832),"CottageNorth"],["house",Vector2(3328,896),"CottageEast"],["monastery",Vector2(3136,1152),"VillageHall"],["house-large",Vector2(2752,1408),"CottageSouthWest"],["house",Vector2(3328,1408),"CottageSouthEast"],["house-large",Vector2(2240,1984),"WoodcutterCottage"]]:
		prop(item[0],item[1],item[2])
	var trees := [Vector2(2650,500),Vector2(2800,400),Vector2(3000,480),Vector2(3220,420),Vector2(3390,560),Vector2(2630,1050),Vector2(2680,1250),Vector2(3410,1180),Vector2(2900,1610),Vector2(3100,1670),Vector2(3360,1630),Vector2(2650,1770),Vector2(2780,1850),Vector2(2940,1810),Vector2(3250,1950),Vector2(3360,2140),Vector2(2960,2250),Vector2(2740,2350),Vector2(2400,2310),Vector2(2120,2250),Vector2(1900,2370),Vector2(1700,2290),Vector2(1500,2130),Vector2(1320,2270),Vector2(1050,2090),Vector2(830,2230),Vector2(620,2080),Vector2(430,2240),Vector2(250,2000),Vector2(240,2400),Vector2(700,2400),Vector2(1140,2440),Vector2(1600,2470),Vector2(2160,2450),Vector2(3200,2420)]
	for index in trees.size():
		prop(["tree-birch","tree-oak","tree-small"][index%3],trees[index],"Grove%02d"%index)
	# Native rocks and low bushes define garden beds and the southern clearing.
	for index in 16:
		var point: Vector2 = [Vector2(2700,660),Vector2(2930,640),Vector2(3260,650),Vector2(3420,780),Vector2(2700,1510),Vector2(3260,1510),Vector2(2900,1200),Vector2(2930,1230),Vector2(2200,2130),Vector2(2290,2120),Vector2(2370,2140),Vector2(1760,2090),Vector2(1700,2120),Vector2(880,1940),Vector2(930,1955),Vector2(970,1980)][index]
		prop("rock",point,"Rock%02d"%index)
	for index in 17:
		var point: Vector2 = [Vector2(2680,870),Vector2(2810,870),Vector2(2940,880),Vector2(3060,880),Vector2(3240,1460),Vector2(3390,1450),Vector2(2720,1450),Vector2(2810,1460),Vector2(3050,1160),Vector2(3240,1170),Vector2(2310,2020),Vector2(2170,2020),Vector2(1540,1920),Vector2(1600,1940),Vector2(1280,2060),Vector2(3030,2250),Vector2(3100,2250)][index]
		prop("bush",point,"Garden%02d"%index)
	# Scene-only waypoint markers for editor and screenshot tools, not blockers.
	for item in [["VillageArrival",Vector2(2920,1088)],["SouthernClearing",Vector2(2144,2190)]]:
		var marker := Marker2D.new()
		marker.name = item[0]
		marker.position = item[1]
		owned(marker,scene)
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,OUT) == OK)
	scene.free()
	print("Saved additive village scene; original forest never opened for writing.")
	quit()
