extends GdUnitTestSuite

const MAIN := "res://src/main/main.tscn"


func test_attack_requires_weapon_and_costs_stamina_once() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	assert_bool(player.combat.try_attack()).is_false()
	player.equip_weapon(ContentRegistry.get_def("core:rusty_dagger") as WeaponDef)
	assert_bool(player.combat.try_attack()).is_true()
	assert_bool(player.combat.try_attack()).is_false()
	assert_float(player.vitals.stamina).is_equal(90.0)


func test_reading_and_pause_prevent_combat() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	player.equip_weapon(ContentRegistry.get_def("core:rusty_dagger") as WeaponDef)
	player.show_text("Carta aberta")
	assert_bool(player.combat.try_attack()).is_false()
	assert_bool(player.combat.try_dodge(Vector3.FORWARD)).is_false()
	player.close_text()
	var menu := runner.scene().get_node("PauseMenu")
	menu.set_open(true)
	var blocked: bool = not player.combat.try_attack()
	menu.set_open(false)
	assert_bool(blocked).is_true()
	assert_float(player.vitals.stamina).is_equal(100.0)


func test_block_only_protects_front_and_dodge_prevents_damage() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	player.rotation = Vector3.ZERO
	player.equip_weapon(ContentRegistry.get_def("core:rusty_dagger") as WeaponDef)
	player.combat.set_blocking(true)
	player.take_damage(20.0, player.global_position + Vector3.FORWARD)
	assert_float(player.vitals.health).is_equal(96.0)
	player.take_damage(20.0, player.global_position + Vector3.BACK)
	assert_float(player.vitals.health).is_equal(76.0)
	player.combat.set_blocking(false)
	assert_bool(player.combat.try_dodge(Vector3.RIGHT)).is_true()
	player.take_damage(20.0, player.global_position + Vector3.FORWARD)
	assert_float(player.vitals.health).is_equal(76.0)


func test_wounded_wolf_is_distant_passive_and_can_be_spared() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	var wolf := root.get_node("WoundedWolf")
	assert_float(wolf.global_position.distance_to(player.global_position)).is_greater(20.0)
	assert_bool(wolf.injured).is_true()
	wolf.get_node("Interaction").interact(player)
	assert_str(wolf.choice).is_equal("spared")
	assert_bool(player.reading).is_true()
	assert_bool(wolf.get_node("Interaction").enabled).is_false()


func test_dagger_hit_damages_wolf_once_after_windup() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	var wolf := runner.scene().get_node("HostileWolf")
	wolf.set_physics_process(false)
	player.global_position = Vector3(0, 0.05, 10)
	player.rotation = Vector3.ZERO
	(player.get_node("Head") as Node3D).rotation.x = -0.65
	wolf.global_position = Vector3(0, 0, 9.2)
	player.equip_weapon(ContentRegistry.get_def("core:rusty_dagger") as WeaponDef)
	await runner.simulate_frames(3)
	var before: float = wolf.vitals.health
	assert_bool(player.combat.try_attack()).is_true()
	player.combat.advance(0.2)
	assert_float(wolf.vitals.health).is_equal(before - 12.0)
	player.combat.advance(0.2)
	assert_float(wolf.vitals.health).is_equal(before - 12.0)


func test_killed_wolf_collapses_and_no_longer_blocks_or_interacts() -> void:
	var runner := scene_runner(MAIN)
	var wolf := runner.scene().get_node("HostileWolf")
	wolf.take_damage(100.0, Vector3.ZERO)
	await runner.simulate_frames(35)
	assert_str(wolf.state).is_equal("dead")
	assert_int(wolf.collision_layer).is_equal(0)
	assert_bool(wolf.get_node("Interaction").enabled).is_false()
	assert_float(absf(wolf.get_node("Visual").rotation.z)).is_greater(1.0)


func test_wall_blocks_strike_and_distant_enemy_is_out_of_reach() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	var wolf := root.get_node("HostileWolf")
	player.set_physics_process(false)
	wolf.set_physics_process(false)
	player.global_position = Vector3(0, 0.05, 10)
	player.rotation = Vector3.ZERO
	(player.get_node("Head") as Node3D).rotation.x = -0.65
	wolf.global_position = Vector3(0, 0, 9.2)
	player.equip_weapon(ContentRegistry.get_def("core:rusty_dagger") as WeaponDef)
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2, 3, 0.15)
	shape.shape = box
	wall.add_child(shape)
	root.add_child(wall)
	wall.position = Vector3(0, 1.5, 9.6)
	await runner.simulate_frames(3)
	assert_bool(player.combat.try_attack()).is_true()
	player.combat.advance(0.6)
	assert_float(wolf.vitals.health).is_equal(48.0)
	wall.queue_free()
	wolf.global_position.z = 5.0
	await runner.simulate_frames(60)
	assert_bool(player.combat.try_attack()).is_true()
	player.combat.advance(0.6)
	assert_float(wolf.vitals.health).is_equal(48.0)


func test_hostile_wolf_can_attack_and_wounded_wolf_can_be_killed() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	var hostile := root.get_node("HostileWolf")
	player.global_position = hostile.global_position + Vector3(0, 0.05, 1)
	# Atualiza a consulta física antes de controlar o tempo exato do ataque.
	await runner.simulate_frames(3)
	hostile.set_physics_process(false)
	hostile._physics_process(0.01)
	hostile._physics_process(0.6)
	assert_float(player.vitals.health).is_less(100.0)
	var wounded := root.get_node("WoundedWolf")
	wounded.take_damage(30.0, player.global_position)
	assert_str(wounded.choice).is_equal("killed")
	assert_bool(wounded.get_node("Interaction").enabled).is_false()


func test_pause_preserves_attack_recovery() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	player.equip_weapon(ContentRegistry.get_def("core:rusty_dagger") as WeaponDef)
	assert_bool(player.combat.try_attack()).is_true()
	player.combat.advance(0.2)
	root.get_node("PauseMenu").set_open(true)
	root.get_node("PauseMenu").set_open(false)
	assert_bool(player.combat.try_attack()).is_false()
	player.combat.advance(0.4)
	assert_bool(player.combat.try_attack()).is_true()
