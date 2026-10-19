extends SceneTree
## Whole authored poses only. No native body reuse, grafting or rotated deaths.
const ROOT := "res://art/generated-source/creatures/fullbody-v2/"
const OUT := "res://assets/compiled/"
var quantized: Dictionary = {}

func _initialize() -> void:
	call_deferred("compile_all")

func raw_image(file: String) -> Image:
	var image := Image.new()
	assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(file)) == OK,"Cannot read PNG "+file)
	image.convert(Image.FORMAT_RGBA8)
	return image

func closest(color: Color,palette: Array[Color]) -> Color:
	var key := color.to_rgba32()
	if quantized.has(key):
		return quantized[key]
	var best := palette[0]
	var score := INF
	for candidate in palette:
		var distance := pow(color.r-candidate.r,2)+pow(color.g-candidate.g,2)+pow(color.b-candidate.b,2)
		if distance < score:
			score = distance
			best = candidate
	quantized[key] = best
	return best

func bounds(image: Image) -> Rect2i:
	var start := image.get_size()
	var end := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a >= 0.8:
				start = start.min(Vector2i(x,y))
				end = end.max(Vector2i(x+1,y+1))
	assert(end.x > 0,"Empty authored full-body pose")
	return Rect2i(start,end-start)

func pose(source: Image,spec: Dictionary,row: int,col: int,palette: Array[Color]) -> Image:
	var band: Array = spec.bands[row]
	var width := source.get_width()/6
	var cell := source.get_region(Rect2i(col*width,int(band[0]),width,int(band[1])-int(band[0])))
	var occupied := bounds(cell)
	# One scale for the WHOLE character across all states and facings.
	# Translate complete poses to the foot baseline; never resize limbs/heads.
	var scale: float = spec.scale
	var piece := cell.get_region(occupied)
	piece.resize(roundi(piece.get_width()*scale),roundi(piece.get_height()*scale),Image.INTERPOLATE_NEAREST)
	var at := Vector2i(96+roundi((occupied.position.x-width/2.0)*scale),132-piece.get_height())
	var result := Image.create(192,192,false,Image.FORMAT_RGBA8)
	for y in piece.get_height():
		for x in piece.get_width():
			var c := piece.get_pixel(x,y)
			if c.a >= 0.8:
				var point := at+Vector2i(x,y)
				assert(point.x > 0 and point.y > 0 and point.x < 191 and point.y < 191,"Authored pose clipped")
				result.set_pixelv(point,closest(c,palette))
	return result

func compile_all() -> void:
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"layout.json"))
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/registry.json"))
	DirAccess.make_dir_recursive_absolute(OUT)
	var palette: Array[Color] = []
	for hex: String in layout.palette:
		palette.append(Color(hex))
	for id: String in layout.characters:
		var spec: Dictionary = layout.characters[id]
		var source := raw_image(ROOT+id+".png")
		for state: String in spec.states:
			var frames: Array = spec.states[state]
			var count := frames.size()
			assert(int(registry.assets[id].animations[state].frames) == count,"Registry/source pose mismatch")
			var result := Image.create(count*192,384,false,Image.FORMAT_RGBA8)
			for facing in 2:
				for frame in count:
					var location: Array = frames[frame]
					# Optional independently reviewed rear selection avoids a malformed pose.
					if facing == 1 and spec.has("rear_overrides") and spec.rear_overrides.has(state):
						location = spec.rear_overrides[state][frame]
					var whole := pose(source,spec,int(location[0])+facing*4,int(location[1]),palette)
					result.blit_rect(whole,Rect2i(0,0,192,192),Vector2i(frame*192,facing*192))
			assert(result.save_png(OUT+id+"-"+state+".png") == OK)
	print("Compiled three complete authored characters; fixed 192px cells, common per-character scale, no native body composites.")
	quit()
