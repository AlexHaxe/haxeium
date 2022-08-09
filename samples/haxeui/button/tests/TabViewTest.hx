import haxeium.Wait;
import haxeium.elements.Element;
import haxeium.test.TestBaseAllRestarts;
import utest.Assert;

class TabViewTest extends TestBaseAllRestarts {
	public function testTabBar() {
		Wait.untilElementBecomesVisible(ById("tv1"));
		var tabView = driver.findElement(ById("tv1"));
		Assert.equals(3, tabView.getProp("pageCount"));
		Assert.equals(0, tabView.getProp("pageIndex"));

		var page:Element = cast tabView.getProp("selectedPage");
		Assert.notNull(page);
		var pageChilds = page.children();
		Assert.equals(1, pageChilds.length);
		Assert.equals("Page 1 button", pageChilds[0].text);

		tabView.setProp("pageIndex", 2);
		page = cast tabView.getProp("selectedPage");
		Assert.notNull(page);
		pageChilds = page.children();
		Assert.equals(1, pageChilds.length);
		Assert.equals("Page 3 button", pageChilds[0].text);
	}

	public function testClickTab2() {
		var tabView = driver.findElement(ById("tv1"));

		var tabBar = tabView.findElement(ByCssClass("tabbar"));

		var tabBarButtons = tabBar.findElements(ByCssClass("tabbarbutton"));
		Assert.equals(3, tabBarButtons.length);

		tabBarButtons[1].click();
		// tabBarButtons[1].findElement(ByCssClass("image")).click();
		Assert.equals("Page 2", tabBarButtons[1].text);

		Assert.equals(1, tabView.getProp("pageIndex"));

		var pageLocator:Element = cast tabView.getProp("selectedPage");
		Assert.notNull(pageLocator);
		var pageButton = pageLocator.findElement(ByCssClass("button"));
		Assert.equals("Page 2 button", pageButton.text);
	}
}
