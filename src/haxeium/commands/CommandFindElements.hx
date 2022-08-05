package haxeium.commands;

typedef CommandFindElements = CommandLocatorBase & {
	@:optional var parent:ElementLocator;
}
