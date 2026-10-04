extends Node
## Controls the flow of signals between [SignalBusSender] and[br]
## [SignalBusReceiver].
##
## [u][color=yellow]It must be put as an Autoload[/color][/u]
##
## Example of workflow with [SignalBus]:
## In a scene from where you want to send a [Signal], add a [SignalBusSender] node, and through[br]
## the editor, connect the signal you want to send to [method SignalBusSender.connect_signal]. Then,[br]
## you can call [method Signal.emit] as normal in the code.
## In a scene you want to receive a [Signal], add a [SignalBusReceiver] node, and through[br]
## the editor, connect the signal you want to receive from [SignalBusReceiver] to the function
## you want to call.


var _free_locks: Array[int] = []
var _locks: Array[int] = []
var _buffer: Array[Dictionary] = []


func send(signal_name: StringName, args: Array):
	#print("sending ", signal_name)
	if _locks.size() > 0:
		_buffer.append({signal_name = signal_name, args = args})
	else:
		_broadcast(signal_name, args)


func is_locked() -> bool:
	return not _locks.is_empty()


func lock() -> int:
	var lock_id := -1
	if _free_locks.is_empty():
		lock_id = _locks.size() + 1
	else:
		lock_id = _free_locks.pop_front()
	_locks.append(lock_id)
	return lock_id


func unlock(lock_id: int):
	if lock_id in _locks:
		_locks.erase(lock_id)
		_free_locks.append(lock_id)
	while not _buffer.is_empty() and _locks.is_empty():
		var signal_call: Dictionary = _buffer.pop_front()
		_broadcast(signal_call.signal_name, signal_call.args)


func _broadcast(signal_name: StringName, args: Array):
	#print_rich("[color=GREEN]broadcasting signal to the following receivers: [/color]", SignalBusReceiver.all(get_tree()))
	for receiver in SignalBusReceiver.all(get_tree()):
		receiver.callv(&'emit_signal', [signal_name] + args)
		#print_rich("[color=ORANGE]signal [/color]", signal_name, "[color=ORANGE] emmited!![/color]")
