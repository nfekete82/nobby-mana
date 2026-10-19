extends "res://scripts/fighter.gd"

const MOVE_SPEED := 225.0

func _ready() -> void:
	asset_id = "hero"
	target_group = "enemies"
	collision_layer = 2
	collision_mask = 1
	add_to_group("hero")
	super._ready()
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
	velocity = direction * MOVE_SPEED * (0.2 if attack_remaining > 0 else 1.0) + knockback
	move_and_slide()
