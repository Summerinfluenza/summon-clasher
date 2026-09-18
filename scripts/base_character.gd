class_name BaseCharacter
extends CharacterBody2D

# __________________________Unit Configs Properties__________________________
const TILESIZE = 32

@export var stats : CharacterStats
@export var team : Team.Side

var current_hp : int
var current_energy : int
var attack_cooldown : float = 0.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var detection: Detection = $Detection
@onready var movement: Movement = $Movement
@onready var animations: Animations = $Animations
@onready var health: Health = $Health
@onready var health_bar: HealthBar = $HealthBar

# __________________________Interaction signals__________________________
signal character_hurt(current_hp: int)
signal character_attack(damage: int)
signal died()

# __________________________Spawn Config__________________________
func _ready() -> void:
	# Checking if stats has been assigned for the character before being spawned.
	if stats == null:
		push_warning("%s has no Stats assigned — using defaults." % name)
		stats = CharacterStats.new()
	stats = stats.duplicate()
	
	detection.team = team
	detection.setup()
	
	health.setup(stats)
	health_bar.setup(health)
	health.hurt.connect(func(hp): character_hurt.emit(hp))
	health.died.connect(_death)
	
	movement.set_starting_direction(team)
	
	_spawn()
	
func _spawn() -> void:
	animations.set_state(Animations.State.IDLE)
	
#__________________________Game Process__________________________
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Stops animation after running once.
	if animations.is_locked():
		return
	
	var current_target := _get_current_target()
	if not is_instance_valid(current_target):
		movement.stop()
		animations.set_state(Animations.State.IDLE)
		return
	
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	var to_target := current_target.global_position - global_position
	if to_target.length() <= ((stats.attack_range + 1) * TILESIZE):
		movement.stop()
		if attack_cooldown <= 0.0:
			_attack(current_target)
	else:
		movement.move_toward_target(to_target)
		animations.set_state(Animations.State.WALK)
	

# __________________________Unit interactions__________________________

# Fetches a target within the detection area, if none returns the base.
func _get_current_target() -> Node2D:
	var nearest_enemy := detection.get_nearest_enemy()
	if nearest_enemy != null:
		return nearest_enemy
	return detection.get_enemy_base()

func _attack(current_target: Node2D) -> void:
	animations.set_state(Animations.State.ATTACK)
	
	# Checks combat math for counterbonus.
	var damage := stats.attack_damage
	if is_instance_valid(current_target) and "stats" in current_target:
		damage = CombatMath.calculate_damage(stats, current_target.stats)

	if is_instance_valid(current_target) and current_target.has_method("_hurt"):
		current_target._hurt(damage)

	character_attack.emit(damage)
	attack_cooldown = 1.0 /stats.attack_speed

func _special() -> void:
	animations.set_state(Animations.State.SPECIAL)
	
func _hurt(amount: int) -> void:
	health.take_damage(amount)
	
# Upon death, stop all logic and delete the character after playing the death animation once.
func _death() -> void:
	animations.set_state(Animations.State.DEATH)
	set_physics_process(false)
	died.emit()
