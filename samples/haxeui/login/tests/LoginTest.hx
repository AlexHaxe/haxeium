import haxeium.Actions;
import haxeium.Wait;
import haxeium.commands.ResultStatusHandler;
import haxeium.test.TestBaseAllRestarts;

class LoginTest extends TestBaseAllRestarts {
	public function testLoginOpensDialog() {
		var button = driver.findElement(ById("loginButton"));
		equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		Wait.untilElementBecomesAvailable(ById("username"));
		// should not be clickable when there is a modal dialog
		button.click(ResultStatusHelper.expectNotVisibleResult);
		var dialog = driver.findElements(ByClassName("LoginDialog"));
		notNull(dialog);
	}

	public function testCancelLoginDialog() {
		var button = driver.findElement(ById("loginButton"));
		equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		var dialog = driver.findElement(ByClassName("LoginDialog"));
		notNull(dialog);
		var cancel = driver.findElement(ById("{{cancel}}"));
		cancel.click();

		Wait.untilElementBecomesUnavailable(ByClassName("LoginDialog"));
		dialog = driver.findElement(ByClassName("LoginDialog"), ResultStatusHelper.expectNotFoundResult);
		isNull(dialog);
	}

	public function testSubmitEmpty() {
		var button = driver.findElement(ById("loginButton"));
		equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		Wait.untilElementBecomesAvailable(ById("username"));
		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();
		Wait.untilElementBecomesAvailable(ByCssClass("messagebox"));
		var messageBox = driver.findElement(ByCssClass("messagebox"));
		equals("Missing Username", messageBox.getProp("title"));
		equals("Username is required!", messageBox.getProp("message"));
		var closeBtn = messageBox.findElement(ByCssClass("button"));
		closeBtn.click();

		Wait.untilElementBecomesUnavailable(ByClassName("messagebox"));
		Wait.untilInteractiveElementBecomesAvailable(ById("{{cancel}}"));
		var cancelBtn = driver.findElement(ById("{{cancel}}"));
		cancelBtn.click();
	}

	public function testSubmitOnlyUsername() {
		var button = driver.findElement(ById("loginButton"));
		equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		Wait.untilElementBecomesAvailable(ById("username"));
		var username = driver.findElement(ById("username"));
		new Actions().click(username).sendKeys("admin").perform();
		equals("admin", username.text);
		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();

		Wait.untilElementBecomesAvailable(ByCssClass("messagebox"));
		var messageBox = driver.findElement(ByCssClass("messagebox"));
		equals("Missing Password", messageBox.getProp("title"));
		equals("Password is required!", messageBox.getProp("message"));
		var closeBtn = messageBox.findElement(ByCssClass("button"));
		closeBtn.click();

		Wait.untilElementBecomesUnavailable(ByClassName("messagebox"));
		Wait.untilInteractiveElementBecomesAvailable(ById("{{cancel}}"));
		var cancelBtn = driver.findElement(ById("{{cancel}}"));
		cancelBtn.click();
	}

	public function testSubmitUserAndPassword() {
		var button = driver.findElement(ById("loginButton"));
		equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		var username = driver.findElement(ById("username"));
		new Actions().click(username).sendKeys("admin").perform();

		isTrue(username.getProp("focus"));
		equals("admin", username.text);
		var password = driver.findElement(ById("password"));
		new Actions().click(password).sendKeys("password").perform();
		isTrue(password.getProp("focus"));
		equals("password", password.text);
		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();

		Wait.untilElementBecomesUnavailable(ByClassName("LoginDialog"));
		var dialog = driver.findElement(ByClassName("LoginDialog"), ResultStatusHelper.expectNotFoundResult);
		isNull(dialog);
		var messageBox = driver.findElement(ByCssClass("messagebox"), ResultStatusHelper.expectNotFoundResult);
		isNull(messageBox);
	}

	public function testSubmitUserAndPasswordMistype() {
		var button = driver.findElement(ById("loginButton"));
		equals("Login", button.text);
		button.click();

		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		Wait.untilInteractiveElementBecomesAvailable(ById("username"));
		var username = driver.findElement(ById("username"));
		new Actions().click(username).sendKeys("adminn").keyDown(8).perform();
		isTrue(username.getProp("focus"));

		var password = driver.findElement(ById("password"));
		new Actions().click(password).sendKeys("passwordd").keyDown(8).perform();
		isTrue(password.getProp("focus"));

		equals("admin", username.text);
		equals("password", password.text);

		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();
		Wait.untilElementBecomesUnavailable(ByClassName("LoginDialog"));
		var dialog = driver.findElement(ByClassName("LoginDialog"), ResultStatusHelper.expectNotFoundResult);
		isNull(dialog);
		var messageBox = driver.findElement(ByCssClass("messagebox"), ResultStatusHelper.expectNotFoundResult);
		isNull(messageBox);
	}
}
