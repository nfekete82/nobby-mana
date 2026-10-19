extends SceneTree
## One-time bootstrap only. Never overwrites an authored level.
const OUT := "res://scenes/levels/forest.tscn"
const Prop = preload("res://scripts/level_prop.gd")

func _initialize() -> void:
	call_deferred("create")

func owned(node: Node, parent: Node, scene: Node) -> void:
	parent.add_child(node)
	node.owner = scene

func atlas(file: String, columns: int, rows: int, solid := false) -> TileSet:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(64,64)
	if solid:
		tiles.add_physics_layer()
		tiles.set_physics_layer_collision_layer(0,1)
		tiles.set_physics_layer_collision_mask(0,0)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/licensed/"+file+".png")
	source.texture_region_size = Vector2i(64,64)
	tiles.add_source(source,0)
	for y in rows:
		for x in columns:
			var cell := Vector2i(x,y)
			source.create_tile(cell)
			if solid:
				var data := source.get_tile_data(cell,0)
				data.set_collision_polygons_count(0,1)
				data.set_collision_polygon_points(0,0,PackedVector2Array([Vector2(-32,-32),Vector2(32,-32),Vector2(32,32),Vector2(-32,32)]))
	return tiles

func create() -> void:
	if FileAccess.file_exists(OUT):
		push_error("Level already exists. Edit it in Godot; bootstrap never overwrites it.")
		quit(1)
		return
	var scene := Node2D.new()
	scene.name = "Forest"
	scene.set_script(load("res://scripts/level_data.gd"))
	scene.y_sort_enabled = true
	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.z_index = -10
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.tile_set = atlas("grass",9,6)
	owned(ground,scene,scene)
	var path := TileMapLayer.new()
	path.name = "Paths"
	path.z_index = -9
	path.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	path.tile_set = atlas("path",3,3)
	owned(path,scene,scene)
	var cells: Dictionary = {}
	for rect in [Rect2i(4,6,16,8),Rect2i(19,9,10,2),Rect2i(27,7,9,12),Rect2i(30,18,2,7)]:
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):
				cells[Vector2i(x,y)] = true
	for y in 28:
		for x in 40:
			ground.set_cell(Vector2i(x,y),0,Vector2i(1,1))
	for cell: Vector2i in cells:
		var ax := 0 if not cells.has(cell+Vector2i.LEFT) else (2 if not cells.has(cell+Vector2i.RIGHT) else 1)
		var ay := 0 if not cells.has(cell+Vector2i.UP) else (2 if not cells.has(cell+Vector2i.DOWN) else 1)
		path.set_cell(cell,0,Vector2i(ax,ay))
	var barriers := TileMapLayer.new()
	barriers.name = "Barriers"
	barriers.tile_set = atlas("grass",3,3,true)
	barriers.modulate = Color(1,0.25,0.25,0.5)
	barriers.z_index = 30
	owned(barriers,scene,scene)
	var props := Node2D.new()
	props.name = "Scenery"
	props.y_sort_enabled = true
	owned(props,scene,scene)
	var points: Array[Vector2] = []
	for x in range(1,40,2):
		points.append(Vector2(x*64,280+(x%3)*16))
		points.append(Vector2(x*64,1730))
	for y in range(5,26,2):
		points.append(Vector2(100,y*64))
		points.append(Vector2(2470,y*64))
	for point in [Vector2(1500,1000),Vector2(1590,1080),Vector2(1470,1190),Vector2(2040,1420),Vector2(2150,1480),Vector2(930,1450),Vector2(1050,1500)]:
		points.append(point)
	for index in points.size():
		var prop := StaticBody2D.new()
		prop.set_script(Prop)
		prop.asset_id = "tree-oak" if index%3 != 0 else "tree-small"
		prop.name = "Tree%02d"%index
		prop.position = points[index]
		owned(prop,props,scene)
	for point in [Vector2(250,480),Vector2(1200,400),Vector2(310,960),Vector2(1260,910),Vector2(600,350),Vector2(2000,480),Vector2(1670,1370)]:
		var bush := StaticBody2D.new()
		bush.set_script(Prop)
		bush.asset_id = "bush"
		bush.position = point
		owned(bush,props,scene)
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector2(448,640)
	owned(spawn,scene,scene)
	var encounters := Node2D.new()
	encounters.name = "Encounters"
	owned(encounters,scene,scene)
	for index in 2:
		var marker := Marker2D.new()
		marker.name = "Warrior%d"%(index+1)
		marker.position = [Vector2(850,570),Vector2(1050,770)][index]
		owned(marker,encounters,scene)
		var sprite := Sprite2D.new()
		sprite.name = "Preview"
		var image := AtlasTexture.new()
		image.atlas = load("res://assets/licensed/enemy-warrior-stand.png")
		image.region = Rect2(0,0,192,192)
		sprite.texture = image
		sprite.centered = false
		sprite.position = Vector2(-96,-132)
		owned(sprite,marker,scene)
	var packed := PackedScene.new()
	packed.pack(scene)
	var result := ResourceSaver.save(packed,OUT)
	scene.free()
	print("Saved editable forest: ",result)
	quit(result)
