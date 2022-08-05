package haxeium.commands;

typedef ResultBase = {
	var status:ResultStatus;
	@:optional var locator:ElementLocator;
}

enum abstract ResultStatus(String) {
	var Success = "Success";
	var Error = "error";
	var FailedNotFound = "FailedNotFound";
	var FailedNotVisible = "FailedNotVisible";
	var FailedReadOnly = "FailedReadOnly";
	var FailedDisabled = "FailedDisabled";
	var Unsupported = "Unsupported";
}
