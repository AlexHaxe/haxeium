package haxeium.test;

import utest.Assert;
import utest.ITest;

class TestBaseOneInstance extends TestBaseScreenshotAssert {
	function setupClass() {
		driver.startApp();
	}

	function teardownClass() {
		driver.stopApp();
	}
}
