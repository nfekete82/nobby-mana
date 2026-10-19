extends SceneTree
## Authored bitmap extraction, nearest sampling and deterministic terrain seams.
const ROOT := "res://art/generated-source/reference-grove/"
const OUT := "res://assets/compiled/"

func _initialize() -> void:
	call_deferred("compile_all")

func read_png(file: String) -> Image:
	var result := Image.new()
	assert(result.load_png_from_buffer(FileAccess.get_file_as_bytes(ROOT+file)) == OK)
	result.convert(Image.FORMAT_RGBA8)
	return result

func bounds(image: Image) -> Rect2i:
	var start := image.get_size()
	var end := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a >= 0.8:
				start = start.min(Vector2i(x,y))
				end = end.max(Vector2i(x+1,y+1))
	return Rect2i(start,end-start)

func module(sheet: Image,spec: Dictionary) -> Image:
	var rectangle: Array = spec.rect
	var piece := sheet.get_region(Rect2i(rectangle[0],rectangle[1],rectangle[2],rectangle[3]))
	piece = piece.get_region(bounds(piece))
	if spec.get("rotate",false):
		piece.rotate_90(CLOCKWISE)
	var target := Vector2i(spec.fit[0],spec.fit[1])
	var factor := minf(float(target.x)/piece.get_width(),float(target.y)/piece.get_height())
	piece.resize(roundi(piece.get_width()*factor),roundi(piece.get_height()*factor),Image.INTERPOLATE_NEAREST)
	if spec.has("strip"):
		piece = piece.get_region(Rect2i((piece.get_width()-int(spec.strip))/2,0,int(spec.strip),piece.get_height()))
	var result := Image.create(spec.frame[0],spec.frame[1],false,Image.FORMAT_RGBA8)
	var at := Vector2i(int(spec.foot[0])-piece.get_width()/2,int(spec.foot[1])-piece.get_height())
	for y in piece.get_height():
		for x in piece.get_width():
			var color := piece.get_pixel(x,y)
			if color.a >= 0.8:
				color.a = 1
				result.set_pixelv(at+Vector2i(x,y),color)
	return result

func texture(sheet: Image,quadrant: Vector2i,size := 64) -> Image:
	var half := sheet.get_size()/2
	var result := sheet.get_region(Rect2i(quadrant*half,half))
	result.resize(size,size,Image.INTERPOLATE_NEAREST)
	# Copy equal opposite edge pixels so neighboring cells have no color jump.
	for index in size:
		var horizontal := result.get_pixel(0,index).lerp(result.get_pixel(size-1,index),0.5)
		result.set_pixel(0,index,horizontal)
		result.set_pixel(size-1,index,horizontal)
		var vertical := result.get_pixel(index,0).lerp(result.get_pixel(index,size-1),0.5)
		result.set_pixel(index,0,vertical)
		result.set_pixel(index,size-1,vertical)
	return result

func compile_all() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"layout.json"))
	var environment := read_png("environment.png")
	for id: String in layout.modules:
		assert(module(environment,layout.modules[id]).save_png(OUT+id+"-stand.png") == OK)
	var icons := read_png("hud-icons.png")
	for id: String in layout.icons:
		assert(module(icons,layout.icons[id]).save_png(OUT+"hud-"+id+".png") == OK)
	var terrains := read_png(layout.get("texture_source","terrain.png"))
	assert(texture(terrains,Vector2i(1,1)).save_png(OUT+"grove-stone.png") == OK)
	var grass := texture(terrains,Vector2i(0,0))
	var dirt := texture(terrains,Vector2i(1,0))
	assert(grass.save_png(OUT+"grove-grass.png") == OK)
	assert(texture(terrains,Vector2i(0,1),128).save_png(OUT+"grove-water.png") == OK)
	var paths := Image.create(192,192,false,Image.FORMAT_RGBA8)
	for ay in 3:
		for ax in 3:
			for y in 64:
				for x in 64:
					var edge := 64
					if ax == 0:
						edge = mini(edge,x)
					if ax == 2:
						edge = mini(edge,63-x)
					if ay == 0:
						edge = mini(edge,y)
					if ay == 2:
						edge = mini(edge,63-y)
					# A short pixel-hard irregular fringe uses authored grass/dirt.
					var fringe := 4+posmod(x*13+y*7,4)
					paths.set_pixel(ax*64+x,ay*64+y,grass.get_pixel(x,y) if edge < fringe else dirt.get_pixel(x,y))
	assert(paths.save_png(OUT+"grove-path.png") == OK)
	print("Compiled authored grove modules, HUD symbols and seamless 64px terrain.")
	quit()
