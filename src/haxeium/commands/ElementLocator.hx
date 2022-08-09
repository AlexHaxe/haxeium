package haxeium.commands;

enum ByLocator {
	ByIndex(index:Int);
	ById(id:String);
	ByClassName(name:String);
	ByCssClass(cssClass:String);
	ByCssSelector(selector:String);
}

typedef ElementLocator = {
	var type:LocatorType;
	var location:String;
}
