package haxeium.commands;

enum abstract LocatorType(String) {
	final ByIndex = "ByIndex";
	final ById = "ById";
	final ByClassName = "ByClassName";
	final ByCssClass = "ByCssClass";
	final ByCssSelector = "ByCssSelector";
}
