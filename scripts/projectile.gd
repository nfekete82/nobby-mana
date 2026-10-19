extends Node2D
const SPEED := 640.0
const RANGE := 600.0
var direction := Vector2.RIGHT
var damage := 18
var caster: CharacterBody2D
var arcane := false
var remaining := RANGE

func _ready() -> void:
	add_to_group("projectiles")
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/compiled/"+("arcane-arrow.png" if arcane else "arrow.png"))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position.y = -30
	sprite.rotation = direction.angle()
	add_child(sprite)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(caster) or caster.dead:
		queue_free()
		return
	var next := global_position + direction * minf(SPEED*delta,remaining)
	var query := PhysicsRayQueryParameters2D.create(global_position,next,1|4)
	var impact := get_world_2d().direct_space_state.intersect_ray(query)
	if not impact.is_empty():
		if impact.collider.is_in_group("enemies") and not impact.collider.dead:
			impact.collider.take_damage(damage,caster.global_position)
		queue_free()
		return
	remaining -= global_position.distance_to(next)
	global_position = next
	if remaining <= 0:
		queue_free()
