package haxeium.elements;

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
		var cmd:CommandMouseEvent = {command: MouseEvent, locator: LocatorHelper.byToElementLocator(locator), eventName: eventName};
		var result:ResultBase = AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('mouse event "$eventName" failed');
			return;
		}
		if (handler == null) {
			handler = ResultStatusHelper.expectSuccessResult;
		}
		handler('mouse event "$eventName"', result.status);
	}

	public function keyPress(text:String, handler:Null<ResultStatusHandler> = null) {
		keyboardEvent(KeyPress, text, null, handler);
	}

	public function keyDown(keyCode:Int, handler:Null<ResultStatusHandler> = null) {
		keyboardEvent(KeyDown, null, keyCode, handler);
	}

	public function keyUp(keyCode:Int, handler:Null<ResultStatusHandler> = null) {
		keyboardEvent(KeyUp, null, keyCode, handler);
	}

	function keyboardEvent(eventName:KeyboardEventName, text:Null<String>, keyCode:Null<Int>, altKey:Null<Bool> = null, ctrlKey:Null<Bool> = null,
			shiftKey:Null<Bool> = null, handler:Null<ResultStatusHandler> = null) {
		var cmd:CommandKeyboardEvent = {
			command: KeyboardEvent,
			eventName: eventName
		};
		if (text != null) {
			cmd.text = text;
		}
		if (keyCode != null) {
			cmd.keyCode = keyCode;
		}
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
			handler = ResultStatusHelper.expectSuccessResult;
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
		var cmd:CommandPropGet = {command: PropGet, locator: LocatorHelper.byToElementLocator(locator), name: name};
		var result:ResultPropGet = cast AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('getProp "$name" failed');
			return null;
		}
		if (handler == null) {
			handler = ResultStatusHelper.expectSuccessResult;
		}
		handler('getProp "$name"', result.status);
		if (result.value != null) {
			var locatorValue:ElementLocator = cast result.value;
			if (Reflect.hasField(locatorValue, "type")
				&& Reflect.hasField(locatorValue, "location")
				&& '${locatorValue.type}'.startsWith("By")) {
				return AppDriver.createElement(locatorValue, result.className);
			}
		}
		return result.value;
	}

	public function setProp(name:String, value:Any, handler:Null<ResultStatusHandler> = null):Any {
		var cmd:CommandPropSet = {
			command: PropSet,
			locator: LocatorHelper.byToElementLocator(locator),
			name: name,
			value: value
		};
		var result:ResultPropGet = cast AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('setProp "$name" failed');
			return null;
		}
		if (handler == null) {
			handler = ResultStatusHelper.expectSuccessResult;
		}
		handler('setProp "$name"', result.status);
		return result.value;
	}

	public function children():Array<Element> {
		return AppDriver.instance.findChildren(locator);
	}

	public function findElement(loc:ByLocator):Element {
		return AppDriver.instance.findElement(loc, locator);
	}

	public function findElements(loc:ByLocator):Array<Element> {
		return AppDriver.instance.findElements(loc, locator);
	}
}
