extends SceneTree
## New authored map, isolated from the user's older hand-edited scenes.
const OUT := "res://scenes/levels/reference_grove.tscn"
const Prop = preload("res://scripts/level_prop.gd")
var scene: Node2D
var scenery: Node2D
var paths: Dictionary = {}

func _initialize() -> void:
	call_deferred("create")

func owned(node: Node,parent: Node) -> void:
	parent.add_child(node)
	node.owner = scene

func tiles(file: String,columns: int,rows: int,solid := false) -> TileSet:
	var result := TileSet.new()
	result.tile_size = Vector2i(64,64)
	if solid:
		result.add_physics_layer()
		result.set_physics_layer_collision_layer(0,1)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load("res://assets/compiled/"+file+".png")
	atlas.texture_region_size = Vector2i(64,64)
	result.add_source(atlas,0)
	for y in rows:
		for x in columns:
			var cell := Vector2i(x,y)
			atlas.create_tile(cell)
			if solid:
				var data := atlas.get_tile_data(cell,0)
				data.set_collision_polygons_count(0,1)
				data.set_collision_polygon_points(0,0,PackedVector2Array([Vector2(-32,-32),Vector2(32,-32),Vector2(32,32),Vector2(-32,32)]))
	return result

func layer(title: String,file: String,columns: int,rows: int,z: int,solid := false) -> TileMapLayer:
	var node := TileMapLayer.new()
	node.name = title
	node.z_index = z
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.tile_set = tiles(file,columns,rows,solid)
	owned(node,scene)
	return node

func prop(id: String,point: Vector2,title: String) -> void:
	var node := StaticBody2D.new()
	node.set_script(Prop)
	node.name = title
	node.asset_id = "grove-"+id
	node.position = point
	owned(node,scenery)

func route(rectangle: Rect2i) -> void:
	for y in range(rectangle.position.y,rectangle.end.y):
		for x in range(rectangle.position.x,rectangle.end.x):
			paths[Vector2i(x,y)] = true

func create() -> void:
	if FileAccess.file_exists(OUT):
		push_error("Reference grove already exists; edit it in Godot. No overwriting.")
		quit(1)
		return
	scene = Node2D.new()
	scene.name = "ReferenceGrove"
	scene.set_script(load("res://scripts/level_data.gd"))
	scene.include_village = false
	scene.include_goblin_camp = false
	scene.y_sort_enabled = true
	var ground := layer("Ground","grove-grass",1,1,-10)
	var water := layer("River","grove-water",2,2,-9)
	var material := ShaderMaterial.new()
	material.shader = load("res://shaders/river.gdshader")
	water.material = material
	var cliff_faces := layer("CliffFaces","grove-stone",1,1,-7,true)
	var road := layer("Paths","grove-path",3,3,-8)
	var barriers := layer("Barriers","grove-grass",1,1,30,true)
	barriers.modulate = Color(1,0.2,0.2,0.4)
	for y in 40:
		for x in 56:
			ground.set_cell(Vector2i(x,y),0,Vector2i.ZERO)
			if x >= 24 and x <= 29:
				water.set_cell(Vector2i(x,y),0,Vector2i(x%2,y%2))
				if y not in [17,18]:
					barriers.set_cell(Vector2i(x,y),0,Vector2i.ZERO)
	for y in 40:
		if y not in [17,18]:
			cliff_faces.set_cell(Vector2i(23,y),0,Vector2i.ZERO)
			cliff_faces.set_cell(Vector2i(30,y),0,Vector2i.ZERO)
	for y in range(2,5):
		for x in range(24,30):
			if x not in [26,27]:
				cliff_faces.set_cell(Vector2i(x,y),0,Vector2i.ZERO)
	for rectangle in [Rect2i(4,8,15,4),Rect2i(11,5,3,14),Rect2i(12,17,23,2),Rect2i(32,14,17,3),Rect2i(40,11,3,15),Rect2i(34,23,12,3),Rect2i(19,18,3,17),Rect2i(20,32,28,3),Rect2i(45,24,3,10),Rect2i(6,7,3,4),Rect2i(33,15,3,10)]:
		route(rectangle)
	for cell: Vector2i in paths:
		if cell.x >= 24 and cell.x <= 29:
			continue
		var ax := 0 if not paths.has(cell+Vector2i.LEFT) else (2 if not paths.has(cell+Vector2i.RIGHT) else 1)
		var ay := 0 if not paths.has(cell+Vector2i.UP) else (2 if not paths.has(cell+Vector2i.DOWN) else 1)
		road.set_cell(cell,0,Vector2i(ax,ay))
	scenery = Node2D.new()
	scenery.name = "Scenery"
	scenery.y_sort_enabled = true
	owned(scenery,scene)
	prop("house",Vector2(832,1100),"StartCottage")
	prop("house",Vector2(2624,960),"RiverCottage")
	prop("house",Vector2(2944,960),"EasternCottage")
	prop("house",Vector2(2752,1500),"GardenCottage")
	prop("house",Vector2(2304,2016),"Woodcutter")
	prop("bridge",Vector2(1728,1248),"RiverBridge")
	# Deck is drawn below actors; water collision remains open only here.
	scenery.get_node("RiverBridge").z_index = -4
	prop("waterfall",Vector2(1728,400),"Waterfall")
	prop("cliff",Vector2(1600,320),"CascadeWest")
	prop("cliff",Vector2(1856,320),"CascadeEast")
	for y in range(70,2560,62):
		if y > 1040 and y < 1290:
			continue
		for x in [1540,1916]:
			prop("foam",Vector2(x,y),"Foam%d_%d"%[x,y])
			scenery.get_node("Foam%d_%d"%[x,y]).z_index = -5
	for y in range(190,2560,158):
		if y >= 960 and y <= 1370:
			continue
		prop("cliff",Vector2(1472,y),"WestBank%d"%y)
		prop("cliff",Vector2(1984,y+50),"EastBank%d"%y)
	# Dense designed forest: no trunks in paths, doors or fight/test clearances.
	var index := 0
	for y in range(190,2560,146):
		for x in range(105,3584,150):
			var point := Vector2(x+posmod(y,41)-20,y+posmod(x,37)-18)
			var cell := Vector2i(point/64)
			if point.x > 1370 and point.x < 2080:
				continue
			var near_road := false
			for dy in range(-1,2):
				for dx in range(-1,2):
					if paths.has(cell+Vector2i(dx,dy)):
						near_road = true
			if near_road:
				continue
			if Rect2(330,330,350,260).has_point(point) or Rect2(2460,650,630,420).has_point(point) or Rect2(2560,1210,380,400).has_point(point) or Rect2(2100,1730,400,400).has_point(point):
				continue
			prop("tree",point,"Canopy%03d"%index)
			index += 1
	# Flowers hug paths rather than forming random obstacles.
	index = 0
	for cell: Vector2i in paths:
		if cell.x >= 23 and cell.x <= 30:
			continue
		if posmod(cell.x*7+cell.y*11,5) != 0:
			continue
		for side in [Vector2i.LEFT,Vector2i.RIGHT]:
			if not paths.has(cell+side):
				prop("flowers",Vector2(cell*64)+Vector2(32,48)+Vector2(side)*50,"Blooms%03d"%index)
				index += 1
	for item in [[Vector2(332,580),"CottageFence"],[Vector2(690,580),"GardenFence"],[Vector2(2500,1040),"EastFence"],[Vector2(2870,1550),"SouthFence"]]:
		prop("fence",item[0],item[1])
	for item in [[Vector2(1350,700),"RiverChest"],[Vector2(2850,1920),"WoodlandChest"]]:
		prop("chest",item[0],item[1])
	for index_bush in 20:
		var point := Vector2(260+posmod(index_bush*317,3000),320+posmod(index_bush*223,2000))
		if point.x > 1330 and point.x < 2130:
			continue
		if not paths.has(Vector2i(point/64)):
			prop("bush",point,"Hedge%02d"%index_bush)
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector2(1240,1120)
	owned(spawn,scene)
	var encounters := Node2D.new()
	encounters.name = "Encounters"
	owned(encounters,scene)
	for item in [["Warrior1","warrior",Vector2(850,570)],["Warrior2","warrior",Vector2(1050,770)],["ScoutWest","goblin-scout",Vector2(1300,1420)],["BruteWest","goblin-brute",Vector2(1310,1490)],["ScoutEast","goblin-scout",Vector2(2160,1100)],["BruteEast","goblin-brute",Vector2(2650,1530)]]:
		var marker := Marker2D.new()
		marker.name = item[0]
		marker.position = item[2]
		marker.set_script(load("res://scripts/encounter_marker.gd"))
		marker.enemy_kind = item[1]
		owned(marker,encounters)
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,OUT) == OK)
	scene.free()
	print("Saved complete reference grove: dense forest, river, crossing, waterfall and cottages.")
	quit()
