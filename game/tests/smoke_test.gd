extends GdUnitTestSuite
## Garante que o projeto abre e que a versão do jogo está configurada.


func test_game_version_is_set() -> void:
	assert_str(ProjectSettings.get_setting("application/config/version")).is_equal("0.1.0")
