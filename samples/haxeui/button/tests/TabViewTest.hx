import haxeium.AppDriver;
import haxeium.Wait;
import haxeium.commands.ElementLocator;
import haxeium.commands.LocatorType;
import haxeium.elements.DropDownElement;
import haxeium.test.TestBaseAllRestarts;
import utest.Assert;

class TabViewTest extends TestBaseAllRestarts {
	public function testTabBar() {
		Wait.untilElementBecomesVisible(ById("tv1"));
		var tabView = driver.findElement(ById("tv1"));
		Assert.equals(3, tabView.getProp("pageCount"));
		Assert.equals(0, tabView.getProp("pageIndex"));

		trace(driver.findChildren(ById("tv1")));

		var pageLocator:ByLocator = cast tabView.getProp("selectedPage");
		Assert.notNull(pageLocator);
		var page1 = driver.findElement(pageLocator);

		var pageChilds = driver.findChildren(pageLocator);
		Assert.equals(1, pageChilds.length);
		Assert.equals("Page 1", pageChilds[0].text);

		tabView.setProp("pageIndex", 2);

		pageLocator = cast tabView.getProp("selectedPage");
		Assert.notNull(pageLocator);
		var page3 = driver.findElement(pageLocator);

		pageChilds = driver.findChildren(pageLocator);
		Assert.equals(1, pageChilds.length);
		Assert.equals("Page 3", pageChilds[0].text);
	}
}
