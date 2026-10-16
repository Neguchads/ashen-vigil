extends GdUnitTestSuite
## Fluxo do despertar: pegar a vela, ler a carta, ficar de pé no chão, árvores com colisão.

const MAIN := "res://src/main/main.tscn"


func test_candle_and_letter_flow() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	var candle := root.get_node("Room/Candle") as Interactable
	var letter := root.get_node("Room/Letter") as Interactable
	var hand := player.get_node("Head/Camera/HandLight") as LightSource

	assert_bool(player.has_candle).is_false()
	candle.interact(player)
	assert_bool(player.has_candle).is_true()
	assert_bool(hand.lit).is_true()
	assert_bool(candle.enabled).is_false()

	candle.interact(player)  # pegar de novo não faz nada
	assert_bool(player.has_candle).is_true()

	letter.interact(player)
	assert_bool(player.reading).is_true()
	var text := (player.get_node("Hud/Reader/Text") as Label).text
	assert_str(text).contains("Estamos te vendo")
	player.close_text()
	assert_bool(player.reading).is_false()


func test_interact_with_nothing_in_sight_is_safe() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	player.rotation.y = PI  # olha para a parede oposta à mesa
	await runner.simulate_frames(2)
	player.try_interact()
	assert_bool(player.has_candle).is_false()
	assert_bool(player.reading).is_false()


func test_aiming_at_candle_and_pressing_e_picks_it_up() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	# Em pé ao lado da mesa, virado para -X e olhando para baixo, na vela.
	player.global_position = Vector3(-1.2, 0.05, -1.6)
	player.rotation.y = PI / 2.0
	# O corpo encosta na mesa e para em x ≈ -1.05; do olho (y 1.67) até a vela
	# (x -1.95, y 0.83) o ângulo é atan(0.84 / 0.9) ≈ 0.75 rad.
	(player.get_node("Head") as Node3D).rotation.x = -0.75
	await runner.simulate_frames(3)
	assert_object(player.current_target()).is_not_null()
	player.try_interact()
	assert_bool(player.has_candle).is_true()


func test_player_stands_on_floor() -> void:
	var runner := scene_runner(MAIN)
	await runner.simulate_frames(90)
	var player := runner.scene().get_node("Player") as Player
	assert_bool(player.is_on_floor()).is_true()
	assert_float(player.global_position.y).is_between(-0.05, 0.3)


func test_forest_has_trunk_collision_per_tree() -> void:
	var runner := scene_runner(MAIN)
	var forest := runner.scene().get_node("Forest")
	var trunks := forest.get_node("Trunks")
	assert_int(trunks.get_child_count()).is_equal(forest.tree_count)
