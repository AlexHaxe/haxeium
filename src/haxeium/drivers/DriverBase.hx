package haxeium.drivers;

import haxe.Exception;
import haxe.Json;
import haxe.Timer;
import haxe.extern.EitherType;
import haxe.io.Bytes;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;

abstract class DriverBase<T> {
	var socket:WebSocket;
	var components:Array<T>;

	var url:String;

	public function new(url:String) {
		components = [];
		this.url = url;
		start();
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
					if (result is Bytes) {
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
			case ScreenGrab:
				return doScreenGrab(command);
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

	abstract function doFindElement(command:CommandFindElement):ResultBase;

	abstract function doFindElements(command:CommandFindElements):ResultBase;

	abstract function doFindElementsUnderPoint(command:CommandFindElementsUnderPoint):ResultBase;

	abstract function doFindChildren(command:CommandFindChildren):ResultBase;

	abstract function doMouseEvent(command:CommandMouseEvent):ResultBase;

	abstract function doKeyboardEvent(command:CommandKeyboardEvent):ResultBase;

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
		var component = findComponent(elementToByLocator(command.locator));
		if (component == null) {
			return notFound(command.locator);
		}
		Reflect.setProperty(component, command.name, command.value);
		var result:ResultPropGet = cast success(command.locator);
		result.value = Reflect.getProperty(component, command.name);
		return result;
	}

	function doPropGet(command:CommandPropGet):ResultBase {
		var component = findComponent(elementToByLocator(command.locator));
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

	abstract function findComponent(locator:ByLocator, ?parent:ByLocator):T;

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
