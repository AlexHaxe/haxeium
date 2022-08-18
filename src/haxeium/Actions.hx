package haxeium;

import haxe.PosInfos;
import haxeium.commands.ResultStatusHandler;
import haxeium.elements.Element;

class Actions {
	var actions:Array<InputAction>;

	public function new() {
		actions = [];
	}

	public function click(?element:Element, ?x:Float, ?y:Float):Actions {
		actions.push(Click(element, x, y));
		return this;
	}

	public function doubleClick(?element:Element, ?x:Float, ?y:Float):Actions {
		actions.push(DoubleClick(element, x, y));
		return this;
	}

	public function mouseDown(?element:Element, ?x:Float, ?y:Float):Actions {
		actions.push(MouseDown(element, x, y));
		return this;
	}

	public function mouseUp(?element:Element, ?x:Float, ?y:Float):Actions {
		actions.push(MouseUp(element, x, y));
		return this;
	}

	public function moveToElement(?element:Element, ?x:Float, ?y:Float):Actions {
		actions.push(MoveToElement(element, x, y));
		return this;
	}

	public function moveTo(x:Float, y:Float):Actions {
		actions.push(MoveTo(x, y));
		return this;
	}

	public function moveByOffset(offsetX:Float, offsetY:Float):Actions {
		actions.push(MoveByOffset(offsetX, offsetY));
		return this;
	}

	public function keyDown(keyCode:Int):Actions {
		actions.push(KeyDown(keyCode));
		return this;
	}

	public function keyUp(keyCode:Int):Actions {
		actions.push(KeyUp(keyCode));
		return this;
	}

	public function sendKeys(text:String):Actions {
		actions.push(SendKeys(text));
		return this;
	}

	public function pause(s:Float):Actions {
		actions.push(Pause(s));
		return this;
	}

	public function perform(?pos:PosInfos):Actions {
		function elementToLocator(element:Element) {
			if (element == null) {
				return null;
			}
			return LocatorHelper.byToElementLocator(element.locator);
		}
		for (action in actions) {
			var success = switch (action) {
				case Click(element, x, y):
					performMouseEvent(Click, elementToLocator(element), x, y);
				case DoubleClick(element, x, y):
					performMouseEvent(DoubleClick, elementToLocator(element), x, y);
				case MouseDown(element, x, y):
					performMouseEvent(MouseDown, elementToLocator(element), x, y);
				case MouseUp(element, x, y):
					performMouseEvent(MouseUp, elementToLocator(element), x, y);
				case MoveToElement(element, offsetX, offsetY):
					performMouseEvent(MoveTo, LocatorHelper.byToElementLocator(element.locator), offsetX, offsetY);
				case MoveTo(x, y):
					performMouseEvent(MoveTo, null, x, y);
				case MoveByOffset(offsetX, offsetY):
					performMouseEvent(MoveByOffset, null, offsetX, offsetY);
				case KeyDown(keyCode, altKey, ctrlKey, shiftKey):
					performKeyboardEvent(KeyDown, null, keyCode, altKey, ctrlKey, shiftKey);
				case KeyUp(keyCode, altKey, ctrlKey, shiftKey):
					performKeyboardEvent(KeyUp, null, keyCode, altKey, ctrlKey, shiftKey);
				case SendKeys(text):
					performKeyboardEvent(KeyPress, text);
				case Pause(s):
					Sys.sleep(s);
					true;
			}
			if (!success) {
				ResultStatusHelper.grabFailScreenshot(pos);
				break;
			}
		}
		return this;
	}

	function performMouseEvent(eventName:MouseEventName, locator:Null<ElementLocator>, x:Null<Float>, y:Null<Float>) {
		var cmd:CommandMouseEvent = {
			command: MouseEvent,
			locator: locator,
			eventName: eventName,
			x: x,
			y: y
		};
		var result:ResultBase = AppDriver.instance.send(cmd);
		if (result == null) {
			return false;
		}
		if (result.status != Success) {
			return false;
		}
		return true;
	}

	function performKeyboardEvent(eventName:KeyboardEventName, ?text:String, ?keyCode:Int, ?altKey:Bool, ?ctrlKey:Bool, ?shiftKey:Bool) {
		var cmd:CommandKeyboardEvent = {
			command: KeyboardEvent,
			eventName: eventName,
			text: text,
			keyCode: keyCode,
			altKey: altKey,
			ctrlKey: ctrlKey,
			shiftKey: shiftKey
		};
		var result:ResultBase = AppDriver.instance.send(cmd);
		if (result == null) {
			return false;
		}
		if (result.status != Success) {
			return false;
		}
		return true;
	}
}

enum InputAction {
	Click(?element:Element, ?x:Float, ?y:Float);
	DoubleClick(?element:Element, ?x:Float, ?y:Float);
	MouseDown(?element:Element, ?x:Float, ?y:Float);
	MouseUp(?element:Element, ?x:Float, ?y:Float);
	MoveToElement(element:Element, ?offsetX:Float, ?offsetY:Float);
	MoveTo(x:Float, y:Float);
	MoveByOffset(offsetX:Float, offsetY:Float);
	KeyDown(keyCode:Int, ?altKey:Bool, ?ctrlKey:Bool, ?shiftKey:Bool);
	KeyUp(keyCode:Int, ?altKey:Bool, ?ctrlKey:Bool, ?shiftKey:Bool);
	SendKeys(text:String);

	Pause(s:Float);
}
