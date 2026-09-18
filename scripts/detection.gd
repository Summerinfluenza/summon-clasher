class_name Detection
extends Area2D

@export var team : Team.Side
var enemy_base : Node2D
var enemies_in_range: Array[BaseCharacter] = []

@onready var character: BaseCharacter = get_parent()

func _ready() -> void:
	_setup_collision_layers()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func setup() -> void:
	_setup_collision_layers()
	
# Player and enemy units and buildings have different layers, using layers to
# differentiate.
func _setup_collision_layers() -> void:
	if team == Team.Side.PLAYER:
		character.collision_layer = 1 << 2
		collision_mask = 1 << 3
	else:
		character.collision_layer = 1 << 3
		collision_mask = 1 << 2

# Upon entering the detection area, add to enemies_in_range
func _on_body_entered(body: Node2D) -> void:
	if body is BaseCharacter:
		enemies_in_range.append(body)

# Upon leaving the detection area, remove from enemies_in_range
func _on_body_exited(body: Node2D) -> void:
	if body is BaseCharacter:
		enemies_in_range.erase(body)

# Moves toward the nearest enemy.
func get_nearest_enemy() -> BaseCharacter:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.is_empty():
		return null
	var nearest := enemies_in_range[0]
	var nearest_dist := character.global_position.distance_to(nearest.global_position)
	for e in enemies_in_range:
		var dist := character.global_position.distance_to(e.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = e
	return nearest

# Checks the BattlefieldState script to find respective enemy base.
func get_enemy_base() -> Node2D:
	if not is_instance_valid(enemy_base):
		enemy_base = BattlefieldState.get_enemy_base(team)
	return enemy_base
