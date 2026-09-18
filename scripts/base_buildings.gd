class_name Building
extends StaticBody2D

# __________________________Building Configs Properties__________________________
@export var team : Team.Side
@export var stats : CharacterStats
var current_hp: int

signal building_hurt(current_hp: int)
signal die()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stats == null:
		push_warning("%s has no Stats assigned — using defaults." % name)
		stats = CharacterStats.new()
	stats = stats.duplicate()
	current_hp = stats.max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# __________________________Bulding interactions__________________________
func _hurt(amount: int) -> void:
	current_hp -= (amount - stats.armor)
	building_hurt.emit(current_hp)
	# No animation yet
	#_set_state(State.HURT)
	
	# Checks if unit hp less than 0, if true run death animation.
	if current_hp <= 0:
		_die()

func _die() -> void:
	die.emit()
	queue_free()
