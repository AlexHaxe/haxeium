package haxeium.drivers;

import haxe.Exception;
import haxe.Json;
import haxe.Timer;
import haxe.extern.EitherType;
import haxe.io.Bytes;
import haxe.ui.containers.menus.Menu.MenuEvent;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;
#if sys
import sys.thread.Mutex;
#end

class DriverBase<T> {
	var socket:WebSocket;
	var components:Array<T>;
	var virtualX:Float;
	var virtualY:Float;
	var inputsDown:Array<InputDown>;

	var url:String;
	var intervalMs:Int;
	var mainThreadAction:Null<MainThreadAction>;
	#if sys
	var mainThreadMutex:Mutex;
	#end

	public function new(url:String, intervalMs:Int = 100) {
		components = [];
		virtualX = -1;
		virtualY = -1;
		inputsDown = [];
		this.url = url;
		this.intervalMs = intervalMs;
		mainThreadAction = null;
		#if sys
		mainThreadMutex = new Mutex();
		#end
		Timer.delay(function() {
			start();
		}, 500);
		Timer.delay(pollCommands, intervalMs);
	}

	function pollCommands() {
		#if sys
		mainThreadMutex.acquire();
		#end
		try {
			if (mainThreadAction != null) {
				mainThreadAction();
				mainThreadAction = null;
			}
		} catch (e:Exception) {
			trace(e);
		}
		#if sys
		mainThreadMutex.release();
		#end
		Timer.delay(pollCommands, intervalMs);
	}

	function runInMainThread(action:MainThreadAction) {
		#if sys
		mainThreadMutex.acquire();
		mainThreadAction = action;
		mainThreadMutex.release();
		while (true) {
			mainThreadMutex.acquire();
			if (mainThreadAction == null) {
				mainThreadMutex.release();
				break;
			}
			mainThreadMutex.release();
			Sys.sleep(0.01);
		}
		#else
		mainThreadAction = action;
		mainThreadAction();
		mainThreadAction = null;
		#end
	}

	function start() {
		try {
			socket = new WebSocket(url);
			socket.onopen = onOpen;
			socket.onclose = onClose;
			socket.onmessage = onMessage;
			socket.onerror = onError;
		} catch (e:Exception) {
			onError(e);
		}
	}

	function onOpen() {
		trace("socket connection established");
	}

	function onClose() {
		// trace("socket connection closed");
	}

	function onMessage(message:MessageType) {
		switch (message) {
			case BytesMessage(content):
			case StrMessage(content):
				var result = runCommand(Json.parse(content));
				if (result != null) {
					if ((result is Bytes)) {
						socket.send(result);
					} else {
						socket.send(Json.stringify(result));
					}
				}
		}
	}

	function onError(error) {
		// trace("connection failed - retrying");
		socket = null;
		Timer.delay(start, 2000);
	}

	function runCommand(command:CommandBase):Null<EitherType<ResultBase, Bytes>> {
		switch (command.command) {
			case FindElement:
				return doFindElement(cast command);
			case FindInteractiveElement:
				return doFindInteractiveElement(cast command);
			case FindElements:
				return doFindElements(cast command);
			case FindElementsUnderPoint:
				return doFindElementsUnderPoint(cast command);
			case FindChildren:
				return doFindChildren(cast command);
			case KeyboardEvent:
				return doKeyboardEvent(cast command);
			case MouseEvent:
				return doMouseEvent(cast command);
			case PropSet:
				return doPropSet(cast command);
			case PropGet:
				return doPropGet(cast command);
			case Restart:
				doRestart(command);
				return null;
			case ResetInput:
				return doResetInputs();
			case ScreenGrab:
				return doScreenGrab(command);
			case ScrollToElement:
				return doScrollToElement(cast command);
		}
		return notFound();
	}

	function getComponentLocator(component:T):ElementLocator {
		var index = components.indexOf(component);
		if (index < 0) {
			index = components.length;
			components.push(component);
		}
		return {type: ByIndex, location: '$index'};
	}

	function doFindElement(command:CommandFindElement):ResultBase {
		return null;
	}

	function doFindInteractiveElement(command:CommandFindElement):ResultBase {
		return null;
	}

	function doFindElements(command:CommandFindElements):ResultBase {
		return null;
	}

	function doFindElementsUnderPoint(command:CommandFindElementsUnderPoint):ResultBase {
		return null;
	}

	function doFindChildren(command:CommandFindChildren):ResultBase {
		return null;
	}

	function doMouseEvent(command:CommandMouseEvent):ResultBase {
		return null;
	}

	function doKeyboardEvent(command:CommandKeyboardEvent):ResultBase {
		return null;
	}

	function doResetInputs():ResultBase {
		return null;
	}

	function doScrollToElement(command:CommandScrollToElement):ResultBase {
		return null;
	}

	function addInputDown(inputDown:InputDown) {
		for (down in inputsDown) {
			if ('$down' == '$inputDown') {
				return;
			}
		}
		inputsDown.push(inputDown);
	}

	function removeInputDown(inputDown:InputDown) {
		for (down in inputsDown) {
			if ('$down' == '$inputDown') {
				inputsDown.remove(down);
			}
		}
	}

	function doScreenGrab(command:CommandBase):EitherType<ResultBase, Bytes> {
		#if openfl
		var stage = openfl.Lib.current.stage;
		var bitmapData = new openfl.display.BitmapData(stage.stageWidth, stage.stageHeight);
		bitmapData.draw(stage);
		var bytes:Bytes = bitmapData.encode(new openfl.geom.Rectangle(0, 0, stage.stageWidth, stage.stageHeight), new openfl.display.PNGEncoderOptions());
		return bytes;
		#end
		return unsupported();
	}

	function doPropSet(command:CommandPropSet):ResultBase {
		var component = findComponent(LocatorHelper.elementToByLocator(command.locator));
		if (component == null) {
			return notFound(command.locator);
		}
		runInMainThread(function() {
			Reflect.setProperty(component, command.name, command.value);
		});
		var result:ResultPropGet = cast success(command.locator);
		result.value = Reflect.getProperty(component, command.name);
		return result;
	}

	function doPropGet(command:CommandPropGet):ResultBase {
		var component = findComponent(LocatorHelper.elementToByLocator(command.locator));
		if (component == null) {
			return notFound(command.locator);
		}
		var result:ResultPropGet = cast success(command.locator);
		result.value = Reflect.getProperty(component, command.name);
		return result;
	}

	function doRestart(command:CommandBase):ResultBase {
		socket.close();
		#if js
		js.Browser.location.reload(true);
		return success();
		#else
		Sys.exit(0);
		return unsupported();
		#end
	}

	function findComponent(locator:ByLocator, ?parent:ByLocator):T {
		return null;
	};

	function success(?locator:ElementLocator):ResultBase {
		return {
			status: Success,
			locator: locator
		};
	}

	function error(?locator:ElementLocator, message:String):ResultError {
		return {
			status: Error,
			locator: locator,
			message: message
		};
	}

	function disabled(?locator:ElementLocator):ResultBase {
		return {
			status: FailedDisabled,
			locator: locator
		};
	}

	function notFound(?locator:ElementLocator):ResultBase {
		return {
			status: FailedNotFound,
			locator: locator
		};
	}

	function notVisible(locator:ElementLocator):ResultBase {
		return {
			status: FailedNotVisible,
			locator: locator
		};
	}

	function unsupported():ResultBase {
		return {
			status: Unsupported
		};
	}
}

typedef MainThreadAction = () -> Void;

enum InputDown {
	LeftMouse;
	RightMouse;
	MiddleMouse;
	KeyCode(keyCode:Int);
}
