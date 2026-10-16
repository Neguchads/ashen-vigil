extends GdUnitTestSuite

var _thing: Interactable


func before_test() -> void:
	_thing = auto_free(Interactable.new())


func test_emits_when_enabled() -> void:
	var by: Node = auto_free(Node.new())
	var got: Array = []
	_thing.interacted.connect(func(who: Node) -> void: got.append(who))
	_thing.interact(by)
	assert_array(got).contains_exactly([by])


func test_does_nothing_when_disabled() -> void:
	var got: Array = []
	_thing.interacted.connect(func(who: Node) -> void: got.append(who))
	_thing.enabled = false
	_thing.interact(auto_free(Node.new()))
	assert_array(got).is_empty()
