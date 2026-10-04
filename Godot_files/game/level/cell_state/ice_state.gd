extends CellState
class_name Ice


func _enter_state() -> void:
	# change sprite, do some crazy stuff
	pass


func _exit_state() -> void:
	# maybe not needed because the new state will change sprite and do crazy stuff,
	# but here some cleaning up can be done
	pass


func _apply_effect() -> void:
	# maybe not needed
	pass
