package haxeium.commands;

enum abstract Command(String) {
	var FindElement = "findElement";
	var FindElements = "findElements";
	var FindChildren = "findChildren";
	var MouseEvent = "mouseEvent";
	var PropGet = "propGet";
	var PropSet = "propSet";
	var Restart = "restart";
}
