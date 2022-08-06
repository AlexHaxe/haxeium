package haxeium.commands;

typedef ResultPropGet = ResultBase & {
	var value:Any;
	@:optional var className:String;
}
