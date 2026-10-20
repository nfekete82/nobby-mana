extends RefCounted
## Shared explored cells only; player state and existing maps are untouched.
var storage_path: String
var maps: Dictionary = {}
var dirty := false

func _init(path := "user://map-exploration-v1.json") -> void:
	storage_path = path
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return
	var data: Variant = json.data
	if data is Dictionary and data.get("version") == 1 and data.get("maps") is Dictionary:
		# Validate each map on first use; never trust saved dimensions/indices.
		maps = data.maps

func matches_size(saved: Variant,size: Vector2i) -> bool:
	if not saved is Dictionary:
		return false
	var dimensions: Variant = saved.get("size")
	if not dimensions is Array or dimensions.size() != 2:
		return false
	for axis in 2:
		var value: Variant = dimensions[axis]
		if not (value is int or value is float) or float(value) != float(size[axis]):
			return false
	return true

func ensure_map(id: String,size: Vector2i) -> void:
	var saved: Variant = maps.get(id)
	if matches_size(saved,size) and saved.get("seen") is Array:
		var clean: Dictionary = {}
		for index: Variant in saved.seen:
			if (index is int or index is float) and float(index) == floor(float(index)) and index >= 0 and index < size.x*size.y:
				clean[int(index)] = true
		maps[id] = {"size":[size.x,size.y],"cells":clean}
	elif not (matches_size(saved,size) and saved.get("cells") is Dictionary):
		maps[id] = {"size":[size.x,size.y],"cells":{}}

func inherit_area(old_id: String,new_id: String,old_size: Vector2i,new_size: Vector2i) -> void:
	if maps.has(new_id) or not maps.has(old_id):
		return
	ensure_map(old_id,old_size)
	ensure_map(new_id,new_size)
	for index: int in maps[old_id].cells:
		var cell := Vector2i(index%old_size.x,index/old_size.x)
		if cell.x < new_size.x and cell.y < new_size.y:
			maps[new_id].cells[cell.y*new_size.x+cell.x] = true
	dirty = true

func is_explored(id: String,cell: Vector2i) -> bool:
	if not maps.has(id):
		return false
	var data: Dictionary = maps[id]
	var size := Vector2i(data.size[0],data.size[1])
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y and data.cells.has(cell.y*size.x+cell.x)

func reveal(id: String,center: Vector2i,radius: int) -> Array[Vector2i]:
	var added: Array[Vector2i] = []
	var data: Dictionary = maps[id]
	var size := Vector2i(data.size[0],data.size[1])
	if center.x < 0 or center.y < 0 or center.x >= size.x or center.y >= size.y:
		return added
	for y in range(maxi(0,center.y-radius),mini(size.y,center.y+radius+1)):
		for x in range(maxi(0,center.x-radius),mini(size.x,center.x+radius+1)):
			var cell := Vector2i(x,y)
			var index := y*size.x+x
			if (cell-center).length_squared() <= radius*radius and not data.cells.has(index):
				data.cells[index] = true
				added.append(cell)
	if not added.is_empty():
		dirty = true
	return added

func flush() -> Error:
	if not dirty or storage_path.is_empty():
		return OK
	var output: Dictionary = {}
	for id: String in maps:
		var data: Dictionary = maps[id]
		if data.get("cells") is Dictionary:
			output[id] = {"size":data.size,"seen":data.cells.keys()}
		else:
			output[id] = data
	var temporary := storage_path+".tmp"
	var file := FileAccess.open(temporary,FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version":1,"maps":output}))
	file.close()
	var result := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),ProjectSettings.globalize_path(storage_path))
	if result == OK:
		dirty = false
	return result
