package haxeium.elements;

import utest.Assert;
import haxeium.AppDriver;

class Element {
	public var locator:ByLocator;

	public var text(get, set):String;

	public function new(locator:ByLocator) {
		this.locator = locator;
	}

	public function click(handler:Null<ResultStatusHandler> = null) {
		mouseEvent(Click, handler);
	}

	public function mouseDown(handler:Null<ResultStatusHandler> = null) {
		mouseEvent(MouseDown, handler);
	}

	public function mouseUp(handler:Null<ResultStatusHandler> = null) {
		mouseEvent(MouseUp, handler);
	}

	function mouseEvent(eventName:MouseEventName, handler:Null<ResultStatusHandler> = null) {
		var cmd:CommandMouseEvent = {command: MouseEvent, locator: byToElementLocator(locator), eventName: eventName};
		var result:ResultBase = AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('mouse event "$eventName" failed');
			return;
		}
		if (handler == null) {
			handler = expectSuccessResult;
		}
		handler('mouse event "$eventName"', result.status);
	}

	public function keyPress(text:String, handler:Null<ResultStatusHandler> = null) {
		keyboardEvent(KeyPress, text, handler);
	}

	public function keyDown(text:String, handler:Null<ResultStatusHandler> = null) {
		keyboardEvent(KeyDown, text, handler);
	}

	public function keyUp(text:String, handler:Null<ResultStatusHandler> = null) {
		keyboardEvent(KeyUp, text, handler);
	}

	function keyboardEvent(eventName:KeyboardEventName, text:String, altKey:Null<Bool> = null, ctrlKey:Null<Bool> = null, shiftKey:Null<Bool> = null,
			handler:Null<ResultStatusHandler> = null) {
		var cmd:CommandKeyboardEvent = {
			command: KeyboardEvent,
			locator: byToElementLocator(locator),
			eventName: eventName,
			text: text
		};
		if (altKey != null) {
			cmd.altKey = altKey;
		}
		if (ctrlKey != null) {
			cmd.ctrlKey = ctrlKey;
		}
		if (shiftKey != null) {
			cmd.shiftKey = shiftKey;
		}
		var result:ResultBase = AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('keyboard event "$eventName" failed');
			return;
		}
		if (handler == null) {
			handler = expectSuccessResult;
		}
		handler('keyboard event "$eventName"', result.status);
	}

	public function get_text():String {
		return getProp("text");
	}

	public function set_text(value:String):String {
		return setProp("text", value);
	}

	public function getProp(name:String, handler:Null<ResultStatusHandler> = null):Any {
		var cmd:CommandPropGet = {command: PropGet, locator: byToElementLocator(locator), name: name};
		var result:ResultPropGet = cast AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('getProp "$name" failed');
			return null;
		}
		if (handler == null) {
			handler = expectSuccessResult;
		}
		handler('getProp "$name"', result.status);
		if (result.value != null) {
			var locatorValue:ElementLocator = cast result.value;
			if (Reflect.hasField(locatorValue, "type")
				&& Reflect.hasField(locatorValue, "location")
				&& '${locatorValue.type}'.startsWith("By")) {
				return elementToByLocator(locatorValue);
			}
		}
		return result.value;
	}

	public function setProp(name:String, value:Any, handler:Null<ResultStatusHandler> = null):Any {
		var cmd:CommandPropSet = {
			command: PropSet,
			locator: byToElementLocator(locator),
			name: name,
			value: value
		};
		var result:ResultPropGet = cast AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('setProp "$name" failed');
			return null;
		}
		if (handler == null) {
			handler = expectSuccessResult;
		}
		handler('setProp "$name"', result.status);
		return result.value;
	}
}

typedef ResultStatusHandler = (name:String, status:ResultStatus) -> Void;

function expectSuccessResult(name:String, status:ResultStatus) {
	if (status == Success) {
		return;
	}
	Assert.fail('$name failed with $status');
}

function expectNotVisibleResult(name:String, status:ResultStatus) {
	if (status == FailedNotVisible) {
		return;
	}
	Assert.fail('$name failed with $status');
}
