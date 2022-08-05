package;

import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
	public function new() {
		super();

		loginButton.onClick = function(e) {
			var dialog = new LoginDialog();
			dialog.onDialogClosed = function(e:DialogEvent) {
				trace(e.button);
			}
			dialog.showDialog();
		}
	}
}
