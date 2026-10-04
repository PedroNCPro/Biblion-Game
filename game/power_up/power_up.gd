extends Node
class_name PowerUp


# Non-virtual interface pattern: 
# this pattern adds a layer of indirection to virtual methods such that we can carry out pre and
# post operations relative to the abstract operation we are carrying out (playing a sound every time
# a power-up is used, for example)
func apply_effect() -> void:
	_apply_effect()
	

func is_applicable() -> bool:
	return _is_applicable()


func _apply_effect() -> void:
	var caller_class_name := "unknown"
	var script = get_script()
	if script:
		if script.has_method("get_global_name") and not script.get_global_name().is_empty():
			caller_class_name = script.get_global_name()
		else:
			caller_class_name = script.resource_path.get_file().get_basename()
	push_error("virtual method _apply_effect() not implemented in ", caller_class_name)


func _is_applicable() -> bool:
	var caller_class_name := "unknown"
	var script = get_script()
	if script:
		if script.has_method("get_global_name") and not script.get_global_name().is_empty():
			caller_class_name = script.get_global_name()
		else:
			caller_class_name = script.resource_path.get_file().get_basename()
	push_error("virtual method _try_applying_effect() not implemented in ", caller_class_name)
	return false
