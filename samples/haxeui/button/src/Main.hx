package;

import haxe.ui.HaxeUIApp;
import haxeium.drivers.HaxeUIDriver;

class Main {
	public static function main() {
		var app = new HaxeUIApp();
		app.ready(function() {
			app.addComponent(new MainView());

			app.start();
			new HaxeUIDriver("ws://127.0.0.1:9999");
		});
	}
}
