package haxeium.test;

class TestBaseAllRestarts extends TestBaseScreenshotAssert {
	function setup() {
		driver.startApp();
	}

	function teardown() {
		driver.resetInputState();
		driver.stopApp();
	}
}
