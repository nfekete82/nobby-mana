extends "res://scripts/fighter.gd"

const MOVE_SPEED := 105.0
const AGGRO_RADIUS := 290.0
const LEASH_RADIUS := 390.0
var home := Vector2.ZERO
var attack_delay := 0.8

func _ready() -> void:
	asset_id = "enemy-warrior"
	target_group = "hero"
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
	var hero = get_tree().get_first_node_in_group("hero")
	var direction := Vector2.ZERO
	if hero != null and not hero.dead:
		var distance: float = global_position.distance_to(hero.global_position)
		var query := PhysicsRayQueryParameters2D.create(global_position + Vector2(0,-12), hero.global_position + Vector2(0,-12), 1)
		var visible := get_world_2d().direct_space_state.intersect_ray(query).is_empty()
		if distance < AGGRO_RADIUS and global_position.distance_to(home) < LEASH_RADIUS and visible:
			direction = global_position.direction_to(hero.global_position)
			if distance < 78.0:
				facing = direction
				if attack_delay <= 0:
					start_attack()
					attack_delay = 1.3
				direction = Vector2.ZERO
		elif global_position.distance_to(home) > 8:
			direction = global_position.direction_to(home)
	animate_movement(direction)
	velocity = direction * MOVE_SPEED * (0.0 if attack_remaining > 0 else 1.0) + knockback
	move_and_slide()
