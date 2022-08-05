import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

@:build(haxe.ui.macros.ComponentMacros.build("assets/login-dialog.xml"))
class LoginDialog extends Dialog {
	public function new() {
		super();
		buttons = DialogButton.CANCEL | "Login";
	}

	public override function validateDialog(button:DialogButton, fn:Bool->Void) {
		if (button == "Login") {
			if (username.text == "" || username.text == null) {
				Dialogs.messageBox("Username is required!", "Missing Username", MessageBoxType.TYPE_WARNING);
				fn(false);
			} else if (password.text == "" || password.text == null) {
				Dialogs.messageBox("Password is required!", "Missing Password", MessageBoxType.TYPE_WARNING);
				fn(false);
			} else {
				fn(true);
			}
		} else {
			fn(true);
		}
	}
}
