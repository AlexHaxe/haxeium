import haxeium.AppDriver;
import haxeium.Wait;
import haxeium.commands.LocatorType;
import haxeium.elements.DropDownElement;
import haxeium.test.TestBaseAllRestarts;

class DropDownTest extends TestBaseAllRestarts {
	public function testDropDown() {
		Wait.untilElementBecomesVisible(ById("dropdown1"));
		var dropdown:DropDownElement = cast driver.findElement(ById("dropdown1"));
		equals("Select Item", dropdown.text);
		equals(-1, dropdown.selectedIndex);
		isNull(dropdown.selectedItem);
		dropdown.mouseDown();
		dropdown.getProp("dataSource");
		dropdown.selectedIndex = 2;
		equals(2, dropdown.selectedIndex);
		notNull(dropdown.selectedItem);
		equals("Item 3", dropdown.text);
	}
}
