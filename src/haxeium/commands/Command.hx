package haxeium.commands;

enum abstract Command(String) {
	var FindElement = "findElement";
	var FindInteractiveElement = "findInteractiveElement";
	var FindElements = "findElements";
	var FindElementsUnderPoint = "findElementsUnderPoint";
	var FindChildren = "findChildren";
	var MouseEvent = "mouseEvent";
	var KeyboardEvent = "keyboardEvent";
	var PropGet = "propGet";
	var PropSet = "propSet";
	var Restart = "restart";
	var ResetInput = "resetInput";
	var ScreenGrab = "screenGrab";
	var ScrollToElement = "scrollToElement";
}
