extends GdUnitTestSuite


func test_damage_clamps_and_death_cannot_repeat() -> void:
	var vitals: CombatVitals = auto_free(CombatVitals.new())
	vitals.reset()
	assert_float(vitals.take_damage(25.0)).is_equal(25.0)
	assert_float(vitals.health).is_equal(75.0)
	assert_float(vitals.take_damage(150.0)).is_equal(75.0)
	assert_bool(vitals.is_dead()).is_true()
	assert_float(vitals.take_damage(10.0)).is_equal(0.0)


func test_stamina_rejects_negative_and_insufficient_spending() -> void:
	var vitals: CombatVitals = auto_free(CombatVitals.new())
	vitals.reset()
	assert_bool(vitals.spend(80.0)).is_true()
	assert_bool(vitals.spend(30.0)).is_false()
	assert_bool(vitals.spend(-10.0)).is_false()
	assert_float(vitals.stamina).is_equal(20.0)


func test_regeneration_waits_then_caps_at_maximum() -> void:
	var vitals: CombatVitals = auto_free(CombatVitals.new())
	vitals.regeneration_delay = 0.5
	vitals.regeneration_rate = 20.0
	vitals.reset()
	vitals.spend(40.0)
	vitals.advance(0.25)
	assert_float(vitals.stamina).is_equal(60.0)
	vitals.advance(0.5)
	assert_float(vitals.stamina).is_equal(65.0)
	vitals.advance(10.0)
	assert_float(vitals.stamina).is_equal(100.0)


func test_dead_actor_cannot_spend_or_regenerate_until_reset() -> void:
	var vitals: CombatVitals = auto_free(CombatVitals.new())
	vitals.reset()
	vitals.spend(20.0)
	vitals.take_damage(100.0)
	vitals.advance(5.0)
	assert_float(vitals.stamina).is_equal(80.0)
	assert_bool(vitals.spend(1.0)).is_false()
	vitals.reset()
	assert_float(vitals.health).is_equal(100.0)
	assert_float(vitals.stamina).is_equal(100.0)
