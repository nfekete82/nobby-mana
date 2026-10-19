extends "res://scripts/fighter.gd"
signal mana_changed(current: float, maximum: float)
signal companions_changed
signal summon_feedback(message: String)

const Companion = preload("res://scripts/companion.gd")
const MOVE_SPEED := 225.0
const MAX_MANA := 100.0
const SUMMON_COST := 10.0
const SUMMON_LIMIT := 3
const MANA_REGEN := 5.0
const MANA_IDLE_GRACE := 0.25
var mana := MAX_MANA
var mana_idle_remaining := MANA_IDLE_GRACE

func _ready() -> void:
	asset_id = "hero"
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
	camera.limit_right = 1536
	camera.limit_bottom = 1152
	add_child(camera)

func _physics_process(delta: float) -> void:
	if dead:
		return
	tick_combat(delta)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	animate_movement(direction)
	if Input.is_action_just_pressed("attack"):
		start_attack()
	if Input.is_action_just_pressed("summon"):
		summon_skeleton()
	velocity = direction * MOVE_SPEED * (0.2 if attack_remaining > 0 else 1.0) + knockback
	move_and_slide()
	regenerate_mana(delta,direction != Vector2.ZERO or attack_remaining > 0 or knockback.length() > 1)

func companion_count() -> int:
	var count := 0
	for companion in get_tree().get_nodes_in_group("companions"):
		if companion.summoner == self and not companion.dead:
			count += 1
	return count

func summon_skeleton() -> bool:
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
	mana -= SUMMON_COST
	mana_idle_remaining = MANA_IDLE_GRACE
	mana_changed.emit(mana,MAX_MANA)
	companions_changed.emit()
	summon_feedback.emit("Skelett erweckt – es kämpft zwei Minuten an deiner Seite.")
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
