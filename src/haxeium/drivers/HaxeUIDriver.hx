package haxeium.drivers;

import haxe.Exception;
import haxe.Json;
import haxe.Timer;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.styles.elements.RuleElement;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;

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
	function doMouseEvent(command:CommandMouseEvent):ResultBase {
		var component:Component = findComponent(elementToByLocator(command.locator));
		if (component == null) {
			return notFound(command.locator);
		}
		if (component.hidden) {
			return notVisible(command.locator);
		}
		if (component.disabled) {
			return disabled(command.locator);
		}
		// if (!component.hasEvent(command.eventName)) {
		// 	return disabled(command.locator);
		// }
		var event = new MouseEvent(command.eventName);
		event.target = component;
		try {
			component.dispatch(event);
		} catch (e:Exception) {
			return error(command.locator, e.message);
		}

		return success(command.locator);
	}

	override function doPropGet(command:CommandPropGet):ResultPropGet {
		var result:ResultPropGet = cast super.doPropGet(command);
		if (result.status != Success) {
			return result;
		}
		if (result.value is Component) {
			result.value = getComponentLocator(result.value);
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
