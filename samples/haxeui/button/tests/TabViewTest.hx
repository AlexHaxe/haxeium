import haxeium.Wait;
import haxeium.elements.Element;
import haxeium.test.TestBaseAllRestarts;

class TabViewTest extends TestBaseAllRestarts {
	public function testTabBar() {
		Wait.untilElementBecomesVisible(ById("tv1"));
		var tabView = driver.findElement(ById("tv1"));
		equals(3, tabView.getProp("pageCount"));
		equals(0, tabView.getProp("pageIndex"));

		var page:Element = cast tabView.getProp("selectedPage");
		notNull(page);
		var pageChilds = page.children();
		equals(1, pageChilds.length);
		equals("Page 1 button", pageChilds[0].text);

		tabView.setProp("pageIndex", 2);
		page = cast tabView.getProp("selectedPage");
		notNull(page);
		pageChilds = page.children();
		equals(1, pageChilds.length);
		equals("Page 3 button", pageChilds[0].text);
	}

	public function testClickTab2() {
		var tabView = driver.findElement(ById("tv1"));

		var tabBar = tabView.findElement(ByCssClass("tabbar"));

		var tabBarButtons = tabBar.findElements(ByCssClass("tabbarbutton"));
		equals(3, tabBarButtons.length);

		tabBarButtons[1].click();
		// tabBarButtons[1].findElement(ByCssClass("image")).click();
		equals("Page 2", tabBarButtons[1].text);

		equals(1, tabView.getProp("pageIndex"));

		var pageLocator:Element = cast tabView.getProp("selectedPage");
		notNull(pageLocator);
		var pageButton = pageLocator.findElement(ByCssClass("button"));
		equals("Page 2 button", pageButton.text);
	}
}
