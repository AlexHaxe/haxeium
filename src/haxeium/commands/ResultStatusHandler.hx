package haxeium.commands;

import haxe.PosInfos;

typedef ResultStatusHandler = (name:String, status:ResultStatus, ?pos:PosInfos) -> Bool;

class ResultStatusHelper {
	public static function expectSuccessResult(name:String, status:ResultStatus, ?pos:PosInfos):Bool {
		if (status == Success) {
			return true;
		}
		utest.Assert.fail('$name failed with $status', pos);
		grabFailScreenshot(pos);
		return false;
	}

	public static function expectNotVisibleResult(name:String, status:ResultStatus, ?pos:PosInfos) {
		if (status == FailedNotVisible) {
			return true;
		}
		utest.Assert.fail('$name failed with $status', pos);
		grabFailScreenshot(pos);
		return false;
	}

	public static function expectNotFoundResult(name:String, status:ResultStatus, ?pos:PosInfos) {
		if (status == FailedNotFound) {
			return true;
		}
		utest.Assert.fail('$name failed with $status', pos);
		grabFailScreenshot(pos);
		return false;
	}

	public static function grabFailScreenshot(?pos:PosInfos) {
		if (pos == null) {
			return;
		}
		var name = '${pos.className}_${pos.methodName}_${pos.lineNumber}_fail.png';
		AppDriver.instance.screenGrab(name);
	}
}
