extends BADMatchActionHandler

# Setup initial or reload saved player properties
func ready_player(network_id: int, player: Variant):
	if is_multiplayer_authority():
		player.name = str(network_id)
		player.global_transform = get_spawn_point(player.name)
		
		if player.name != "1":
			player.selected_ship = player.ship_types[1]

		# Player is always owned by the server
		player.set_multiplayer_authority(1)

func get_spawn_point(player_name) -> Transform2D:
	if player_name == "1": # For now, just check if you're the host, spawn on left side.
		return Transform2D(0, Vector2(randi_range(75, 275), randi_range(50, 570)))
	else:
		return Transform2D(0, Vector2(randi_range(1400, 1600), randi_range(50, 570)))
