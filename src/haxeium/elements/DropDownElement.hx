package haxeium.elements;

class DropDownElement extends Element {
	public var selectedIndex(get, set):Int;
	public var selectedItem(get, set):Any;

	public function new(locator:ByLocator) {
		super(locator);
	}

	public function get_selectedIndex():Int {
		return getProp("selectedIndex");
	}

	public function set_selectedIndex(value:Int):Int {
		return setProp("selectedIndex", value);
	}

	public function get_selectedItem():Any {
		return getProp("selectedItem");
	}

	public function set_selectedItem(value:Any):Any {
		return setProp("selectedItem", value);
	}
}
