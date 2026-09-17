class_name BaseCharacter
extends CharacterBody2D

# Possible character states
enum State { IDLE, WALK, ATTACK, HURT, DEATH, SPECIAL }

# Defensive stats
@export var max_hp : int
@export var hp : int
@export var max_shield : int
@export var shield : int
@export var armor : int

# Offensive stats
@export var attack_damage : int
@export var attack_speed : float
@export var attack_range : int

# Utility
@export var movement_speed : float
@export var max_energy : int
@export var energy : int
@export var team: Team.Side

# Starting stats and configs
const SPEED = 30
var current_hp: int
var current_energy: int
var state: State = State.IDLE
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Direction
var starting_direction: Vector2
var current_direction: Vector2
var direction : Vector2 = Vector2.ZERO



const DIR_2 = [ Vector2.LEFT, Vector2.RIGHT ]

signal character_damaged()


# Original hp, energy and state upon spawn
func _ready() -> void:
	current_hp = max_hp
	current_energy = max_energy
	_set_state(State.IDLE)
	_starting_facing(team)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if current_hp <= 0:
		_die()
		return
	if state == State.ATTACK:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		_attack()
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction != Vector2.ZERO:
		velocity = input_direction * movement_speed * SPEED
		_walk()
		_facing(input_direction)
	else:
		velocity = Vector2.ZERO
		_idle()
	move_and_slide()
		
	
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
			
func _walk() -> void:
	_set_state(State.WALK)

func _attack() -> void:
	_set_state(State.ATTACK)
	animated_sprite.animation_finished.connect(_idle, CONNECT_ONE_SHOT)

func _special() -> void:
	_set_state(State.SPECIAL)
	
func _hurt() -> void:
	_set_state(State.HURT)

# Upon death, stop all logic and delete the character after playing the death animation once.
func _die() -> void:
	_set_state(State.DEATH)
	set_physics_process(false)
	animated_sprite.animation_finished.connect(func(): queue_free(), CONNECT_ONE_SHOT)

func _idle() -> void:
	_set_state(State.IDLE)
	
func _starting_facing(team: Team.Side) -> void:
	if team == Team.Side.PLAYER:
		starting_direction = Vector2.RIGHT
		animated_sprite.flip_h = false
	else:
		starting_direction = Vector2.LEFT
		animated_sprite.flip_h = true
		
func _facing(direction: Vector2) -> void:
	if direction.x > 0:
		animated_sprite.flip_h = false
		current_direction = Vector2.RIGHT
	elif direction.x < 0:
		animated_sprite.flip_h = true
		current_direction = Vector2.LEFT
