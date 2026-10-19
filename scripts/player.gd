extends "res://scripts/fighter.gd"
signal mana_changed(current: float, maximum: float)
signal companions_changed
signal summon_feedback(message: String)

const Projectile = preload("res://scripts/projectile.gd")
const Companion = preload("res://scripts/companion.gd")
const MOVE_SPEED := 225.0
const MAX_MANA := 100.0
const SUMMON_COST := 10.0
const SUMMON_LIMIT := 3
const MANA_REGEN := 5.0
const MANA_IDLE_GRACE := 0.25
var character_class := "monkey"
var shot_cooldown := 0.0
var casting_remaining := 0.0
var mana := MAX_MANA
var mana_idle_remaining := MANA_IDLE_GRACE

func _ready() -> void:
	var session := get_node_or_null("/root/Session")
	character_class = session.selected_class if session != null else "monkey"
	asset_id = {"monkey":"monkey-shaman","panda":"panda"}[character_class]
	if character_class == "panda":
		max_health = 125
		health = max_health
		attack_damage = 28
	target_group = "enemies"
	collision_layer = 2
	collision_mask = 1
	add_to_group("hero")
	add_to_group("allies")
	super._ready()
	defeated.connect(dismiss_companions)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(get_parent().get_parent().world_pixels().x)
	camera.limit_bottom = int(get_parent().get_parent().world_pixels().y)
	add_child(camera)

func _physics_process(delta: float) -> void:
	if dead:
		return
	tick_combat(delta)
	shot_cooldown = maxf(0,shot_cooldown-delta)
	casting_remaining = maxf(0,casting_remaining-delta)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if casting_remaining <= 0:
		animate_movement(direction)
	if Input.is_action_just_pressed("attack"):
		start_attack()
	if Input.is_action_just_pressed("shoot"):
		primary_action(aim_position(false))
	if Input.is_action_just_pressed("heal"):
		heal_self()
	if Input.is_action_just_pressed("summon"):
		summon_skeleton()
	velocity = direction * MOVE_SPEED * (0.0 if casting_remaining > 0 else (0.2 if attack_remaining > 0 else 1.0)) + knockback
	move_and_slide()
	regenerate_mana(delta,direction != Vector2.ZERO or attack_remaining > 0 or knockback.length() > 1 or casting_remaining > 0)

func companion_count() -> int:
	var count := 0
	for companion in get_tree().get_nodes_in_group("companions"):
		if companion.summoner == self and not companion.dead:
			count += 1
	return count

func summon_skeleton() -> bool:
	if not is_summoner():
		summon_feedback.emit("Nur der Schamane kann Skelette erwecken.")
		return false
	if dead:
		return false
	if companion_count() >= SUMMON_LIMIT:
		summon_feedback.emit("Du hast bereits drei Skelette.")
		return false
	if mana < SUMMON_COST:
		summon_feedback.emit("Nicht genug Mana (10 nötig). Im Stehen erholt es sich.")
		return false
	var world = get_parent().get_parent()
	var point: Variant = world.summon_position(global_position)
	if point == null:
		summon_feedback.emit("Kein freier Platz für ein Skelett in deiner Nähe.")
		return false
	var companion := Companion.new()
	companion.summoner = self
	# Use an unoccupied formation slot when an earlier companion has died.
	var occupied: Array[int] = []
	for ally in get_tree().get_nodes_in_group("companions"):
		if ally.summoner == self:
			occupied.append(ally.slot)
	for index in SUMMON_LIMIT:
		if index not in occupied:
			companion.slot = index
			break
	companion.position = point
	get_parent().add_child(companion)
	casting_remaining = float(sprite.sprite_frames.get_frame_count("heal"))/sprite.sprite_frames.get_animation_speed("heal")
	sprite.play(animation_for("heal"))
	mana -= SUMMON_COST
	mana_idle_remaining = MANA_IDLE_GRACE
	mana_changed.emit(mana,MAX_MANA)
	companions_changed.emit()
	summon_feedback.emit("Skelett erweckt – es kämpft zwei Minuten an deiner Seite.")
	return true

func heal_self() -> bool:
	if dead or health >= max_health or mana < 20:
		return false
	mana -= 20
	var restored := mini(35,max_health-health)
	health += restored
	mana_idle_remaining = MANA_IDLE_GRACE
	if sprite.sprite_frames.has_animation("heal"):
		casting_remaining = 1.2
		sprite.play(animation_for("heal"))
	health_changed.emit(health,max_health)
	mana_changed.emit(mana,MAX_MANA)
	summon_feedback.emit("+%d LP · 20 Mana" % restored)
	return true

func regenerate_mana(delta: float, active: bool) -> void:
	if dead:
		return
	if active:
		mana_idle_remaining = MANA_IDLE_GRACE
		return
	var before := mana_idle_remaining
	mana_idle_remaining = maxf(0,mana_idle_remaining-delta)
	var elapsed := maxf(0,delta-before)
	if elapsed > 0 and mana < MAX_MANA:
		mana = minf(MAX_MANA,mana+MANA_REGEN*elapsed)
		mana_changed.emit(mana,MAX_MANA)

func dismiss_companions() -> void:
	for companion in get_tree().get_nodes_in_group("companions"):
		if companion.summoner == self:
			companion.dismiss()

func aim_position(mouse_aim := true) -> Vector2:
	var mouse := get_global_mouse_position()
	if mouse_aim and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var near_mouse := 90.0
		var aimed: Variant = null
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var distance: float = mouse.distance_to(enemy.global_position+Vector2(0,-40))
			if distance < near_mouse:
				near_mouse = distance
				aimed = enemy.global_position
		return aimed if aimed != null else mouse
	var nearest := 600.0
	var point := global_position+facing*600
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance < nearest:
			nearest = distance
			point = enemy.global_position
	return point

func primary_action(point: Vector2) -> bool:
	if character_class != "panda":
		return shoot_at(point)
	if dead or hurt_remaining > 0 or attack_remaining > 0:
		return false
	var direction := global_position.direction_to(point)
	if direction != Vector2.ZERO:
		facing = direction
	start_attack()
	return attack_remaining > 0

func shoot_at(point: Vector2) -> bool:
	if character_class != "monkey" or dead or hurt_remaining > 0 or shot_cooldown > 0 or attack_remaining > 0:
		return false
	facing = global_position.direction_to(point)
	if facing == Vector2.ZERO:
		facing = Vector2.RIGHT
	var arrow := Projectile.new()
	arrow.caster = self
	arrow.arcane = false
	arrow.damage = 18
	arrow.direction = facing
	arrow.position = global_position+Vector2(0,-12)
	get_parent().add_child(arrow)
	shot_cooldown = 0.45
	casting_remaining = 0.4
	mana_idle_remaining = MANA_IDLE_GRACE
	sprite.flip_h = facing.x < 0
	sprite.play(animation_for("attack"))
	return true

func is_summoner() -> bool:
	return character_class == "monkey"

func display_name() -> String:
	return {"monkey":"Affen-Schamane","panda":"Panda-Kämpferin"}[character_class]

func take_damage(amount: int, origin: Vector2) -> void:
	var before := health
	super.take_damage(amount,origin)
	if health < before:
		casting_remaining = 0

func start_attack() -> void:
	if dead or hurt_remaining > 0:
		return
	casting_remaining = 0
	super.start_attack()
