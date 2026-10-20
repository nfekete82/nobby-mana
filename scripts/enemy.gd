extends "res://scripts/fighter.gd"

const MOVE_SPEED := 105.0
const AGGRO_RADIUS := 290.0
const LEASH_RADIUS := 390.0
const DEFEAT_FADE := 0.3
@export_enum("warrior","goblin-scout","goblin-brute") var enemy_kind := "warrior"
@export_range(1,50) var enemy_level := 1
var move_speed := MOVE_SPEED
var health_bar: ProgressBar
var home := Vector2.ZERO
var attack_delay := 0.8
var target: CharacterBody2D
var route := PackedVector2Array()
var repath_remaining := 0.0

func _ready() -> void:
	asset_id = "enemy-warrior" if enemy_kind == "warrior" else enemy_kind
	if enemy_kind != "warrior":
		max_health = 45 if enemy_kind == "goblin-scout" else 75
		health = max_health
		attack_damage = 10 if enemy_kind == "goblin-scout" else 18
		move_speed = 135 if enemy_kind == "goblin-scout" else 95
	max_health = roundi(max_health*(1.0+ENEMY_HEALTH_PER_LEVEL*(enemy_level-1)))
	health = max_health
	attack_damage += ENEMY_DAMAGE_PER_LEVEL*(enemy_level-1)
	target_group = "allies"
	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")
	super._ready()
	home = global_position
	build_health_bar()
	health_changed.connect(update_health_bar)
	defeated.connect(disappear)

func build_health_bar() -> void:
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.position = Vector2(-24,-101 if enemy_kind == "warrior" else -83)
	health_bar.size = Vector2(48,6)
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.show_percentage = false
	health_bar.add_theme_font_size_override("font_size",1)
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_bar.z_index = 10
	var background := StyleBoxFlat.new()
	background.bg_color = Color("16242d")
	background.border_color = Color("293544")
	background.set_border_width_all(1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("bd464a")
	health_bar.add_theme_stylebox_override("background",background)
	health_bar.add_theme_stylebox_override("fill",fill)
	add_child(health_bar)
	health_bar.size = Vector2(48,6)
	if enemy_level > 1:
		var rank := Label.new()
		rank.text = "Lv.%d" % enemy_level
		rank.position = health_bar.position+Vector2(12,-15)
		rank.add_theme_font_size_override("font_size",10)
		rank.add_theme_color_override("font_color",Color("f2ead1"))
		rank.add_theme_color_override("font_outline_color",Color("16242d"))
		rank.add_theme_constant_override("outline_size",3)
		rank.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rank.name = "LevelLabel"
		add_child(rank)

func update_health_bar(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_bar.visible = current > 0

func disappear() -> void:
	health_bar.hide()
	if has_node("LevelLabel"):
		get_node("LevelLabel").hide()
	remove_from_group("enemies")
	# The supplied warrior has no death sheet: a short fade leaves no corpse.
	var tween := create_tween()
	if sprite.sprite_frames.has_animation("death"):
		sprite.modulate = Color.WHITE
		sprite.play(animation_for("death"))
		tween.tween_interval(0.5)
	tween.tween_property(self,"modulate:a",0.0,DEFEAT_FADE)
	tween.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	if dead:
		return
	tick_combat(delta)
	attack_delay = maxf(0, attack_delay - delta)
	repath_remaining -= delta
	var world = get_parent().get_parent()
	if repath_remaining <= 0:
		repath_remaining = 0.25
		choose_target(world)
	var direction := Vector2.ZERO
	if is_instance_valid(target) and not target.dead and global_position.distance_to(target.global_position) < 78 and world.navigation().clear_line(global_position,target.global_position):
		facing = global_position.direction_to(target.global_position)
		if attack_delay <= 0:
			start_attack()
			attack_delay = 1.3
	else:
		while not route.is_empty() and global_position.distance_to(route[0]) < 9:
			route.remove_at(0)
		if not route.is_empty():
			direction = global_position.direction_to(route[0])
	animate_movement(direction)
	velocity = direction * move_speed * (0.0 if attack_remaining > 0 else 1.0) + knockback
	move_and_slide()

func choose_target(world: Node2D) -> void:
	target = null
	route = PackedVector2Array()
	var nav = world.navigation()
	var nearest := AGGRO_RADIUS
	if global_position.distance_to(home) < LEASH_RADIUS:
		for ally in get_tree().get_nodes_in_group("allies"):
			var distance := global_position.distance_to(ally.global_position)
			if ally.dead or distance > nearest:
				continue
			var candidate: PackedVector2Array = nav.path(global_position,ally.global_position)
			if not candidate.is_empty():
				target = ally
				nearest = distance
				route = candidate
	if target == null and global_position.distance_to(home) > 8:
		route = nav.path(global_position,home)
