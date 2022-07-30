package haxeium.commands;

typedef CommandFindElements = CommandBase & {
	@:optional var parent:ElementLocator;
}
