package haxeium.elements;

import haxeium.elements.Element;

class TabBarButtonElement extends Element {
	public function new(locator:ByLocator) {
		super(locator);
	}

	override public function click(handler:Null<ResultStatusHandler> = null) {
		// TabBarButtons only react to mouseDown events
		mouseEvent(MouseDown, handler);
	}
}
