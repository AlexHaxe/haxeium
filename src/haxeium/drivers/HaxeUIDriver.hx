package haxeium.drivers;

import haxe.Exception;
import haxe.Json;
import haxe.Timer;
import haxe.ui.components.TextField;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.styles.elements.RuleElement;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;
import haxeium.drivers.events.LimeDispatchHelper;

class HaxeUIDriver extends DriverBase<Component> {
	public function new(url:String, intervalMs:Int = 100) {
		super(url, intervalMs);
	}

	override function doFindElement(command:CommandFindElement):ResultBase {
		var component = findComponent(LocatorHelper.elementToByLocator(command.locator), LocatorHelper.elementToByLocator(command.parent));
		if (component == null) {
			return notFound(command.locator);
		}
		var result:ResultFindElement = cast success(getComponentLocator(component));
		result.className = component.className;
		return result;
	}

	override function doFindInteractiveElement(command:CommandFindElement):ResultBase {
		var component = findComponent(LocatorHelper.elementToByLocator(command.locator), LocatorHelper.elementToByLocator(command.parent));
		if (component == null) {
			return notFound(command.locator);
		}
		if (component.hidden) {
			return notVisible(command.locator);
		}
		if (component.disabled) {
			return disabled(command.locator);
		}
		var x = component.screenLeft + component.width / 2;
		var y = component.screenTop + component.height / 2;
		// if we are sending a mouse event to an interactive component, then it should be the one found through findInteractiveComponent
		var componentUnderPoint = findInteractiveComponent(x, y);
		if (componentUnderPoint == null) {
			return notVisible(command.locator);
		}
		if (componentUnderPoint != component) {
			return notVisible(command.locator);
		}

		var result:ResultFindElement = cast success(getComponentLocator(component));
		result.className = component.className;
		return result;
	}

	override function doFindElements(command:CommandFindElements):ResultBase {
		var matchingComponents:Array<Component> = [];

		var byLocator = LocatorHelper.elementToByLocator(command.locator);
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
			searchComponents(findComponent(LocatorHelper.elementToByLocator(command.parent)));
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

	override function doFindElementsUnderPoint(command:CommandFindElementsUnderPoint):ResultBase {
		var components = Screen.instance.findComponentsUnderPoint(command.x, command.y);
		var results:ResultFindElements = cast success(command.locator);
		results.elements = [];
		for (component in components) {
			results.elements.push({locator: getComponentLocator(component), className: component.className});
		}
		return results;
	}

	override function doFindChildren(command:CommandFindChildren):ResultBase {
		var parentComponent:Component = findComponent(LocatorHelper.elementToByLocator(command.locator));
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

	function findInteractiveComponent(x:Float, y:Float):Null<Component> {
		var components = Screen.instance.findComponentsUnderPoint(x, y);
		if (components.length <= 0) {
			return null;
		}
		var componentUnderPoint:Null<Component> = null;
		for (component in components) {
			if (component.id == "modal-background") {
				componentUnderPoint = component;
				continue;
			}
			if (isComponentInteractive(component)) {
				componentUnderPoint = component;
			}
		}
		return componentUnderPoint;
	}

	function isComponentInteractive(component:Component):Bool {
		if ((component is InteractiveComponent)) {
			var interactive:InteractiveComponent = cast component;
			return (interactive.allowFocus);
		}
		return false;
	}

	override function doMouseEvent(command:CommandMouseEvent):ResultBase {
		var component:Component;

		var x:Null<Float> = command.x;
		var y:Null<Float> = command.y;

		if (command.x == null && command.y == null && command.locator == null) {
			x = virtualX;
			y = virtualY;
		}

		if (command.locator != null) {
			component = cast findComponent(LocatorHelper.elementToByLocator(command.locator));
			if (component == null) {
				return notFound(command.locator);
			}
			if (component.hidden) {
				return notVisible(command.locator);
			}
			if (component.disabled) {
				return disabled(command.locator);
			}
			x = component.screenLeft + component.width / 2;
			y = component.screenTop + component.height / 2;
			if ((command.x != null) && (command.y != null)) {
				x += command.x;
				y += command.y;
			}
			if (isComponentInteractive(component)) {
				// if we are sending a mouse event to an interactive component, then it should be the one found through findInteractiveComponent
				var componentUnderPoint = findInteractiveComponent(x, y);
				if (componentUnderPoint == null) {
					return notVisible(command.locator);
				}
				if (componentUnderPoint != component) {
					return notVisible(command.locator);
				}
			}
		}
		switch (command.eventName) {
			case MoveTo:
				virtualX = x;
				virtualY = y;
				return success(command.locator);
			case MoveByOffset:
				virtualX += x;
				virtualY += y;
				return success(command.locator);
			default:
		}
		switch (command.eventName) {
			case Click:
				removeInputDown(LeftMouse);
			case DoubleClick:
				removeInputDown(LeftMouse);
			case MouseDown:
				addInputDown(LeftMouse);
			case MouseUp:
				removeInputDown(LeftMouse);
			case MouseWheel:
			case MiddleClick:
				removeInputDown(MiddleMouse);
			case MiddleMouseDown:
				addInputDown(MiddleMouse);
			case MiddleMouseUp:
				removeInputDown(MiddleMouse);
			case RightClick:
				removeInputDown(RightMouse);
			case RightMouseDown:
				addInputDown(RightMouse);
			case RightMouseUp:
				removeInputDown(RightMouse);
			case MoveTo | MoveByOffset:
		}

		try {
			#if lime
			runInMainThread(function() {
				LimeDispatchHelper.dispatchMouseEvent(command, x, y);
			});
			virtualX = x;
			virtualY = y;
			return success(command.locator);
			#end
		} catch (e:Exception) {
			return error(command.locator, e.message);
		}

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

	override function doKeyboardEvent(command:CommandKeyboardEvent):ResultBase {
		if (command.keyCode != null) {
			switch (command.eventName) {
				case KeyPress:
				case KeyDown:
					addInputDown(KeyCode(command.keyCode));
				case KeyUp:
					removeInputDown(KeyCode(command.keyCode));
			}
		}
		try {
			#if lime
			runInMainThread(function() {
				LimeDispatchHelper.dispatchKeyboardEvent(command);
			});
			#end
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
		if ((result.value is Component)) {
			var component = cast result.value;
			result.value = getComponentLocator(component);
			result.className = component.className;
		}
		return result;
	}

	override function doResetInputs():ResultBase {
		for (down in inputsDown) {
			switch (down) {
				case LeftMouse:
					#if lime
					runInMainThread(function() {
						LimeDispatchHelper.dispatchMouseEvent({command: MouseEvent, eventName: MouseUp}, -1, -1);
					});
					#end
				case RightMouse:
					#if lime
					runInMainThread(function() {
						LimeDispatchHelper.dispatchMouseEvent({command: MouseEvent, eventName: RightMouseUp}, -1, -1);
					});
					#end
				case MiddleMouse:
					#if lime
					runInMainThread(function() {
						LimeDispatchHelper.dispatchMouseEvent({command: MouseEvent, eventName: MiddleMouseUp}, -1, -1);
					});
					#end
				case KeyCode(keyCode):
					#if lime
					runInMainThread(function() {
						LimeDispatchHelper.dispatchKeyboardEvent({
							command: KeyboardEvent,
							eventName: KeyUp,
							keyCode: keyCode,
							altKey: false,
							ctrlKey: false,
							shiftKey: false
						});
					});
					#end
			}
		}
		virtualX = -1;
		virtualY = -1;
		return success();
	}

	override function doScrollToElement(command:CommandScrollToElement):ResultBase {
		var component = findComponent(LocatorHelper.elementToByLocator(command.locator));
		if (component == null) {
			return notFound(command.locator);
		}
		var parent = component.parentComponent;
		if (parent == null) {
			return notFound(command.locator);
		}
		var found = false;
		while (parent != null) {
			if ((parent is ScrollView)) {
				var scrollView:ScrollView = cast parent;
				runInMainThread(function() {
					scrollView.ensureVisible(component);
				});
				found = true;
			}
			parent = parent.parentComponent;
		}
		if (found) {
			return success(command.locator);
		}
		return notFound(command.locator);
	}

	override function findComponent(locator:ByLocator, ?parent:ByLocator):Component {
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
