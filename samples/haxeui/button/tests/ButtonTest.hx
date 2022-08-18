import haxeium.Actions;
import haxeium.Wait;
import haxeium.test.TestBaseAllRestarts;

class ButtonTest extends TestBaseAllRestarts {
	public function testPressButton1() {
		var button = driver.findElement(ById("button1"));
		equals("Click Me!", button.text);
		button.click();

		Wait.untilPropertyEqualsValue(button.locator, "text", "Thanks!");
		equals("Thanks!", button.text);
	}

	public function testPressButton2() {
		var button = driver.findElement(ById("button2"));
		equals("Click Me!", button.text);
		button.click();
		Wait.untilPropertyEqualsValue(button.locator, "text", "Thanks!");
		equals("Thanks!", button.text);
	}

	public function testPressAllButtons() {
		var button1 = driver.findElement(ById("button1"));
		var button2 = driver.findElement(ById("button2"));
		equals("Click Me!", button1.text);
		equals("Click Me!", button2.text);
		var buttons = driver.findElements(ByCssClass("button"));
		isTrue(buttons.length > 0);
		for (button in buttons) {
			// click with random +/- 2.5 pixels offset from center of button
			new Actions().click(button, Math.random() * 5 - 2.5, Math.random() * 5 - 2.5).perform();
		}
		Wait.untilPropertyEqualsValue(button1.locator, "text", "Thanks!");
		equals("Thanks!", button1.text);
		equals("Thanks!", button2.text);
	}
}
