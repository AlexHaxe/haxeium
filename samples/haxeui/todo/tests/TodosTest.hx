import haxeium.Actions;
import haxeium.commands.ResultStatusHandler.ResultStatusHelper;
import haxeium.test.TestBaseAllRestarts;

class TodosTest extends TestBaseAllRestarts {
	public function testEnterOneTodo() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		var ac = new Actions().click(todoItem).sendKeys("do groceries").keyDown(13).pause(0.1).perform();

		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("1 item left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var textFields = todoList.findElements(ByCssClass("textfield"));
		equals(1, textFields.length);
		for (field in textFields) {
			equals("do groceries", field.text);
		}
	}

	public function testEnterTenIdenticalTodos() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		var ac = new Actions().click(todoItem).sendKeys("do groceries").keyDown(13).pause(0.1);
		for (i in 0...10) {
			ac.perform();
		}

		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("10 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var textFields = todoList.findElements(ByCssClass("textfield"));
		equals(10, textFields.length);
		for (field in textFields) {
			equals("do groceries", field.text);
		}
	}

	public function testEnterTenDifferentTodos() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		for (i in 0...10) {
			new Actions().click(todoItem).sendKeys('do groceries $i').keyDown(13).pause(0.1).perform();
		}

		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("10 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var textFields = todoList.findElements(ByCssClass("textfield"));
		equals(10, textFields.length);
		var i = 0;
		for (field in textFields) {
			equals('do groceries ${i++}', field.text);
		}
	}

	public function testEnterOneHundertDifferentTodos() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		for (i in 0...100) {
			new Actions().click(todoItem).sendKeys('do groceries $i').keyDown(13).pause(0.1).perform();
		}

		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("100 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var textFields = todoList.findElements(ByCssClass("textfield"));
		equals(100, textFields.length);
		var i = 0;
		for (field in textFields) {
			equals('do groceries ${i++}', field.text);
		}
	}

	public function testSetTodoDone() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		for (i in 0...10) {
			new Actions().click(todoItem).sendKeys('do groceries $i').keyDown(13).pause(0.1).perform();
		}
		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("10 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var checkboxes = todoList.findElements(ByCssClass("checkbox"));
		equals(10, checkboxes.length);
		new Actions().scrollToElement(checkboxes[5])
			.pause(0.2)
			.click(checkboxes[5])
			.pause(0.1)
			.perform();
		equals("9 items left", activeCountLabel.text);

		var clearCompletedLink = driver.findElement(ById("clearCompletedLink"));
		new Actions().scrollToElement(clearCompletedLink)
			.pause(0.1)
			.click(clearCompletedLink)
			.pause(0.1)
			.perform();

		var checkboxes = todoList.findElements(ByCssClass("checkbox"));
		equals(9, checkboxes.length);
	}

	public function testSetAllDone() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		for (i in 0...10) {
			new Actions().click(todoItem).sendKeys('do groceries $i').keyDown(13).pause(0.1).perform();
		}
		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("10 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var checkboxes = todoList.findElements(ByCssClass("checkbox"));
		equals(10, checkboxes.length);
		var i = 10;
		for (checkbox in checkboxes) {
			new Actions().scrollToElement(checkbox).pause(0.2).click(checkbox).pause(0.1).perform();
			i--;
			if (i == 1) {
				equals('1 item left', activeCountLabel.text);
			} else {
				equals('$i items left', activeCountLabel.text);
			}
		}

		var clearCompletedLink = driver.findElement(ById("clearCompletedLink"));
		new Actions().scrollToElement(clearCompletedLink)
			.pause(0.1)
			.click(clearCompletedLink)
			.pause(0.1)
			.perform();

		var checkboxes = todoList.findElements(ByCssClass("checkbox"));
		equals(0, checkboxes.length);
	}

	public function testDeleteTodo() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		for (i in 0...10) {
			new Actions().click(todoItem).sendKeys('do groceries $i').keyDown(13).pause(0.1).perform();
		}
		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("10 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var buttons = todoList.findElements(ByCssClass("button"));
		equals(10, buttons.length);
		new Actions().scrollToElement(buttons[5]).pause(0.2).click(buttons[5]).pause(0.1).perform();
		equals("9 items left", activeCountLabel.text);

		var clearCompletedLink = driver.findElement(ById("clearCompletedLink"));
		clearCompletedLink.click(ResultStatusHelper.expectNotVisibleResult);
		var checkboxes = todoList.findElements(ByCssClass("checkbox"));
		equals(9, checkboxes.length);
	}

	public function testDeleteAllTodos() {
		var todoItem = driver.findElement(ById("todoItem"));
		notNull(todoItem);
		for (i in 0...10) {
			new Actions().click(todoItem).sendKeys('do groceries $i').keyDown(13).pause(0.1).perform();
		}
		var activeCountLabel = driver.findElement(ById("activeCountLabel"));
		equals("10 items left", activeCountLabel.text);

		var todoList = driver.findElement(ById("todoList"));
		var i = 10;
		while (i > 0) {
			var button = todoList.findElement(ByCssClass("button"));
			new Actions().scrollToElement(button).pause(0.2).click(button).pause(0.1).perform();
			Sys.sleep(0.1);
			i--;
			if (i == 1) {
				equals('1 item left', activeCountLabel.text);
			} else {
				equals('$i items left', activeCountLabel.text);
			}
		}

		var clearCompletedLink = driver.findElement(ById("clearCompletedLink"));
		clearCompletedLink.click(ResultStatusHelper.expectNotVisibleResult);

		var buttons = todoList.findElements(ByCssClass("button"));
		equals(0, buttons.length);
	}
}
