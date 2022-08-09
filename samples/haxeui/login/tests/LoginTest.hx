import haxeium.Wait;
import haxeium.commands.ResultStatusHandler;
import haxeium.test.TestBaseAllRestarts;
import utest.Assert;

class LoginTest extends TestBaseAllRestarts {
	public function testLoginOpensDialog() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ById("username"));
		// should not be clickable when there is a modal dialog
		button.click(ResultStatusHelper.expectNotVisibleResult);
		var dialog = driver.findElements(ByClassName("LoginDialog"));
		Assert.notNull(dialog);
	}

	public function testCancelLoginDialog() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ByClassName("LoginDialog"));
		var cancel = driver.findElement(ById("{{dialog.cancel}}"));
		cancel.click();
		var dialog = driver.findElement(ByClassName("LoginDialog"), ResultStatusHelper.expectNotFoundResult);
		Assert.isNull(dialog);
	}

	public function testSubmitEmpty() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ById("username"));
		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();
		Wait.untilElementBecomesAvailable(ByCssClass("messagebox"));
		var messageBox = driver.findElement(ByCssClass("messagebox"));
		Assert.equals("Missing Username", messageBox.getProp("title"));
		Assert.equals("Username is required!", messageBox.getProp("message"));
		var closeBtn = messageBox.findElement(ByCssClass("button"));
		closeBtn.click();
		var cancelBtn = driver.findElement(ById("{{dialog.cancel}}"));
		cancelBtn.click();
	}

	public function testSubmitOnlyUsername() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ById("username"));

		var username = driver.findElement(ById("username"));
		username.click();
		username.keyPress("admin");
		Assert.equals("admin", username.text);

		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();
		Wait.untilElementBecomesAvailable(ByCssClass("messagebox"));
		var messageBox = driver.findElement(ByCssClass("messagebox"));
		Assert.equals("Missing Password", messageBox.getProp("title"));
		Assert.equals("Password is required!", messageBox.getProp("message"));
		var closeBtn = messageBox.findElement(ByCssClass("button"));
		closeBtn.click();
		var cancelBtn = driver.findElement(ById("{{dialog.cancel}}"));
		cancelBtn.click();
	}

	public function testSubmitUserAndPassword() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ById("username"));

		var username = driver.findElement(ById("username"));
		username.click();
		Assert.isTrue(username.getProp("focus"));
		username.keyPress("admin");
		Assert.equals("admin", username.text);

		var password = driver.findElement(ById("password"));
		password.click();
		Assert.isTrue(password.getProp("focus"));
		password.keyPress("admin");
		Assert.equals("admin", password.text);

		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();
		var dialog = driver.findElement(ByClassName("LoginDialog"), ResultStatusHelper.expectNotFoundResult);
		Assert.isNull(dialog);
		var messageBox = driver.findElement(ByCssClass("messagebox"), ResultStatusHelper.expectNotFoundResult);
		Assert.isNull(messageBox);
	}

	public function testSubmitUserMistypeAndPassword() {
		var button = driver.findElement(ById("loginButton"));
		Assert.equals("Login", button.text);
		button.click();
		Wait.untilElementBecomesAvailable(ById("username"));

		var username = driver.findElement(ById("username"));
		username.click();
		Assert.isTrue(username.getProp("focus"));
		username.keyPress("adminn");
		username.keyDown(8);
		Assert.equals("admin", username.text);

		var password = driver.findElement(ById("password"));
		password.click();
		Assert.isTrue(password.getProp("focus"));
		password.keyPress("admin");
		Assert.equals("admin", password.text);

		var loginBtn = driver.findElement(ById("login"));
		loginBtn.click();
		var dialog = driver.findElement(ByClassName("LoginDialog"), ResultStatusHelper.expectNotFoundResult);
		Assert.isNull(dialog);
		var messageBox = driver.findElement(ByCssClass("messagebox"), ResultStatusHelper.expectNotFoundResult);
		Assert.isNull(messageBox);
	}
}
