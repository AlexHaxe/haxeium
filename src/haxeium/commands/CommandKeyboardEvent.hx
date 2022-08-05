package haxeium.commands;

typedef CommandKeyboardEvent = CommandBase & {
	var eventName:KeyboardEventName;
	var text:String;
	@:optional var altKey:Bool;
	@:optional var ctrlKey:Bool;
	@:optional var shiftKey:Bool;
	@:optional var locator:ElementLocator;
}

enum abstract KeyboardEventName(String) to String {
	var KeyPress = "keypress";
	var KeyDown = "keydown";
	var KeyUp = "keyup";
}
