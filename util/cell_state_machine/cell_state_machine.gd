extends Node
class_name CellStateMachine
## This class is the state machine of a [LetterBox]. It is composed of a root node
## representing a state machine, and all of its children are [CellState]. It controls
## which is the current state, and the change between them, but what each state does
## is contained in each state's script.


var current_state: CellState = null
var previous_state: CellState = null


func includes(state_array: Array[CellState]) -> bool:
	return state_array.any(func(x): return x == current_state)


func get_state(state_script: Script) -> CellState:
	return get_children().filter(func(x): return x.get_script == state_script)[0]


func set_current_state(new_state: CellState) -> void:
	previous_state = current_state
	current_state = new_state
	if previous_state != current_state:
		if previous_state != null:
			previous_state.exit_state()
		if new_state != null:
			current_state.enter_state()
