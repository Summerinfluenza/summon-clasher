class_name BaseCharacter
extends CharacterBody2D

# __________________________Unit Configs Properties__________________________
enum State { IDLE, WALK, ATTACK, HURT, DEATH, SPECIAL }
const ONCE_STATES := [State.ATTACK, State.SPECIAL, State.HURT, State.DEATH]
const GAMESPEED = 30

@export var stats : CharacterStats
@export var team : Team.Side

var current_hp: int
var current_energy : int
var state: State
var target: BaseCharacter
var starting_direction : Vector2
var current_direction : Vector2

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
#@onready var hit_box : HitBox = $HitBox

# __________________________Interaction signals__________________________
signal character_damaged(current_hp: int)
signal character_attack(damage: int)
signal died()

# __________________________Spawn Config__________________________
func _ready() -> void:
	# Checking if stats has been assigned for the character before being spawned.
	if stats == null:
		push_warning("%s has no Stats assigned — using defaults." % name)
		stats = CharacterStats.new()
	stats = stats.duplicate()
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	_spawn()

func _spawn() -> void:
	current_hp = stats.max_hp
	target = null
	_set_state(State.IDLE)
	_starting_direction()

#__________________________Game Process__________________________
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Stops animation after running once.
	if state in ONCE_STATES:
		return
	
	# Temporary input controlled for testing
	if Input.is_action_just_pressed("ui_accept"):
		_attack()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction != Vector2.ZERO:
		velocity = input_direction * stats.movement_speed * GAMESPEED
		_walk()
		_set_direction(input_direction)
	else:
		velocity = Vector2.ZERO
		_idle()
	move_and_slide()
		
# __________________________Unit Animation__________________________
# Animation depending on state
func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	print("Changing state to: ", new_state)
	state = new_state
	
	match state:
		State.IDLE:
			animated_sprite.play("idle")
		State.WALK:
			animated_sprite.play("walk")
		State.ATTACK:
			animated_sprite.play("attack")
		State.SPECIAL:
			animated_sprite.play("special")
		State.HURT:
			animated_sprite.play("hurt")
		State.DEATH:
			animated_sprite.play("death")

func _on_animation_finished() -> void:
	if state in [State.ATTACK, State.SPECIAL, State.HURT]:
		_set_state(State.IDLE)
	elif state == State.DEATH:
		queue_free()

# __________________________Unit interactions__________________________
func _walk() -> void:
	_set_state(State.WALK)

func _attack() -> void:
	_set_state(State.ATTACK)
	character_attack.emit(stats.attack_damage)

func _special() -> void:
	_set_state(State.SPECIAL)
	
func _hurt(amount: int) -> void:
	current_hp -= amount
	character_damaged.emit(current_hp)
	# No animation yet
	#_set_state(State.HURT)
	
	# Checks if unit hp less than 0, if true run death animation.
	if current_hp <= 0:
		_death()
	
# Upon death, stop all logic and delete the character after playing the death animation once.
func _death() -> void:
	_set_state(State.DEATH)
	set_physics_process(false)
	died.emit()

func _idle() -> void:
	_set_state(State.IDLE)

#__________________________Unit direction__________________________
func _starting_direction() -> void:
	if team == Team.Side.PLAYER:
		starting_direction = Vector2.RIGHT
		animated_sprite.flip_h = false
	else:
		starting_direction = Vector2.LEFT
		animated_sprite.flip_h = true
		
func _set_direction(direction: Vector2) -> void:
	if direction.x > 0:
		animated_sprite.flip_h = false
		current_direction = Vector2.RIGHT
	elif direction.x < 0:
		animated_sprite.flip_h = true
		current_direction = Vector2.LEFT
