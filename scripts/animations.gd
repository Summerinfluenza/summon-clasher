class_name Animations
extends Node

enum State { IDLE, WALK, ATTACK, HURT, DEATH, SPECIAL }
const ONCE_STATES := [State.ATTACK, State.SPECIAL, State.HURT, State.DEATH]

var character: BaseCharacter
var sprite: AnimatedSprite2D
var state: State
	
func _ready() -> void:
	character = get_parent()
	sprite = character.get_node("AnimatedSprite2D")
	sprite.animation_finished.connect(_on_animation_finished)
	
func set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	match state:
		State.IDLE: sprite.play("idle")
		State.WALK: sprite.play("walk")
		State.ATTACK: sprite.play("attack")
		State.SPECIAL: sprite.play("special")
		State.HURT: sprite.play("hurt")
		State.DEATH: sprite.play("death")

func is_locked() -> bool:
	return state in ONCE_STATES

func _on_animation_finished() -> void:
	if state in [State.ATTACK, State.SPECIAL, State.HURT]:
		set_state(State.IDLE)
	elif state == State.DEATH:
		character.queue_free()
