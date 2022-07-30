package haxeium.commands;

typedef CommandMouseEvent = CommandBase & {
	var eventName:MouseEventName;
}

enum abstract MouseEventName(String) to String {
	var Click = "click";
	var MouseDown = "mousedown";
	var MouseUp = "mouseup";
}
