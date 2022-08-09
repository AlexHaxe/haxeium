package haxeium.commands;

typedef CommandKeyboardEvent = CommandBase & {
	var eventName:KeyboardEventName;
	@:optional var text:String;
	@:optional var keyCode:Int;
	@:optional var altKey:Bool;
	@:optional var ctrlKey:Bool;
	@:optional var shiftKey:Bool;
}

enum abstract KeyboardEventName(String) to String {
	var KeyPress = "keypress";
	var KeyDown = "keydown";
	var KeyUp = "keyup";
}
