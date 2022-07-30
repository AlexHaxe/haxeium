package haxeium.commands;

import haxeium.commands.ElementLocator;

typedef ResultFindElements = ResultBase & {
	var elements:Array<ElementTypeAndLocator>;
}
