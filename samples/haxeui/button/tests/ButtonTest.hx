import haxeium.AppDriver;
import haxeium.commands.LocatorType;
import haxeium.test.TestBaseAllRestarts;
import utest.Assert;

class ButtonTest extends TestBaseAllRestarts {
	public function testPressButton1() {
		var button = driver.findElement(ById("button1"));
		Assert.equals("Click Me!", button.text);
		button.click();
		Assert.equals("Thanks!", button.text);
	}

	public function testPressButton2() {
		var button = driver.findElement(ById("button2"));
		Assert.equals("Click Me!", button.text);
		button.click();
		Assert.equals("Thanks!", button.text);
	}

	public function testPressAllButtons() {
		var button1 = driver.findElement(ById("button1"));
		var button2 = driver.findElement(ById("button2"));
		Assert.equals("Click Me!", button1.text);
		Assert.equals("Click Me!", button2.text);

		var buttons = driver.findElements(ByCssClass("button"));
		Assert.isTrue(buttons.length > 0);
		for (button in buttons) {
			trace(button.text);
			button.click();
		}

		Assert.equals("Thanks!", button1.text);
		Assert.equals("Thanks!", button2.text);
	}
}
