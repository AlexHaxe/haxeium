import haxeium.Wait;
import haxeium.elements.Element;
import haxeium.test.TestBaseAllRestarts;
import utest.Assert;

class LoginTest extends TestBaseAllRestarts {
	public function testLoginOpensDialog() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ById("username"));

		// should not be clickable when there is a modal dialog
		button.click(expectNotVisibleResult);
	}

	public function testEnterUsername() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ById("username"));

		var username = driver.findElement(ById("username"));

		username.click();

		// username.text = "admin";
		username.keyPress("admin");
		Assert.equals("admin", username.text);
	}
}
