package haxeium;

import haxe.Exception;
import haxe.PosInfos;
import haxe.Timer;
import haxeium.AppDriver;
import haxeium.commands.ElementLocator;
import haxeium.elements.Element;

class Wait {
	public static function untilElementBecomesAvailable(locator:Null<ByLocator> = null, element:Null<Element> = null, ?pos:PosInfos) {
		if (element != null) {
			locator = element.locator;
		}
		if (locator == null) {
			return;
		}
		until(function() {
			return AppDriver.instance.findElement(locator, waitForAllResults) != null;
		}, pos);
	}

	public static function untilElementBecomesUnavailable(locator:Null<ByLocator> = null, element:Null<Element> = null, ?pos:PosInfos) {
		if (element != null) {
			locator = element.locator;
		}
		if (locator == null) {
			return;
		}
		until(function() {
			return AppDriver.instance.findElement(locator, waitForAllResults) == null;
		}, pos);
	}

	public static function untilInteractiveElementBecomesAvailable(locator:Null<ByLocator> = null, element:Null<Element> = null, ?pos:PosInfos) {
		if (element != null) {
			locator = element.locator;
		}
		if (locator == null) {
			return;
		}
		until(function() {
			return AppDriver.instance.findInteractiveElement(locator, waitForAllResults) != null;
		}, pos);
	}

	public static function untilElementBecomesVisible(locator:Null<ByLocator> = null, element:Null<Element> = null, ?pos:PosInfos) {
		if (element != null) {
			locator = element.locator;
		}
		if (locator == null) {
			return;
		}
		until(function() {
			var element = AppDriver.instance.findElement(locator, waitForAllResults);
			if (element == null) {
				return false;
			}
			var hidden:Bool = cast element.getProp("hidden");
			return !hidden;
		}, pos);
	}

	public static function untilPropertyEqualsValue(locator:Null<ByLocator> = null, element:Null<Element> = null, name:String, expectedValue:Any,
			?pos:PosInfos) {
		if (element != null) {
			locator = element.locator;
		}
		if (locator == null) {
			return;
		}
		until(function() {
			var element = AppDriver.instance.findElement(locator, waitForAllResults);
			if (element == null) {
				return false;
			}

			var currentValue = element.getProp(name);
			return currentValue == expectedValue;
		}, pos);
	}

	public static function until(waitFunc:() -> Bool, waitTime:Float = 0.1, retries:Int = 600, ?pos:PosInfos) {
		var counter = 0;
		while (counter++ < retries) {
			var startStamp = Timer.stamp();
			if (waitFunc()) {
				return;
			}
			var elapsed = Timer.stamp() - startStamp;
			while (elapsed > waitTime) {
				elapsed -= waitTime;
				counter++;
			}
			Sys.sleep(waitTime - elapsed);
		}
		throw new WaitTimeoutException("wait timeout");
	}

	static function waitForAllResults(name:String, status:ResultStatus, ?pos:PosInfos):Bool {
		return true;
	}
}

class WaitTimeoutException extends Exception {}
