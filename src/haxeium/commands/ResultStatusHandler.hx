package haxeium.commands;

typedef ResultStatusHandler = (name:String, status:ResultStatus) -> Bool;

function expectSuccessResult(name:String, status:ResultStatus):Bool {
	if (status == Success) {
		return true;
	}
	utest.Assert.fail('$name failed with $status');
	return false;
}

function expectNotVisibleResult(name:String, status:ResultStatus) {
	if (status == FailedNotVisible) {
		return true;
	}
	utest.Assert.fail('$name failed with $status');
	return false;
}

function expectNotFoundResult(name:String, status:ResultStatus) {
	if (status == FailedNotFound) {
		return true;
	}
	utest.Assert.fail('$name failed with $status');
	return false;
}
