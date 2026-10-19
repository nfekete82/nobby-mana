extends "res://scripts/fighter.gd"

const MOVE_SPEED := 105.0
const AGGRO_RADIUS := 290.0
const LEASH_RADIUS := 390.0
var home := Vector2.ZERO
var attack_delay := 0.8
var target: CharacterBody2D
var route := PackedVector2Array()
var repath_remaining := 0.0

func _ready() -> void:
	asset_id = "enemy-warrior"
	target_group = "allies"
	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")
	super._ready()
	home = global_position

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
	velocity = direction * MOVE_SPEED * (0.0 if attack_remaining > 0 else 1.0) + knockback
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
