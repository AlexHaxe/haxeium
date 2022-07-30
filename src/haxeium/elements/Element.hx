package haxeium.elements;

import utest.Assert;
import haxeium.AppDriver;

class Element {
	public var locator:ByLocator;

	public var text(get, set):String;

	public function new(locator:ByLocator) {
		this.locator = locator;
	}

	public function click() {
		mouseEvent(Click);
	}

	public function mouseDown() {
		mouseEvent(MouseDown);
	}

	public function mouseUp() {
		mouseEvent(MouseUp);
	}

	function mouseEvent(eventName:MouseEventName) {
		var cmd:CommandMouseEvent = {command: MouseEvent, locator: byToElementLocator(locator), eventName: eventName};
		var result:ResultBase = AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('mouse event "$eventName" failed');
			return;
		}
		if (result.status != Success) {
			Assert.fail('mouse event "$eventName" failed');
		}
	}

	public function get_text():String {
		return getProp("text");
	}

	public function set_text(value:String):String {
		return setProp("text", value);
	}

	public function getProp(name:String):Any {
		var cmd:CommandPropGet = {command: PropGet, locator: byToElementLocator(locator), name: name};
		var result:ResultPropGet = cast AppDriver.instance.send(cmd);
		if (result == null) {
			Assert.fail('getProp "$name" failed');
			return null;
		}
		if (result.status != Success) {
			Assert.fail('getProp "$name" failed');
		}
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

	public function setProp(name:String, value:Any):Any {
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
		if (result.status != Success) {
			Assert.fail('setProp "$name" failed');
		}
		return result.value;
	}
}
