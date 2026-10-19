extends CharacterBody2D
## Shared combat timing. Each swing hits each target at most once, at impact.
signal health_changed(current: int, maximum: int)
signal defeated

const Art = preload("res://scripts/art_library.gd")
const MAX_HEALTH := 100
const ATTACK_DAMAGE := 25
const ATTACK_REACH := 98.0
const ATTACK_RECOVERY := 0.46
const IMPACT_TIME := 0.16
const INVULNERABILITY := 0.65

var health := MAX_HEALTH
var facing := Vector2.DOWN
var sprite: AnimatedSprite2D
var attack_remaining := 0.0
var invulnerable_remaining := 0.0
var knockback := Vector2.ZERO
var did_impact := false
var dead := false
var target_group := "enemies"
var asset_id := "hero"

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	sprite = Art.sprite_for(asset_id)
	add_child(sprite)
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 24)
	collider.shape = shape
	collider.position.y = -12
	add_child(collider)

func tick_combat(delta: float) -> void:
	invulnerable_remaining = maxf(0.0, invulnerable_remaining - delta)
	knockback = knockback.move_toward(Vector2.ZERO, 850.0 * delta)
	sprite.modulate = Color(1, 0.55, 0.45) if invulnerable_remaining > 0.45 else Color.WHITE
	if attack_remaining > 0.0:
		attack_remaining = maxf(0.0, attack_remaining - delta)
		if not did_impact and attack_remaining <= ATTACK_RECOVERY - IMPACT_TIME:
			did_impact = true
			resolve_attack()

func start_attack() -> void:
	if dead or attack_remaining > 0.0:
		return
	attack_remaining = ATTACK_RECOVERY
	did_impact = false
	if absf(facing.x) > 0.1:
		sprite.flip_h = facing.x < 0
	sprite.play("attack")

func can_hit(target_position: Vector2) -> bool:
	var offset := target_position - global_position
	return offset.length() <= ATTACK_REACH and (offset.length() < 18.0 or facing.dot(offset.normalized()) >= 0.3)

func resolve_attack() -> void:
	for target in get_tree().get_nodes_in_group(target_group):
		if target.dead or not can_hit(target.global_position):
			continue
		# World geometry must block melee, even at close range.
		var query := PhysicsRayQueryParameters2D.create(global_position + Vector2(0,-12), target.global_position + Vector2(0,-12), 1)
		if get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			target.take_damage(ATTACK_DAMAGE, global_position)

func take_damage(amount: int, origin: Vector2) -> void:
	if dead or invulnerable_remaining > 0.0:
		return
	health = maxi(0, health - amount)
	invulnerable_remaining = INVULNERABILITY
	knockback = origin.direction_to(global_position) * 190.0
	health_changed.emit(health, MAX_HEALTH)
	if health == 0:
		dead = true
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		sprite.stop()
		sprite.modulate = Color(0.5, 0.5, 0.5, 0.6)
		defeated.emit()

func animate_movement(direction: Vector2) -> void:
	if attack_remaining > 0.0 or dead:
		return
	if direction.length_squared() > 0.01:
		facing = direction.normalized()
		if absf(direction.x) > 0.1:
			sprite.flip_h = direction.x < 0
		sprite.play("walk")
	else:
		sprite.play("stand")
