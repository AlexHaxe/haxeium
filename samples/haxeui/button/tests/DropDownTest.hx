import haxeium.AppDriver;
import haxeium.Wait;
import haxeium.commands.LocatorType;
import haxeium.elements.DropDownElement;
import haxeium.test.TestBaseAllRestarts;
import utest.Assert;

class DropDownTest extends TestBaseAllRestarts {
	public function testDropDown() {
		Wait.untilElementBecomesVisible(ById("dropdown1"));
		var dropdown:DropDownElement = cast driver.findElement(ById("dropdown1"));
		Assert.equals("Select Item", dropdown.text);
		Assert.equals(-1, dropdown.selectedIndex);
		Assert.isNull(dropdown.selectedItem);
		dropdown.mouseDown();
		trace(dropdown.getProp("dataSource"));
		dropdown.selectedIndex = 2;
		Assert.equals(2, dropdown.selectedIndex);
		Assert.notNull(dropdown.selectedItem);
		Assert.equals("Item 3", dropdown.text);
	}
}
