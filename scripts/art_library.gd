extends RefCounted
## Native cells and feet from the reviewed Nobby World registry. No trimming.

static func registry() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://art/registry.json"))

static func frames_for(id: String) -> SpriteFrames:
	var data: Dictionary = registry().assets[id]
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for state: String in data.animations:
		var animation: Dictionary = data.animations[state]
		var file := "res://assets/licensed/" + str(animation.file)
		assert(ResourceLoader.exists(file), "Missing art. Run python3 tools/setup_assets.py")
		var sheet: Texture2D = load(file)
		frames.add_animation(state)
		frames.set_animation_speed(state, float(animation.fps))
		frames.set_animation_loop(state, state != "attack")
		var indices: Array = animation.get("indices", range(int(animation.frames)))
		for index: int in indices:
			var texture := AtlasTexture.new()
			texture.atlas = sheet
			texture.region = Rect2(index * int(data.frame[0]), 0, data.frame[0], data.frame[1])
			frames.add_frame(state, texture)
	return frames

static func sprite_for(id: String) -> AnimatedSprite2D:
	var data: Dictionary = registry().assets[id]
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames_for(id)
	sprite.centered = false
	sprite.position = -Vector2(data.foot[0], data.foot[1])
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.play("stand")
	return sprite
