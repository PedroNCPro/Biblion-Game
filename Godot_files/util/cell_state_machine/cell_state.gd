extends Node
class_name CellState
## This class represents the state of a [LetterBox]. It is used for power-up effect resolution
## on the level's [Grid].


signal state_entered(state: CellState)

@onready var state_machine: CellStateMachine = get_parent()


func enter_state() -> void:
	state_entered.emit(self)
	_enter_state()


func exit_state() -> void:
	_exit_state()


# maybe only a power-up will have an effect to apply. This function can be removed if unecessary
# (as actually any function here in this framework).
func apply_effect() -> void:
	_apply_effect()


func _enter_state() -> void:
	push_error("no virtual method _enter_state in ", self)


func _exit_state() -> void:
	push_error("no virtual method _exit_state in ", self)


func _apply_effect() -> void:
	push_error("no virtual method _apply_effect in ", self)
