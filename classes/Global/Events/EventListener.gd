extends Resource
class_name EventListener

var listener = null;
@export var event_signal:String = "";
@export var is_global:bool = false;
@export var actions:Array[EventAction];

func event(_listener, source, data := {}):
	listener = _listener;
	data.source = source;
	if listener is StatusEffect or listener is Feat:
		#if it stops working, use listener.pawn.pawn and source.pawn
		if is_global: action(data);
		elif listener.pawn == source: action(data);
		elif listener.pawn == source.pawn: action(data);
	else: action(data);

func action(data:Dictionary):
	for a in actions: a.event_action(self, data);
