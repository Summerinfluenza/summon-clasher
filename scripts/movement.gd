# movement.gd
class_name Movement
extends Node

@onready var character: BaseCharacter = get_parent()

var current_direction: Vector2
var starting_direction: Vector2

func set_starting_direction(team: Team.Side) -> void:
	if team == Team.Side.PLAYER:
		starting_direction = Vector2.RIGHT
		character.animated_sprite.flip_h = false
	else:
		starting_direction = Vector2.LEFT
		character.animated_sprite.flip_h = true

func move_toward_target(to_target: Vector2) -> void:
	character.velocity = to_target.normalized() * character.stats.movement_speed * BaseCharacter.TILESIZE
	_set_direction(to_target.normalized())
	character.move_and_slide()

func stop() -> void:
	character.velocity = Vector2.ZERO
	character.move_and_slide()

func _set_direction(direction: Vector2) -> void:
	if direction.x > 0:
		character.animated_sprite.flip_h = false
		current_direction = Vector2.RIGHT
	elif direction.x < 0:
		character.animated_sprite.flip_h = true
		current_direction = Vector2.LEFT
