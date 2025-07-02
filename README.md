# BAD Multiplayer

Minimizes networking setup required for your Godot multiplayer game.


# Features

- Currently designed for match based multiplayer games, but is highly configurable.
- Networking lifecycle signals and menu actions are exposed through a simple set of functions.
- Facilitates common match actions like readying a player, spawn point retrieval, respawning, and player reset.
- Build your menus around the networks you want to support.
- Connect the buttons to the provided host and join game functions.

## Supported networks
- ENet (local and dedicated server)
- Noray Client-host P2P (coming soon!)

# Setup

- Add this plugin to your Godot multiplayer project
- TODO: Add link to asset library

# Usage Instructions

- https://github.com/BatteryAcid/bad-multiplayer-plugin/wiki/Usage-Instructions

# Roadmap

- Add support for Steam through steam-multiplayer-peer

# Customization notes

- If you wish to replace one of the provided autoloaders, like `bad_multiplayer_manager`, be sure
to override the public facing functions, like `exit_gameplay_load_main_menu`, as other autoloaders
may call to them.
