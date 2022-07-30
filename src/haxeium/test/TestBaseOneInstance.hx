package haxeium.test;

import utest.Assert;
import utest.ITest;

class TestBaseOneInstance implements ITest {
	var driver:AppDriver = AppDriver.instance;

	function setupClass() {
		driver.startApp();
	}

	function teardownClass() {
		driver.stopApp();
	}

	public function new() {}
}
