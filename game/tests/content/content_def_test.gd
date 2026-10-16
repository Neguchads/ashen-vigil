extends GdUnitTestSuite


func test_valid_ids() -> void:
	assert_bool(ContentDef.is_valid_id("core:rusty_dagger")).is_true()
	assert_bool(ContentDef.is_valid_id("my_mod2:blade_01")).is_true()


func test_invalid_ids() -> void:
	assert_bool(ContentDef.is_valid_id("rusty_dagger")).is_false()
	assert_bool(ContentDef.is_valid_id("Core:Dagger")).is_false()
	assert_bool(ContentDef.is_valid_id("core:rusty dagger")).is_false()
	assert_bool(ContentDef.is_valid_id("core:")).is_false()
	assert_bool(ContentDef.is_valid_id(":dagger")).is_false()
	assert_bool(ContentDef.is_valid_id("a:b:c")).is_false()


func test_content_types() -> void:
	assert_str(String(ContentDef.new().get_content_type())).is_equal("content")
	assert_str(String(ItemDef.new().get_content_type())).is_equal("item")
	assert_str(String(WeaponDef.new().get_content_type())).is_equal("weapon")
