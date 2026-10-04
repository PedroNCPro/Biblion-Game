class_name SignalBusSender
extends Node

@export var signal_prefix := ""

func _ready() -> void:
	_make_connections.call_deferred()

## This function only acts as a way to store which signals are connected to this node
func connect_signal(..._args):
	return

## Bind a custom signal name when connecting the signal
func connect_signal_named(..._args):
	return


func _make_connections():
	for conn_info in get_incoming_connections():
		var sig: Signal = conn_info.signal
		var clb: Callable = conn_info.callable
		var sig_name: StringName = signal_prefix
		
		if clb.get_method() == connect_signal_named.get_method():
			sig_name += clb.get_bound_arguments()[0]
			clb.unbind(1)
		else:
			sig_name += sig.get_name()
		
		print("name of the signal connected: ", sig_name)
		sig.connect(func(...args):
			SignalBus.send(sig_name, args)
		)
		#print_rich("[color=gray]signal [/color]", sig_name, "[color=gray] connected![/color]")
