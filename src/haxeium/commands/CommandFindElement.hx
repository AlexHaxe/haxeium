package haxeium.commands;

import haxeium.commands.ElementLocator;

typedef CommandFindElement = CommandBase & {
	@:optional var parent:ElementLocator;
}
