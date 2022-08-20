package haxeium;

import haxe.Json;
import haxe.extern.EitherType;
import haxe.io.Bytes;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
import hx.ws.SocketImpl;
import hx.ws.Types.MessageType;
import hx.ws.WebSocketHandler;
import hx.ws.WebSocketServer;
import utest.Assert;
import haxeium.commands.ResultStatusHandler;
import haxeium.elements.DropDownElement;
import haxeium.elements.Element;
import haxeium.elements.NoSuchElementException;

class AppDriver {
	static final RESPONSE_WAIT_TIME:Float = 0.01;
	static final RESPONSE_WAIT_RETRIES:Float = 500;

	public static var instance(default, null):AppDriver;

	public var connected(default, null):Bool;
	public var screenshotFolder:String;

	var server:WebSocketServer<AppSocketHandler>;
	var handler:AppSocketHandler;
	var socketThread:Thread;
	var appRestarter:Null<AppRestarter>;

	var logger:Null<LogFunction>;

	public function new(host:String, port:Int, appRestarter:Null<AppRestarter>, ?logger:LogFunction) {
		this.appRestarter = appRestarter;
		this.logger = logger;
		if (logger == null) {
			this.logger = printLogger;
		}
		if (appRestarter != null) {
			appRestarter.logger = this.logger;
		}
		instance = this;
		connected = false;
		screenshotFolder = "screenshots";

		server = new WebSocketServer<AppSocketHandler>(host, port, 1);
		server.start();
	}

	public function waitForClient() {
		while (true) {
			if (connected) {
				break;
			}
			Sys.sleep(RESPONSE_WAIT_TIME);
		}
	}

	public function startApp() {
		if (appRestarter != null) {
			appRestarter.start();
		}
		waitForClient();
	}

	public function stopApp() {
		var command:CommandRestart = {command: Restart};
		send(command, false);
		connected = false;
		if (handler != null) {
			handler.clear();
		}
		if (appRestarter != null) {
			if (handler != null) {
				handler.clear();
			}
			appRestarter.kill();
		}
	}

	public function findElement(locator:ByLocator, ?parent:ByLocator, ?handler:ResultStatusHandler):Null<Element> {
		var command:CommandFindElement = {
			command: FindElement,
			locator: LocatorHelper.byToElementLocator(locator),
			parent: LocatorHelper.byToElementLocator(parent)
		};

		var result:ResultFindElement = cast send(command);
		if (result == null) {
			throw new NoSuchElementException(locator);
		}
		if (handler == null) {
			handler = ResultStatusHelper.expectSuccessResult;
		}
		if (!handler("findElement", result.status)) {
			throw new NoSuchElementException(locator);
		}
		if (result.status != Success) {
			// handler may allow e.g. FailedNotFound because a test expects an element to not exist,
			// but we don't want an Element instance for anything other than Success
			return null;
		}
		return createElement(result.locator, result.className);
	}

	public function findInteractiveElement(locator:ByLocator, ?parent:ByLocator, ?handler:ResultStatusHandler):Null<Element> {
		var command:CommandFindElement = {
			command: FindInteractiveElement,
			locator: LocatorHelper.byToElementLocator(locator),
			parent: LocatorHelper.byToElementLocator(parent)
		};

		var result:ResultFindElement = cast send(command);
		if (result == null) {
			throw new NoSuchElementException(locator);
		}
		if (handler == null) {
			handler = ResultStatusHelper.expectSuccessResult;
		}
		if (!handler("findInteractiveElement", result.status)) {
			throw new NoSuchElementException(locator);
		}
		if (result.status != Success) {
			// handler may allow e.g. FailedNotFound because a test expects an element to not exist,
			// but we don't want an Element instance for anything other than Success
			return null;
		}
		return createElement(result.locator, result.className);
	}

	public function findElements(locator:ByLocator, ?parent:ByLocator):Array<Element> {
		var command:CommandFindElements = {
			command: FindElements,
			locator: LocatorHelper.byToElementLocator(locator),
			parent: LocatorHelper.byToElementLocator(parent)
		};

		var result:ResultFindElements = cast send(command);
		if (result == null) {
			return [];
		}
		if (result.status != Success) {
			return [];
		}
		return result.elements.map((element) -> createElement(element.locator, element.className));
	}

	public function findChildren(parent:ByLocator):Array<Element> {
		var command:CommandFindChildren = {command: FindChildren, locator: LocatorHelper.byToElementLocator(parent)};

		var result:ResultFindElements = cast send(command);
		if (result == null) {
			return [];
		}
		if (result.status != Success) {
			return [];
		}
		return result.elements.map((element) -> createElement(element.locator, element.className));
	}

	public function screenGrab(fileName:String):Bool {
		var command:CommandScreenGrab = {command: ScreenGrab};

		var result:Null<Bytes> = cast send(command);
		if (result == null) {
			return false;
		}
		if (!FileSystem.exists(screenshotFolder)) {
			FileSystem.createDirectory(screenshotFolder);
		}
		File.saveBytes(Path.join([screenshotFolder, fileName]), result);
		return true;
	}

	public function scrollToElement(locator:ByLocator, ?handler:ResultStatusHandler) {
		var command:CommandScrollToElement = {
			command: ScrollToElement,
			locator: LocatorHelper.byToElementLocator(locator)
		};

		var result:ResultBase = cast send(command);
		if (result == null) {
			throw new NoSuchElementException(locator);
		}
		if (handler == null) {
			handler = ResultStatusHelper.expectSuccessResult;
		}
		if (!handler("scrollToElement", result.status)) {
			throw new NoSuchElementException(locator);
		}
		return;
	}

	public function resetInputState():Bool {
		var command:CommandResetInput = {command: ResetInput};

		var result:ResultBase = cast send(command);
		if (result == null) {
			return false;
		}
		if (result.status != Success) {
			return false;
		}
		return true;
	}

	public static function createElement(locator:ElementLocator, className:String):Element {
		var byLocator = LocatorHelper.elementToByLocator(locator);
		return switch (className) {
			case "haxe.ui.components.DropDown":
				new DropDownElement(byLocator);
			default:
				new Element(byLocator);
		}
	}

	@:allow(haxeium.AppSocketHandler)
	function connectChanged(status:Bool, handler:AppSocketHandler) {
		if (connected == status) {
			return;
		}
		if (connected) {
			logger("--- connection lost");
			this.handler.clear();
			this.handler = null;
			// Assert.fail("connection failed!");
			connected = false;
			return;
		}
		logger("--- new connection established");
		this.handler = handler;
		handler.onmessage = onMessage;
		handler.onerror = onError;
		connected = status;
	}

	function onError(error:Any) {
		Assert.fail('connection error: $error');
	}

	function onMessage(message:MessageType) {
		switch (message) {
			case BytesMessage(content):
				logger(content.readAllAvailableBytes().toString());
			case StrMessage(content):
				logger("received (not processed): " + Json.parse(content));
		}
	}

	public function send(command:CommandBase, withReply:Bool = true):ResultBase {
		if (handler == null) {
			// Assert.fail("no client connection for send operation");
			return null;
		}
		if (!connected) {
			// Assert.fail("no client connection for send operation");
			return null;
		}
		logger('>> $command');
		handler.send(Json.stringify(command));
		if (!withReply) {
			return null;
		}
		var waitCounter = 0;
		var result:Null<EitherType<ResultBase, Bytes>> = null;
		handler.onmessage = function(message:MessageType) {
			switch (message) {
				case BytesMessage(content):
					result = content.readAllAvailableBytes();
					logger('<< binary data (${(result : Bytes).length})');
				case StrMessage(content):
					result = Json.parse(content);
					logger('<< $result');
					logTransmission(command, result);
			}
		}
		while (waitCounter++ < RESPONSE_WAIT_RETRIES) {
			if (!connected) {
				return null;
			}
			if (result != null) {
				break;
			}
			Sys.sleep(RESPONSE_WAIT_TIME);
		}
		if (waitCounter >= RESPONSE_WAIT_RETRIES) {
			logTransmission(command, null);
			Assert.fail("timeout while waiting for result");
		}

		handler.onmessage = onMessage;
		return result;
	}

	public function locatorToText(locator:Null<ElementLocator>) {
		if (locator == null) {
			return "null";
		}
		return switch (locator.type) {
			case ByIndex:
				'ByIndex(${locator.location})';
			case ById:
				'ById("${locator.location}")';
			case ByClassName:
				'ByClassName("${locator.location}")';
			case ByCssClass:
				'ByCssClass("${locator.location}")';
			case ByCssSelector:
				'ByCssSelector("${locator.location}")';
		}
	}

	function logTransmission(cmd:CommandBase, result:Null<ResultBase>) {
		var cmdLocator:CommandLocatorBase = cast cmd;
		var text = switch (cmd.command) {
			case FindElement:
				'findElement(${locatorToText(cmdLocator.locator)})';
			case FindInteractiveElement:
				'findInteractiveElement(${locatorToText(cmdLocator.locator)})';
			case FindElements:
				'findElements(${locatorToText(cmdLocator.locator)})';
			case FindElementsUnderPoint:
				'findElementsUnderPoint(${locatorToText(cmdLocator.locator)})';
			case FindChildren:
				'findChildren(${locatorToText(cmdLocator.locator)})';
			case KeyboardEvent:
				var cmdKeyboard:CommandKeyboardEvent = cast cmd;
				switch (cmdKeyboard.eventName) {
					case KeyPress:
						'keyPress(${cmdKeyboard.text})';
					case KeyDown:
						'keyDown(${cmdKeyboard.keyCode})';
					case KeyUp:
						'keyUp(${cmdKeyboard.keyCode})';
				}
			case MouseEvent:
				var cmdMouse:CommandMouseEvent = cast cmd;
				switch (cmdMouse.eventName) {
					case Click:
						'click(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MouseDown:
						'mouseDown(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MouseUp:
						'mouseUp(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case DoubleClick:
						'doubleClick(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MouseWheel:
						'mouseWheel(${locatorToText(cmdMouse.locator)}, deltaX=${cmdMouse.x}, deltaY=${cmdMouse.y})';
					case MiddleClick:
						'middleClick(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MiddleMouseDown:
						'middleMouseDown(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MiddleMouseUp:
						'middleMouseUp(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case RightClick:
						'rightClick(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case RightMouseDown:
						'rightMouseDown(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case RightMouseUp:
						'rightMouseUp(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MoveTo:
						'moveTo(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
					case MoveByOffset:
						'moveByOffset(${locatorToText(cmdMouse.locator)}, x=${cmdMouse.x}, y=${cmdMouse.y})';
				}
			case PropGet:
				'propGet(${locatorToText(cmdLocator.locator)})';
			case PropSet:
				'propSet(${locatorToText(cmdLocator.locator)})';
			case Restart:
				"restart";
			case ResetInput:
				"resetInput";
			case ScreenGrab:
				"screenGrab";
			case ScrollToElement:
				'scrollToElement(${locatorToText(cmdLocator.locator)})';
		}
		if (result != null) {
			switch (result.status) {
				case null:
					text = "timeout - " + text;
				case Success:
					text = "success - " + text;
				case Error:
					var error:ResultError = cast result;
					text = "error - " + text + " - " + error.message;
				case FailedDisabled:
					text = "failed: disabled - " + text;
				case FailedNotFound:
					text = "failed: not found - " + text;
				case FailedNotVisible:
					text = "failed: not visible - " + text;
				case FailedReadOnly:
					text = "failed: readonly - " + text;
				case Unsupported:
					text = "unsupported: " + text;
			}
		}
		logger(text);
	}

	public static function traceLogger(text:String) {
		trace(text);
	}

	public static function printLogger(text:String) {
		Sys.println(text);
	}

	public static var loggerFileName = "driver.log";

	public static function fileLogger(text:String) {
		var output = File.append(loggerFileName);
		output.writeString(text + "\n");
		output.close();
	}
}

class AppSocketHandler extends WebSocketHandler {
	public function new(s:SocketImpl) {
		super(s);
		onopen = function() {
			AppDriver.instance.connectChanged(true, this);
		}
		onclose = function() {
			AppDriver.instance.connectChanged(false, null);
		}
	}

	@:access(haxeium.AppDriver)
	public function clear() {
		onopen = function() {};
		onclose = function() {};
		onmessage = function(message) {
			AppDriver.instance.logger('$message');
		};
		onerror = function(error) {
			AppDriver.instance.logger('$error');
		};
	}
}

typedef LogFunction = (text:String) -> Void;
