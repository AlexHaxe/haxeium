package haxeium.commands;

typedef CommandMouseEvent = CommandBase & {
	var eventName:MouseEventName;
	@:optional var locator:ElementLocator;
	@:optional var x:Float;
	@:optional var y:Float;
}

enum abstract MouseEventName(String) to String {
	var Click = "click";
	var DoubleClick = "doubleclick";
	var MouseDown = "mousedown";
	var MouseUp = "mouseup";
	var MouseWheel = "mousewheel";
	var MiddleClick = "middleclick";
	var MiddleMouseDown = "middlemousedown";
	var MiddleMouseUp = "middlemouseup";
	var RightClick = "rightclick";
	var RightMouseDown = "rightmousedown";
	var RightMouseUp = "rightmouseup";
}
