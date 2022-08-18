package haxeium.drivers.events;

#if lime
import haxe.Timer;

class LimeDispatchHelper {
	public static function dispatchMouseEvent(command:CommandMouseEvent, x:Float, y:Float) {
		switch (command.eventName) {
			case Click:
				lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.LEFT);
				lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.LEFT);
			case DoubleClick:
				command.eventName = Click;
				dispatchMouseEvent(command, x, y);
				dispatchMouseEvent(command, x, y);
			case MouseDown:
				lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.LEFT);
			case MouseUp:
				lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.LEFT);
			case MouseWheel:
				lime.app.Application.current.window.onMouseWheel.dispatch(command.x, command.y, lime.ui.MouseWheelMode.UNKNOWN);
			case MiddleClick:
				lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
				lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
			case MiddleMouseDown:
				lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
			case MiddleMouseUp:
				lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
			case RightClick:
				lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.RIGHT);
				lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.RIGHT);
			case RightMouseDown:
				lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.RIGHT);
			case RightMouseUp:
				lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.RIGHT);
			case MoveTo | MoveByOffset:
		}
	}

	public static function dispatchKeyboardEvent(command:CommandKeyboardEvent) {
		switch (command.eventName) {
			case KeyPress:
				if (command.text == null || command.text.length <= 0) {
					return;
				}
				lime.app.Application.current.window.onTextInput.dispatch(command.text);
			case KeyDown:
				if (command.keyCode == null) {
					return;
				}
				var modifier = (command.shiftKey ? (lime.ui.KeyModifier.SHIFT) : 0) | (command.ctrlKey ? (lime.ui.KeyModifier.CTRL) : 0) | (command.altKey ? (lime.ui.KeyModifier.ALT) : 0);
				lime.app.Application.current.window.onKeyDown.dispatch(command.keyCode, modifier);
			case KeyUp:
				if (command.keyCode == null) {
					return;
				}
				var modifier = (command.shiftKey ? (lime.ui.KeyModifier.SHIFT) : 0) | (command.ctrlKey ? (lime.ui.KeyModifier.CTRL) : 0) | (command.altKey ? (lime.ui.KeyModifier.ALT) : 0);
				lime.app.Application.current.window.onKeyUp.dispatch(command.keyCode, modifier);
		}
	}
}
#end
