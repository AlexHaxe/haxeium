package haxeium;

import haxe.Exception;
import haxeium.AppDriver;
import haxeium.commands.ElementLocator;

class Wait {
	public static function untilElementBecomesAvailable(locator:ByLocator) {
		until(function() {
			return AppDriver.instance.findElement(locator) != null;
		});
	}

	public static function untilElementBecomesVisible(locator:ByLocator) {
		until(function() {
			var element = AppDriver.instance.findElement(locator);
			if (element == null) {
				return false;
			}
			var hidden:Bool = cast element.getProp("hidden");
			return !hidden;
		});
	}

	public static function until(waitFunc:() -> Bool, waitTime:Float = 1, retries:Int = 60) {
		var counter = 0;
		while (counter++ < retries) {
			if (waitFunc()) {
				return;
			}
			Sys.sleep(waitTime);
		}
		throw new WaitTimeoutException("wait timeout");
	}
}

class WaitTimeoutException extends Exception {}
