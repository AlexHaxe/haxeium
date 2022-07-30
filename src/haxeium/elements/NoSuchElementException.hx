package haxeium.elements;

import haxe.Exception;

class NoSuchElementException extends Exception {
	public function new(locator:ByLocator) {
		super('no such element: $locator');
	}
}
