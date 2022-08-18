package haxeium;

import haxe.Exception;

class ActionFailedException extends Exception {
	public function new() {
		super('action failed');
	}
}
