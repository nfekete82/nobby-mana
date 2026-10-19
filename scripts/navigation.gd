extends RefCounted
## Walkable foot positions sampled against real static physics, cached per scene.
const CELL := 32
var grid := AStarGrid2D.new()
var world: Node2D
var body_shape := RectangleShape2D.new()

func _init(scene: Node2D) -> void:
	world = scene
	body_shape.size = Vector2(32,24)
	grid.region = Rect2i(0,0,48,36)
	grid.cell_size = Vector2(CELL,CELL)
	grid.offset = Vector2(CELL/2,CELL/2)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grid.update()
	for y in grid.region.size.y:
		for x in grid.region.size.x:
			var cell := Vector2i(x,y)
			grid.set_point_solid(cell, not free_at(grid.get_point_position(cell)))

func free_at(point: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body_shape
	query.transform = Transform2D(0,point + Vector2(0,-12))
	query.collision_mask = 1
	return world.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()

func clear_line(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from+Vector2(0,-12),to+Vector2(0,-12),1)
	return world.get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start := Vector2i((from / CELL).floor())
	var end := Vector2i((to / CELL).floor())
	if not grid.is_in_boundsv(start) or not grid.is_in_boundsv(end):
		return PackedVector2Array()
	if grid.is_point_solid(start) or grid.is_point_solid(end):
		return PackedVector2Array()
	var route := grid.get_point_path(start,end)
	# Never accept partial paths as evidence a target is reachable.
	if route.is_empty():
		return route
	if route.size() > 1 and from.distance_to(route[0]) < 24:
		route.remove_at(0)
	return route
