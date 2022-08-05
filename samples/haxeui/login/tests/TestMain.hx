import haxeium.AppDriver;
import haxeium.AppRestarter;
import utest.ITest;
import utest.Runner;
import utest.ui.text.DiagnosticsReport;

class TestMain {
	static function main() {
		#if html5
		// lime test html5
		var driver = new AppDriver("localhost", 9999, null);
		#end

		#if linux
		// lime build linux
		new AppDriver("localhost", 9999, new AppRestarter("./Main", [], "build/openfl/linux/bin"));
		#end

		#if windows
		// lime build windows
		new AppDriver("localhost", 9999, new AppRestarter("./Main.exe", [], "build/openfl/windows/bin"));
		#end

		var tests:Array<ITest> = [new LoginTest()];
		var runner:Runner = new Runner();

		new DiagnosticsReport(runner);
		for (test in tests) {
			runner.addCase(test);
		}
		runner.run();
	}
}
