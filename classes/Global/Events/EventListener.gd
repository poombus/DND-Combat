extends Resource
class_name EventListener

var listener = null;
@export var event_signal:String = "";
@export var actions:Array[EventAction];

func event(_listener, source, data := {}):
	listener = _listener;
	if not data.has("source"): data.source = source;
	action(data);

func action(data:Dictionary):
	for a in actions: a.event_action(self, data);
