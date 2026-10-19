extends "res://scripts/fighter.gd"
## Friendly skeleton: sticky combat focus, world pathfinding and owner cleanup.
const MOVE_SPEED := 205.0
const AGGRO_RADIUS := 300.0
const TARGET_LEASH := 480.0
const LIFETIME := 120.0
const ATTACK_INTERVAL := 1.05
var summoner: CharacterBody2D
var slot := 0
var lifetime_remaining := LIFETIME
var target: CharacterBody2D
var route := PackedVector2Array()
var repath_remaining := 0.0
var attack_delay := 0.0
var spawn_remaining := 0.0
var death_remaining := 0.0
var retiring := false

func _ready() -> void:
	asset_id = "skeleton"
	target_group = "enemies"
	max_health = 85
	health = max_health
	attack_damage = 10
	collision_layer = 2
	collision_mask = 1
	add_to_group("allies")
	add_to_group("companions")
	super._ready()
	defeated.connect(dismiss)
	spawn_remaining = 6.0 / 9.0
	sprite.play("spawn")

func dismiss() -> void:
	if retiring:
		return
	retiring = true
	dead = true
	collision_layer = 0
	collision_mask = 0
	remove_from_group("companions")
	remove_from_group("allies")
	death_remaining = 4.0 / 8.0
	sprite.modulate = Color.WHITE
	sprite.play(animation_for("death"))
	if is_instance_valid(summoner):
		summoner.companions_changed.emit()

func _physics_process(delta: float) -> void:
	if retiring:
		death_remaining -= delta
		if death_remaining <= 0:
			queue_free()
		return
	if not is_instance_valid(summoner) or summoner.dead:
		dismiss()
		return
	lifetime_remaining -= delta
	if lifetime_remaining <= 0:
		dismiss()
		return
	tick_combat(delta)
	spawn_remaining = maxf(0,spawn_remaining-delta)
	attack_delay = maxf(0,attack_delay-delta)
	repath_remaining -= delta
	var world = get_tree().current_scene
	# Tests attach the scene directly to the root as well.
	if world == null:
		world = get_parent().get_parent()
	if repath_remaining <= 0:
		repath_remaining = 0.35
		choose_route(world)
	var direction := Vector2.ZERO
	if is_instance_valid(target) and not target.dead and can_reach_attack(world):
		facing = global_position.direction_to(target.global_position)
		if attack_delay <= 0:
			start_attack()
			attack_delay = ATTACK_INTERVAL
	else:
		while not route.is_empty() and global_position.distance_to(route[0]) < 9:
			route.remove_at(0)
		if not route.is_empty():
			direction = global_position.direction_to(route[0])
	# Spawn visuals never delay AI or prevent rapid consecutive summons.
	if spawn_remaining <= 0 or attack_remaining > 0:
		animate_movement(direction)
	velocity = direction * MOVE_SPEED * (0.0 if attack_remaining > 0 else 1.0) + knockback
	move_and_slide()

func can_reach_attack(world: Node2D) -> bool:
	return global_position.distance_to(target.global_position) < 72 and world.navigation().clear_line(global_position,target.global_position)

func choose_route(world: Node2D) -> void:
	var nav = world.navigation()
	if is_instance_valid(target) and not target.dead and global_position.distance_to(target.global_position) <= TARGET_LEASH:
		route = nav.path(global_position,target.global_position)
		if not route.is_empty():
			return
	target = null
	var nearest := AGGRO_RADIUS
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance := global_position.distance_to(enemy.global_position)
		if enemy.dead or distance > nearest:
			continue
		var candidate: PackedVector2Array = nav.path(global_position,enemy.global_position)
		if not candidate.is_empty():
			target = enemy
			nearest = distance
			route = candidate
	if target != null:
		return
	var offsets := [Vector2(-56,56),Vector2(56,56),Vector2(0,104)]
	var aim: Vector2 = summoner.global_position + offsets[slot % 3]
	if not nav.free_at(aim):
		aim = summoner.global_position
	route = nav.path(global_position,aim) if global_position.distance_to(aim) > 24 else PackedVector2Array()
