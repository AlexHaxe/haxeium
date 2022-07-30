import haxeium.AppDriver;
import haxeium.AppRestarter;
import utest.ITest;
import utest.Runner;
import utest.ui.text.DiagnosticsReport;

class TestMain {
	static function main() {
		// lime test html5
		// var driver = new AppDriver("localhost", 9999, null);

		// lime build linux
		new AppDriver("localhost", 9999, new AppRestarter("./Main", [], "build/openfl/linux/bin"));

		var tests:Array<ITest> = [new ButtonTest(), new DropDownTest(), new TabViewTest()];
		var runner:Runner = new Runner();

		new DiagnosticsReport(runner);
		for (test in tests) {
			runner.addCase(test);
		}
		runner.run();
	}
}
