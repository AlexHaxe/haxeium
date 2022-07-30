package haxeium.drivers;

import haxe.Exception;
import haxe.Json;
import haxe.Timer;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;
import json2object.JsonParser;
import json2object.JsonWriter;

abstract class DriverBase<T> {
	var socket:WebSocket;
	var components:Array<T>;
	var parser:JsonParser<CommandBase>;
	var writer:JsonWriter<ResultBase>;

	var url:String;

	public function new(url:String) {
		components = [];
		this.url = url;
		parser = new JsonParser<CommandBase>();
		writer = new JsonWriter<ResultBase>();
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
		trace("socket connection closed");
	}

	function onMessage(message:MessageType) {
		switch (message) {
			case BytesMessage(content):
				trace(content);
			case StrMessage(content):
				var result = runCommand(Json.parse(content));
				if (result != null) {
					socket.send(Json.stringify(result));
				}
		}
	}

	function onError(error) {
		trace("connection failed - retrying");
		socket = null;
		Timer.delay(start, 500);
	}

	function runCommand(command:CommandBase):Null<ResultBase> {
		switch (command.command) {
			case FindElement:
				return doFindElement(cast command);
			case FindElements:
				return doFindElements(cast command);
			case FindChildren:
				return doFindChildren(cast command);
			case MouseEvent:
				return doMouseEvent(cast command);
			case PropSet:
				return doPropSet(cast command);
			case PropGet:
				return doPropGet(cast command);
			case Restart:
				doRestart(command);
				return null;
		}
		return notFound(command.locator);
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

	abstract function doFindChildren(command:CommandFindChildren):ResultBase;

	abstract function doMouseEvent(command:CommandMouseEvent):ResultBase;

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
		return success(command.locator);
		#else
		Sys.exit(0);
		return unsupported(command.locator);
		#end
	}

	abstract function findComponent(locator:ByLocator, ?parent:ByLocator):T;

	function success(locator:ElementLocator):ResultBase {
		return {
			status: Success,
			locator: locator
		};
	}

	function error(locator:ElementLocator, message:String):ResultError {
		return {
			status: Error,
			locator: locator,
			message: message
		};
	}

	function disabled(locator:ElementLocator):ResultBase {
		return {
			status: FailedDisabled,
			locator: locator
		};
	}

	function notFound(locator:ElementLocator):ResultBase {
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

	function unsupported(locator:ElementLocator):ResultBase {
		return {
			status: Unsupported,
			locator: locator
		};
	}
}
