extends GdUnitTestSuite
## Quebras cobertas: arma não nasce, E não coleta, coleta duplica e mod fica só no registro.

const MAIN := "res://src/main/main.tscn"


func test_dagger_spawns_from_registry_and_can_be_equipped_once() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	var spawner := root.get_node_or_null("DaggerSpawn")
	assert_object(spawner).is_not_null()
	if spawner == null:
		return
	var pickup := spawner.get_node("Pickup") as Interactable
	assert_str(pickup.prompt).contains("Adaga enferrujada")
	pickup.interact(player)
	assert_str(String(player.equipped_weapon.id)).is_equal("core:rusty_dagger")
	assert_float(player.equipped_weapon.damage).is_equal(12.0)
	assert_bool(pickup.enabled).is_false()
	assert_int(pickup.collision_layer).is_equal(0)
	assert_bool(pickup.visible).is_false()
	assert_int(player.get_node("Head/Camera/WeaponHand").get_child_count()).is_equal(1)
	pickup.interact(player)
	assert_int(player.get_node("Head/Camera/WeaponHand").get_child_count()).is_equal(1)
	assert_bool(player.has_candle).is_false()
	player.equip_candle()
	assert_bool(player.has_candle).is_true()
	assert_str(String(player.equipped_weapon.id)).is_equal("core:rusty_dagger")


func test_aiming_at_dagger_and_interacting_equips_it() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	player.global_position = Vector3(0, 0.05, 4.0)
	player.rotation.y = PI
	(player.get_node("Head") as Node3D).rotation.x = -0.65
	await runner.simulate_frames(3)
	assert_object(player.current_target()).is_not_null()
	player.try_interact()
	assert_object(player.equipped_weapon).is_not_null()


func test_registered_mod_weapon_appears_in_playable_scene() -> void:
	var weapon := WeaponDef.new()
	weapon.id = &"playtest:blade"
	weapon.display_name = "Lâmina de teste"
	ContentRegistry.register(weapon, "playtest")
	var runner := scene_runner(MAIN)
	var display := runner.scene().get_node_or_null("ModWeapons")
	assert_object(display).is_not_null()
	if display != null:
		var found := false
		for spawner in display.get_children():
			if spawner.content_id == &"playtest:blade":
				found = true
				var pickup := spawner.get_node("Pickup") as Interactable
				pickup.interact(runner.scene().get_node("Player"))
				assert_str(String(runner.scene().get_node("Player").equipped_weapon.id)).is_equal(
					"playtest:blade"
				)
		assert_bool(found).is_true()
	# Restaura os autoloads para os próximos testes, sem montar packs externos.
	ContentRegistry.clear()
	var empty_mods := TestFs.make_temp_dir("empty_mods")
	ModLoader.load_all(ContentRegistry, "res://core", empty_mods)
	TestFs.remove_dir(empty_mods)


func test_incompatible_model_does_not_leave_an_orphan() -> void:
	var runner := scene_runner(MAIN)
	var model := Node.new()
	var scene := PackedScene.new()
	assert_int(scene.pack(model)).is_equal(OK)
	model.free()
	var weapon := WeaponDef.new()
	weapon.scene = scene
	var pickup := WeaponPickup.new()
	pickup.weapon = weapon
	var before := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	runner.scene().add_child(pickup)
	var after := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	# O pickup já saiu dos órfãos ao entrar na árvore; o modelo incompatível deve ser liberado.
	assert_int(after).is_equal(before - 1)


func test_empty_weapon_scene_can_be_collected_without_errors() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	var weapon := WeaponDef.new()
	weapon.id = &"test:empty_model"
	weapon.scene = PackedScene.new()
	var pickup := WeaponPickup.new()
	pickup.weapon = weapon
	runner.scene().add_child(pickup)
	pickup.interact(player)
	assert_str(String(player.equipped_weapon.id)).is_equal("test:empty_model")
	assert_int(player.get_node("Head/Camera/WeaponHand").get_child_count()).is_equal(0)
	assert_bool(pickup.enabled).is_false()
