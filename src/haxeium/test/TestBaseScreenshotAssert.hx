package haxeium.test;

import haxe.PosInfos;
import utest.Assert;
import utest.ITest;
import haxeium.AppDriver;

class TestBaseScreenshotAssert implements ITest {
	var driver:AppDriver = AppDriver.instance;

	public function new() {}

	public function grabScreenshot(postfix:String, ?pos:PosInfos) {
		if (pos == null) {
			return;
		}
		var name = '${pos.className}_${pos.methodName}_${pos.lineNumber}$postfix.png';
		driver.screenGrab(name);
	}

	function grabFailScreenshot(?pos:PosInfos) {
		grabScreenshot("_fail");
	}

	public function isTrue(cond:Bool, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.isTrue(cond, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function isFalse(value:Bool, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.isFalse(value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function isNull(value:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.isNull(value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function notNull(value:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.notNull(value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function isOfType(value:Dynamic, type:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.isOfType(value, type, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function notEquals(expected:Dynamic, value:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.notEquals(expected, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function equals(expected:Dynamic, value:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.equals(expected, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function match(pattern:EReg, value:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.match(pattern, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function floatEquals(expected:Float, value:Float, ?approx:Float, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.floatEquals(expected, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function same(expected:Dynamic, value:Dynamic, ?recursive:Bool, ?msg:String, ?approx:Float, ?pos:PosInfos):Bool {
		var result = Assert.same(expected, value, recursive, msg, approx, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function raises(method:Void->Void, ?type:Class<Dynamic>, ?msgNotThrown:String, ?msgWrongType:String, ?pos:PosInfos):Bool {
		var result = Assert.raises(method, type, msgNotThrown, msgWrongType, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function allows<T>(possibilities:Array<T>, value:T, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.allows(possibilities, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function contains<T>(match:T, values:Array<T>, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.contains(match, values, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function notContains<T>(match:T, values:Array<T>, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.notContains(match, values, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function stringContains(match:String, value:String, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.stringContains(match, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function stringSequence(sequence:Array<String>, value:String, ?msg:String, ?pos:PosInfos):Bool {
		var result = Assert.stringSequence(sequence, value, msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function pass(msg = "pass expected", ?pos:PosInfos):Bool {
		var result = Assert.pass(msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function fail(msg = "failure expected", ?pos:PosInfos):Bool {
		var result = Assert.fail(msg, pos);
		if (!result) {
			grabFailScreenshot(pos);
		}
		return result;
	}

	public function warn(msg:String, ?pos:PosInfos) {
		Assert.warn(msg);
		grabFailScreenshot(pos);
	}
}
