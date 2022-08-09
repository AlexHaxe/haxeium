package haxeium.commands;

typedef ResultStatusHandler = (name:String, status:ResultStatus) -> Bool;

class ResultStatusHelper {
	public static function expectSuccessResult(name:String, status:ResultStatus):Bool {
		if (status == Success) {
			return true;
		}
		utest.Assert.fail('$name failed with $status');
		return false;
	}

	public static function expectNotVisibleResult(name:String, status:ResultStatus) {
		if (status == FailedNotVisible) {
			return true;
		}
		utest.Assert.fail('$name failed with $status');
		return false;
	}

	public static function expectNotFoundResult(name:String, status:ResultStatus) {
		if (status == FailedNotFound) {
			return true;
		}
		utest.Assert.fail('$name failed with $status');
		return false;
	}
}
