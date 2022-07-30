package haxeium.test;

import utest.Assert;
import utest.ITest;

class TestBaseAllRestarts implements ITest {
	var driver:AppDriver = AppDriver.instance;

	function setup() {
		driver.startApp();
	}

	function teardown() {
		driver.stopApp();
	}

	public function new() {}
}
