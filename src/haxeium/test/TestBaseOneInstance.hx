package haxeium.test;

class TestBaseOneInstance extends TestBaseScreenshotAssert {
	function setupClass() {
		driver.startApp();
	}

	function teardownClass() {
		driver.stopApp();
	}

	function teardown() {
		driver.resetInputState();
	}
}
