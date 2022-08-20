import haxe.ui.containers.VBox;
import haxe.ui.core.Platform;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.IDataItem;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

class TodoItem implements IDataItem {
	public var completed:Bool;
	public var label:String;

	public function new(label:String) {
		this.label = label;
		this.completed = false;
	}
}

@:build(haxe.ui.macros.ComponentMacros.build("assets/todos-view.xml"))
class TodosView extends VBox {
	private var todoData = new ArrayDataSource<TodoItem>();

	public function new() {
		super();
		todoData.onChange = updateActiveCount;
		todoList.dataSource = todoData;
	}

	private function updateActiveCount() {
		todoList.hidden = optionsContainer.hidden = pageBottom.hidden = (!todoData.isFiltered && todoData.size == 0);
		var activeCount = 0;
		for (i in 0...todoData.size) {
			if (todoData.get(i).completed == false) {
				activeCount++;
			}
		}
		activeCountLabel.text = activeCount + " item" + (activeCount == 1 ? "" : "s") + " left";
		clearCompletedLink.hidden = (activeCount == todoData.size);
	}

	@:bind(todoItem, KeyboardEvent.KEY_DOWN)
	private function onTodoItemKey(e:KeyboardEvent) {
		if (e.keyCode == Platform.instance.KeyEnter) {
			if (todoItem.text != "") {
				todoData.add(new TodoItem(todoItem.text));
				todoItem.text = "";
			}
		}
	}

	@:bind(todoList, ItemEvent.COMPONENT_EVENT)
	private function onTodoItemEvent(e:ItemEvent) {
		if (e.source.id == "delete") {
			todoData.removeAt(e.itemIndex);
		} else if (e.source.id == "completed") {
			(e.source.value == true) ? e.target.addClass("completed", true, true) : e.target.removeClass("completed", true, true);
		}
	}

	@:bind(optionsButtonBar, UIEvent.CHANGE)
	private function onOptionsChange(_) {
		switch (optionsButtonBar.selectedIndex) {
			case 0:
				todoData.clearFilter();
			case 1:
				todoData.filter((index, item) -> item.completed == false);
			case 2:
				todoData.filter((index, item) -> item.completed == true);
		}
	}

	@:bind(clearCompletedLink, MouseEvent.CLICK)
	private function onClearCompleted(_) {
		var i = todoData.size;
		while (--i >= 0) {
			var item = todoData.get(i);
			if (item.completed) {
				todoData.remove(item);
			}
		}
	}
}
