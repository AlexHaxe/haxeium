package haxeium.commands;

import haxeium.commands.ElementLocator;

typedef CommandFindElement = CommandLocatorBase & {
	@:optional var parent:ElementLocator;
}
