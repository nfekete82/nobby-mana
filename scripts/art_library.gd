@tool
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
		frames.set_animation_loop(state, state in ["stand", "walk"])
		var indices: Array = animation.get("indices", range(int(animation.frames)))
		for row: int in int(animation.get("rows", 1)):
			var name := state if row == 0 else state + "_back"
			if row > 0:
				frames.add_animation(name)
				frames.set_animation_speed(name, float(animation.fps))
				frames.set_animation_loop(name, state in ["stand", "walk"])
			for index: int in indices:
				var texture := AtlasTexture.new()
				texture.atlas = sheet
				texture.region = Rect2(index * int(data.frame[0]), row * int(data.frame[1]), data.frame[0], data.frame[1])
				frames.add_frame(name, texture)
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
