package haxeium.test;

import utest.Assert;
import utest.ITest;

class TestBaseAllRestarts  extends TestBaseScreenshotAssert {

	function setup() {
		driver.startApp();
	}

	function teardown() {
		driver.stopApp();
	}

}
