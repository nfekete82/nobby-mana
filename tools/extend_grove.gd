extends SceneTree
## One-time additive copy: never regenerate or overwrite an existing map.
const OUT := "res://scenes/levels/expanded_grove.tscn"
var scene: Node2D
var scenery: Node2D
var paths: Dictionary = {}

func _initialize() -> void:
	call_deferred("extend")

func owned(node: Node,parent: Node) -> void:
	parent.add_child(node)
	node.owner = scene

func prop(id: String,point: Vector2,title: String,z := 0) -> void:
	var node := StaticBody2D.new()
	node.set_script(load("res://scripts/level_prop.gd"))
	node.name = title
	node.asset_id = "grove-"+id
	node.position = point
	node.z_index = z
	owned(node,scenery)

func route(rect: Rect2i) -> void:
	for y in range(rect.position.y,rect.end.y):
		for x in range(rect.position.x,rect.end.x):
			paths[Vector2i(x,y)] = true

func encounter(title: String,kind: String,cell: Vector2i,rank: int) -> void:
	var marker := Marker2D.new()
	marker.set_script(load("res://scripts/encounter_marker.gd"))
	marker.name = title
	marker.enemy_kind = kind
	marker.enemy_level = rank
	marker.position = Vector2(cell*64)+Vector2(32,40)
	owned(marker,scene.get_node("Encounters"))

func extend() -> void:
	if FileAccess.file_exists(OUT):
		push_error("Expanded grove already exists; edit in Godot. Refusing overwrite.")
		quit(1)
		return
	scene = load("res://scenes/levels/reference_grove.tscn").instantiate()
	scene.map_tiles = Vector2i(56,80)
	scenery = scene.get_node("Scenery")
	var ground: TileMapLayer = scene.get_node("Ground")
	var river: TileMapLayer = scene.get_node("River")
	var barriers: TileMapLayer = scene.get_node("Barriers")
	var cliff: TileMapLayer = scene.get_node("CliffFaces")
	var road: TileMapLayer = scene.get_node("Paths")
	for cell: Vector2i in road.get_used_cells():
		paths[cell] = true
	for rect in [Rect2i(19,34,3,39),Rect2i(40,33,3,40),Rect2i(7,44,15,3),Rect2i(10,44,3,18),Rect2i(11,59,32,2),Rect2i(7,70,15,3),Rect2i(35,47,14,3),Rect2i(34,69,15,3),Rect2i(33,60,3,11)]:
		route(rect)
	for y in range(40,80):
		for x in 56:
			var cell := Vector2i(x,y)
			ground.set_cell(cell,0,Vector2i.ZERO)
			if x >= 24 and x <= 29:
				river.set_cell(cell,0,Vector2i(x%2,y%2))
				if y not in [59,60]:
					barriers.set_cell(cell,0,Vector2i.ZERO)
		if y not in [59,60]:
			cliff.set_cell(Vector2i(23,y),0,Vector2i.ZERO)
			cliff.set_cell(Vector2i(30,y),0,Vector2i.ZERO)
	# Update seam/connected edge cells only. Northern roads otherwise identical.
	for cell: Vector2i in paths:
		if cell.y < 33 or (cell.x >= 24 and cell.x <= 29):
			continue
		var ax := 0 if not paths.has(cell+Vector2i.LEFT) else (2 if not paths.has(cell+Vector2i.RIGHT) else 1)
		var ay := 0 if not paths.has(cell+Vector2i.UP) else (2 if not paths.has(cell+Vector2i.DOWN) else 1)
		road.set_cell(cell,0,Vector2i(ax,ay))
	prop("bridge",Vector2(1728,3936),"SouthRiverBridge",-4)
	for item in [["SouthWestCottage",Vector2(704,2880)],["SouthEastCottage",Vector2(2688,3008)],["ForestLodge",Vector2(704,4480)],["RangerCottage",Vector2(2688,4416)]]:
		prop("house",item[1],item[0])
	for y in range(2610,5120,158):
		if y > 3650 and y < 4060:
			continue
		prop("cliff",Vector2(1472,y),"SouthWestBank%d"%y)
		prop("cliff",Vector2(1984,y+50),"SouthEastBank%d"%y)
	for y in range(2610,5120,62):
		if y > 3750 and y < 3980:
			continue
		for x in [1540,1916]:
			prop("foam",Vector2(x,y),"SouthFoam%d_%d"%[x,y],-5)
	var index := 0
	for y in range(2630,5050,146):
		for x in range(105,3500,150):
			var point := Vector2(x+posmod(y,41)-20,y+posmod(x,37)-18)
			if point.x > 1360 and point.x < 2090:
				continue
			var near := false
			var cell := Vector2i(point/64)
			for dy in range(-2,3):
				for dx in range(-2,3):
					if paths.has(cell+Vector2i(dx,dy)):
						near = true
			for home in [Vector2(704,2880),Vector2(2688,3008),Vector2(704,4480),Vector2(2688,4416)]:
				if Rect2(home-Vector2(200,320),Vector2(400,450)).has_point(point):
					near = true
			if not near:
				prop("tree",point,"SouthCanopy%03d"%index)
				index += 1
	index = 0
	for cell: Vector2i in paths:
		if cell.y < 40 or cell.x in range(23,31) or posmod(cell.x*7+cell.y*11,5) != 0:
			continue
		for side in [Vector2i.LEFT,Vector2i.RIGHT]:
			if not paths.has(cell+side):
				prop("flowers",Vector2(cell*64)+Vector2(32,48)+Vector2(side)*50,"SouthBlooms%03d"%index)
				index += 1
	prop("chest",Vector2(820,4370),"SouthWoodlandChest")
	prop("chest",Vector2(2840,4320),"RangerChest")
	# Four extra northern encounters, eighteen in the extension. Start stays safe.
	var positions := [Vector2i(20,24),Vector2i(20,30),Vector2i(41,23),Vector2i(45,32),Vector2i(20,39),Vector2i(20,43),Vector2i(12,45),Vector2i(11,49),Vector2i(20,49),Vector2i(20,54),Vector2i(12,59),Vector2i(20,60),Vector2i(20,66),Vector2i(12,71),Vector2i(20,72),Vector2i(41,39),Vector2i(41,45),Vector2i(46,48),Vector2i(41,53),Vector2i(41,60),Vector2i(34,65),Vector2i(41,71)]
	for i in positions.size():
		var rank := 1 if i < 4 else (2 if positions[i].y < 59 else 3)
		encounter("ExpansionEncounter%02d"%i,"goblin-brute" if i%3 == 2 else "goblin-scout",positions[i],rank)
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,OUT) == OK)
	scene.free()
	print("Saved additive 56x80 grove with 28 encounters; original scene preserved.")
	quit()
