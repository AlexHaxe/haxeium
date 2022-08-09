package haxeium.drivers;

import haxe.Exception;
import haxe.Json;
import haxe.Timer;
import haxe.ui.components.TextField;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.styles.elements.RuleElement;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;
import openfl.events.Event;

class HaxeUIDriver extends DriverBase<Component> {
	public function new(url:String) {
		super(url);
	}

	function doFindElement(command:CommandFindElement):ResultBase {
		var component = findComponent(elementToByLocator(command.locator), elementToByLocator(command.parent));
		if (component == null) {
			return notFound(command.locator);
		}
		var result:ResultFindElement = cast success(getComponentLocator(component));
		result.className = component.className;
		return result;
	}

	function doFindElements(command:CommandFindElements):ResultBase {
		var matchingComponents:Array<Component> = [];

		var byLocator = elementToByLocator(command.locator);
		function searchComponents(root:Component) {
			switch (byLocator) {
				case ByIndex(index):
					var component = components[index];
					if (component == null) {
						return;
					}
					matchingComponents.push(component);
				case ById(id):
					root.walkComponents(function(comp:Component) {
						if (comp.id == id) {
							matchingComponents.push(comp);
						}
						return true;
					});
				case ByClassName(name):
					root.walkComponents(function(comp:Component) {
						var c:Class<Dynamic> = Type.getClass(comp);
						if (Type.getClassName(c) == name) {
							matchingComponents.push(comp);
						}
						return true;
					});
				case ByCssClass(cssClass):
					root.walkComponents(function(comp:Component) {
						if (comp.hasClass(cssClass)) {
							matchingComponents.push(comp);
						}
						return true;
					});
				case ByCssSelector(selector):
					var rule = new RuleElement(selector, []);
					root.walkComponents(function(comp:Component) {
						if (rule.match(comp)) {
							matchingComponents.push(comp);
						}
						return true;
					});
			}
		}
		if (command.parent != null) {
			searchComponents(findComponent(elementToByLocator(command.parent)));
		} else {
			for (root in Screen.instance.rootComponents) {
				searchComponents(root);
			}
		}
		if (matchingComponents.length <= 0) {
			return notFound(command.locator);
		}
		var results:ResultFindElements = cast success(command.locator);
		results.elements = [];
		for (component in matchingComponents) {
			results.elements.push({locator: getComponentLocator(component), className: component.className});
		}

		return results;
	}

	function doFindElementsUnderPoint(command:CommandFindElementsUnderPoint):ResultBase {
		var components = Screen.instance.findComponentsUnderPoint(command.x, command.y);
		var results:ResultFindElements = cast success(command.locator);
		results.elements = [];
		for (component in components) {
			results.elements.push({locator: getComponentLocator(component), className: component.className});
		}
		return results;
	}

	function doFindChildren(command:CommandFindChildren):ResultBase {
		var parentComponent:Component = findComponent(elementToByLocator(command.locator));
		if (parentComponent == null) {
			return notFound(command.locator);
		}

		var results:ResultFindElements = cast success(command.locator);
		results.elements = [];
		for (component in parentComponent.childComponents) {
			results.elements.push({locator: getComponentLocator(component), className: component.className});
		}
		return results;
	}

	@:access(haxe.ui.core.Component)
	function findInteractiveComponent(x:Float, y:Float):Null<Component> {
		var components = Screen.instance.findComponentsUnderPoint(x, y);
		if (components.length <= 0) {
			return null;
		}
		var componentUnderPoint:Null<Component> = null;
		for (comp in components) {
			if (comp.id == "modal-background") {
				return comp;
			}
			if (comp is InteractiveComponent) {
				return comp;
			}
			if (comp.onClick != null || comp.hasEvent(MouseEvent.RIGHT_CLICK)) {
				return comp;
			}
		}
		return null;
	}

	function doMouseEvent(command:CommandMouseEvent):ResultBase {
		var component:Component;

		var x:Null<Float> = command.x;
		var y:Null<Float> = command.y;

		if (command.x == null || command.y == null) {
			component = cast findComponent(elementToByLocator(command.locator));
			if (component == null) {
				return notFound(command.locator);
			}
			x = component.screenLeft + component.width / 2;
			y = component.screenTop + component.height / 2;
		}
		#if lime
		try {
			switch (command.eventName) {
				case Click:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.LEFT);
					Sys.sleep(0.02);
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.LEFT);
				case DoubleClick:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.LEFT);
					Sys.sleep(0.02);
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.LEFT);
					Sys.sleep(0.05);
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.LEFT);
					Sys.sleep(0.02);
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.LEFT);
				case MouseDown:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.LEFT);
				case MouseUp:
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.LEFT);
				case MouseWheel:
					lime.app.Application.current.window.onMouseWheel.dispatch(command.x, command.y, lime.ui.MouseWheelMode.UNKNOWN);
				case MiddleClick:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
					Sys.sleep(0.02);
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
				case MiddleMouseDown:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
				case MiddleMouseUp:
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.MIDDLE);
				case RightClick:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.RIGHT);
					Sys.sleep(0.02);
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.RIGHT);
				case RightMouseDown:
					lime.app.Application.current.window.onMouseDown.dispatch(x, y, lime.ui.MouseButton.RIGHT);
				case RightMouseUp:
					lime.app.Application.current.window.onMouseUp.dispatch(x, y, lime.ui.MouseButton.RIGHT);
			}
		} catch (e:Exception) {
			return error(command.locator, e.message);
		}
		return success(command.locator);
		#end

		if (command.x != null && command.y != null) {
			component = findInteractiveComponent(command.x, command.y);
		} else {
			var componentUnderPoint = findInteractiveComponent(x, y);
			if (componentUnderPoint == null) {
				return notVisible(command.locator);
			}
			if (componentUnderPoint != component) {
				return notVisible(command.locator);
			}
		}
		if (component == null) {
			return notFound(command.locator);
		}
		if (component.hidden) {
			return notVisible(command.locator);
		}
		if (component.disabled) {
			return disabled(command.locator);
		}

		if (!component.hasEvent(command.eventName)) {
			return disabled(command.locator);
		}
		var event = new MouseEvent(command.eventName);
		event.target = component;
		try {
			component.dispatch(event);
		} catch (e:Exception) {
			return error(command.locator, e.message);
		}
		return success(command.locator);
	}

	// @:access(lime.app.Application)
	function doKeyboardEvent(command:CommandKeyboardEvent):ResultBase {
		try {
			switch (command.eventName) {
				case KeyPress:
					if (command.text == null || command.text.length <= 0) {
						return success();
					}
					#if lime
					lime.app.Application.current.window.onTextInput.dispatch(command.text);
					#end
				case KeyDown:
					if (command.keyCode == null) {
						return success();
					}
					#if lime
					var modifier = (command.shiftKey ? (lime.ui.KeyModifier.SHIFT) : 0) | (command.ctrlKey ? (lime.ui.KeyModifier.CTRL) : 0) | (command.altKey ? (lime.ui.KeyModifier.ALT) : 0);
					lime.app.Application.current.window.onKeyDown.dispatch(command.keyCode, modifier);
					#end
				case KeyUp:
					if (command.keyCode == null) {
						return success();
					}
					#if lime
					var modifier = (command.shiftKey ? (lime.ui.KeyModifier.SHIFT) : 0) | (command.ctrlKey ? (lime.ui.KeyModifier.CTRL) : 0) | (command.altKey ? (lime.ui.KeyModifier.ALT) : 0);
					lime.app.Application.current.window.onKeyUp.dispatch(command.keyCode, modifier);
					#end
			}
			return success();
		} catch (e:Exception) {
			return error(e.message);
		}
	}

	override function doPropGet(command:CommandPropGet):ResultPropGet {
		var result:ResultPropGet = cast super.doPropGet(command);
		if (result.status != Success) {
			return result;
		}
		if (result.value is Component) {
			var component = cast result.value;
			result.value = getComponentLocator(component);
			result.className = component.className;
		}
		return result;
	}

	function findComponent(locator:ByLocator, ?parent:ByLocator):Component {
		var component:Component = null;

		function searchComponent(root:Component) {
			switch (locator) {
				case ByIndex(index):
					component = components[index];
				case ById(id):
					component = root.findComponent(id, true, "id");
				case ByClassName(name):
					root.walkComponents(function(comp:Component) {
						var c:Class<Dynamic> = Type.getClass(comp);
						if (Type.getClassName(c) == name) {
							component = comp;
							return false;
						}
						return true;
					});
				case ByCssClass(cssClass):
					root.walkComponents(function(comp:Component) {
						if (comp.hasClass(cssClass)) {
							component = comp;
							return false;
						}
						return true;
					});
				case ByCssSelector(selector):
					var rule = new RuleElement(selector, []);
					root.walkComponents(function(comp:Component) {
						if (rule.match(comp)) {
							component = comp;
							return false;
						}
						return true;
					});
			}
		}
		if (parent != null) {
			searchComponent(findComponent(parent));
			if (component == null) {
				return null;
			}
			return component;
		}

		for (root in Screen.instance.rootComponents) {
			searchComponent(root);
			if (component != null) {
				return component;
			}
		}
		return null;
	}
}
