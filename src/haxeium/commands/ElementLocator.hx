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

function byToElementLocator(byLocator:Null<ByLocator>):Null<ElementLocator> {
	return switch (byLocator) {
		case null:
			null;
		case ByIndex(index):
			{type: ByIndex, location: '$index'};
		case ById(id):
			{type: ById, location: id};
		case ByClassName(name):
			{type: ByClassName, location: name};
		case ByCssClass(cssClass):
			{type: ByCssClass, location: cssClass};
		case ByCssSelector(selector):
			{type: ByCssSelector, location: selector};
	}
}

function elementToByLocator(elementLocator:Null<ElementLocator>):Null<ByLocator> {
	if (elementLocator == null) {
		return null;
	}
	return switch (elementLocator.type) {
		case null:
			null;
		case ByIndex:
			ByIndex(Std.parseInt(elementLocator.location));
		case ById:
			ById(elementLocator.location);
		case ByClassName:
			ByClassName(elementLocator.location);
		case ByCssClass:
			ByCssClass(elementLocator.location);
		case ByCssSelector:
			ByCssSelector(elementLocator.location);
	}
}
