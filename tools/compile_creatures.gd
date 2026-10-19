extends SceneTree
## Deterministic pixel compilation: native motion, generated identity parts.
const ROOT := "res://art/generated-source/creatures/"
const OUT := "res://assets/compiled/"
var monkey_palette: Array[Color] = [Color8(22,28,46),Color8(83,54,47),Color8(139,93,60),Color8(186,133,79),Color8(200,168,118),Color8(239,225,171),Color8(61,145,137),Color8(38,81,92)]
var goblin_palette: Array[Color] = [Color8(22,28,46),Color8(45,73,57),Color8(64,95,63),Color8(88,115,69),Color8(139,168,110),Color8(172,187,111),Color8(211,215,148),Color8(239,225,171),Color8(83,54,47),Color8(146,65,89)]
var quantized: Dictionary = {}

func _initialize() -> void:
	call_deferred("compile_all")

func raw_image(file: String) -> Image:
	var image := Image.new()
	assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(file)) == OK,"Cannot read PNG "+file)
	return image

func native(file: String) -> Image:
	var image := raw_image("res://assets/licensed/"+file)
	assert(image != null and not image.is_empty(),"Missing local input "+file)
	image.convert(Image.FORMAT_RGBA8)
	return image

func closest(color: Color,palette: Array[Color],family: String) -> Color:
	var key := family+str(color.to_rgba32())
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

func part(sheet: Image,cell: Vector2i,target: Vector2i,palette: Array[Color],family: String) -> Image:
	var half := sheet.get_size()/2
	var piece := sheet.get_region(Rect2i(cell*half,half))
	# Alpha bounds first; normalize once in compilation, never at runtime.
	var bounds := Rect2i(half,Vector2i.ZERO)
	var end := Vector2i.ZERO
	for y in piece.get_height():
		for x in piece.get_width():
			if piece.get_pixel(x,y).a > 0.5:
				bounds.position = bounds.position.min(Vector2i(x,y))
				end = end.max(Vector2i(x+1,y+1))
	assert(end.x > 0 and end.y > 0,"Empty generated part")
	bounds.size = end-bounds.position
	piece = piece.get_region(bounds)
	var scale := minf(float(target.x)/piece.get_width(),float(target.y)/piece.get_height())
	piece.resize(maxi(1,roundi(piece.get_width()*scale)),maxi(1,roundi(piece.get_height()*scale)),Image.INTERPOLATE_NEAREST)
	var result := Image.create(target.x,target.y,false,Image.FORMAT_RGBA8)
	var at := Vector2i((target.x-piece.get_width())/2,target.y-piece.get_height())
	for y in piece.get_height():
		for x in piece.get_width():
			var color := piece.get_pixel(x,y)
			if color.a >= 0.5:
				result.set_pixelv(at+Vector2i(x,y),closest(color,palette,family))
	return result

func stamp(to: Image,from: Image,at: Vector2i,mirror := false) -> void:
	for y in from.get_height():
		for x in from.get_width():
			var color := from.get_pixel(x,y)
			var point := at+Vector2i(from.get_width()-1-x if mirror else x,y)
			assert(point.x >= 0 and point.y >= 0 and point.x < to.get_width() and point.y < to.get_height(),"Part outside cell")
			if color.a >= 0.5:
				to.set_pixelv(point,color)

func opaque_pose(sheet: Image,index: int,row := 0) -> Image:
	var image := sheet.get_region(Rect2i(index*192,row*192,192,192))
	for y in 192:
		for x in 192:
			var color := image.get_pixel(x,y)
			image.set_pixel(x,y,Color(color.r,color.g,color.b,1) if color.a > 0.99 else Color.TRANSPARENT)
	return image

func skin_top(image: Image,start: int) -> int:
	var top := 192
	for y in range(start,105):
		for x in range(84,116):
			var c := image.get_pixel(x,y)
			if c.a == 1 and ((c.r8 == 239 and c.g8 == 225 and c.b8 == 171) or (c.r8 == 200 and c.g8 == 168 and c.b8 == 118)):
				top = mini(top,y)
	return top

func monkey_top(image: Image) -> int:
	var top := 192
	for y in range(40,100):
		for x in range(72,120):
			var c := image.get_pixel(x,y)
			if c.a == 1 and ((c.r8 == 83 and c.g8 == 54 and c.b8 == 47) or (c.r8 == 139 and c.g8 == 93 and c.b8 == 60) or (c.r8 == 186 and c.g8 == 133 and c.b8 == 79)):
				top = mini(top,y)
	return top

func fallen(pose: Image) -> Image:
	var result := Image.create(192,192,false,Image.FORMAT_RGBA8)
	var max_x := 0
	for y in 192:
		for x in 192:
			if pose.get_pixel(x,y).a == 1:
				max_x = maxi(max_x,x)
	for y in 192:
		for x in 192:
			var color := pose.get_pixel(x,y)
			if color.a == 1:
				var at := Vector2i(96+105-y,132-max_x+x)
				assert(at.x >= 0 and at.x < 192 and at.y >= 0 and at.y < 192)
				result.set_pixelv(at,color)
	return result

func compile_monkey() -> void:
	var source := raw_image(ROOT+"monkey-parts.png")
	var front := part(source,Vector2i(0,0),Vector2i(52,44),monkey_palette,"monkey")
	var rear := part(source,Vector2i(1,0),Vector2i(52,44),monkey_palette,"monkey")
	var closed := part(source,Vector2i(0,1),Vector2i(52,44),monkey_palette,"monkey")
	var tail := part(source,Vector2i(1,1),Vector2i(23,28),monkey_palette,"monkey")
	var states := {"stand":6,"walk":4,"attack":6,"heal":11,"hit":2,"death":4}
	for state: String in states:
		var count: int = states[state]
		var sheet := native("shaman-"+state+".png")
		var result := Image.create(count*192,384,false,Image.FORMAT_RGBA8)
		for row in 2:
			for index in count:
				var body := opaque_pose(sheet,index,row)
				if state == "death":
					body = raw_image(OUT+"monkey-shaman-stand.png").get_region(Rect2i(mini(index,1)*192,row*192,192,192))
					if index >= 2:
						body = fallen(body)
				else:
					# The head follows the exact native scalp bob in every pose.
					var top := monkey_top(body)
					var dy := top-58 if top < 100 else 0
					for y in range(35,105+dy):
						for x in range(68,125):
							body.set_pixel(x,y,Color.TRANSPARENT)
					var composed := Image.create(192,192,false,Image.FORMAT_RGBA8)
					stamp(composed,tail,Vector2i(124 if row == 1 else 46,97+int([0,1,0,-1][index%4])),row == 1)
					stamp(composed,body,Vector2i.ZERO)
					stamp(composed,rear if row == 1 else (closed if state == "heal" and index >= 3 and index <= 8 else front),Vector2i(68,61+dy))
					body = composed
				result.blit_rect(body,Rect2i(0,0,192,192),Vector2i(index*192,row*192))
		assert(result.save_png(OUT+"monkey-shaman-"+state+".png") == OK)

func recolor_goblin(c: Color,variant: String) -> Color:
	var color := Vector3i(c.r8,c.g8,c.b8)
	if color == Vector3i(231,97,97):
		return Color8(139,168,110) if variant == "scout" else Color8(186,133,79)
	if color == Vector3i(146,65,89):
		return Color8(64,95,63) if variant == "scout" else Color8(83,54,47)
	if color == Vector3i(200,168,118):
		return Color8(88,115,69)
	if color == Vector3i(239,225,171):
		return Color8(172,187,111)
	return c

func compile_goblins() -> void:
	var source := raw_image(ROOT+"goblin-parts.png")
	var front := part(source,Vector2i(0,0),Vector2i(46,34),goblin_palette,"goblin")
	var rear := part(source,Vector2i(1,0),Vector2i(46,34),goblin_palette,"goblin")
	var angry := part(source,Vector2i(0,1),Vector2i(46,34),goblin_palette,"goblin")
	var hurt := part(source,Vector2i(1,1),Vector2i(46,34),goblin_palette,"goblin")
	var states := {"stand":["stand",[0,2,4,6]],"walk":["walk",[0,1,2,3,4,5]],"attack":["attack",[0,1,2,3]],"hit":["stand",[0,1]],"death":["stand",[0,1,1,1]]}
	for variant in ["scout","brute"]:
		for state: String in states:
			var spec: Array = states[state]
			var poses: Array = spec[1]
			var sheet := native("enemy-warrior-"+str(spec[0])+".png")
			var result := Image.create(poses.size()*192,384,false,Image.FORMAT_RGBA8)
			for row in 2:
				for index in poses.size():
					var body := opaque_pose(sheet,poses[index])
					var top := skin_top(body,60)
					var dy := clampi(top-74,-7,7) if top < 105 else 0
					for y in 192:
						for x in 192:
							var preserve_weapon := x >= 120 and x >= 119+(100-y)*0.5
							var preserve_shield := x < 80 and y >= 92+dy
							if y < 100+dy and y >= 30 and x >= 60 and x <= 129 and not preserve_weapon and not preserve_shield:
								body.set_pixel(x,y,Color.TRANSPARENT)
							elif body.get_pixel(x,y).a == 1:
								body.set_pixel(x,y,recolor_goblin(body.get_pixel(x,y),variant))
					if row == 1:
						body.flip_x()
					stamp(body,rear if row == 1 else (angry if state == "attack" else (hurt if state == "hit" else front)),Vector2i(72,66+dy))
					if state == "death" and index >= 2:
						body = fallen(body)
					result.blit_rect(body,Rect2i(0,0,192,192),Vector2i(index*192,row*192))
			assert(result.save_png(OUT+"goblin-"+variant+"-"+state+".png") == OK)

func compile_all() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	compile_monkey()
	compile_goblins()
	print("Compiled monkey shaman and two goblin variants with native motion.")
	quit()
