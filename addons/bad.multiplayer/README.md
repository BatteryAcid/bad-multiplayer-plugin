# BAD Multiplayer

The BAD Multiplayer plugin minimizes the networking setup required for your game,
allowing you to focus on the game play logic.

# Features

- Match-style multplayer gameplay (highly configurable)
- Dedicated server builds with ENet
	- Connection using IP/DNS and Port through ENet
- Client-Host P2P connections through Noray host given address and GameID (OpenID)
	- Supports both NAT Punchthrough and Relay for Client-Host P2P
- Signals/Events to handle common match functionalites:
	- Spawning, player actions, spawn location, scene switching, exit game, menus, etc
- Handles common networking boilierplate

# Setup

- TODO
- Assumes game has the following scenes [MainMenu -> Loading -> Game]

# Usage

- TODO

# Roadmap

- Add support for Steam through steam-multiplayer-peer

# Customization notes

- If you wish to replace one of the provided autoloaders, like `bad_multiplayer_manager`, be sure
to override the public facing functions, like `exit_gameplay_load_main_menu`, as other autoloaders
may call to them.
