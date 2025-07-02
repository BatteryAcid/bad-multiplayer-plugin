extends Node

@export_group("Input Panels")
@export var server_input_panel: Node
@export var noray_input_panel: Node

@export_group("Server")
@export var server_host_input: LineEdit
@export var server_port_input: LineEdit

@export_group("Noray")
@export var noray_host_input: LineEdit
@export var noray_game_id_input: LineEdit

var _selected_network_type = BADMP.AvailableNetworks.ENET

func _ready() -> void:
	_set_btn_selection_icon($HostSubMenu/Server)
	$HostSubMenu/Server.grab_focus()
	
	for network_type in BADMP.AvailableNetworks.keys():
		var enabled = BADMP.available_networks[BADMP.AvailableNetworks[network_type]].enabled

		match BADMP.AvailableNetworks[network_type]:
			BADMP.AvailableNetworks.ENET:
				$HostSubMenu/Server.visible = enabled
			BADMP.AvailableNetworks.NORAY:
				$HostSubMenu/Noray.visible = enabled
			BADMP.AvailableNetworks.STEAM:
				$HostSubMenu/Steam.visible = enabled
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_on_cancel_pressed()

func _on_local_pressed() -> void:
	_set_btn_selection_icon($HostSubMenu/Server)
	noray_input_panel.visible = false
	server_input_panel.visible = true
	_selected_network_type = BADMP.AvailableNetworks.ENET

func _on_noray_pressed() -> void:
	_set_btn_selection_icon($HostSubMenu/Noray)
	noray_input_panel.visible = true
	server_input_panel.visible = false
	_selected_network_type = BADMP.AvailableNetworks.NORAY

func _on_steam_pressed() -> void:
	_set_btn_selection_icon($HostSubMenu/Steam)
	noray_input_panel.visible = false
	server_input_panel.visible = false
	# TODO: add steam panel once supported
	_selected_network_type = BADMP.AvailableNetworks.STEAM

func _on_cancel_pressed() -> void:
	_selected_network_type = null
	get_parent().join_options_cancelled.emit()

func _on_start_pressed() -> void:
	var configs = null
	
	match _selected_network_type:
		BADMP.AvailableNetworks.NORAY:
			if noray_host_input && noray_host_input.text && noray_game_id_input && noray_game_id_input.text:
				# port isn't needed here
				configs = BADNetworkConnectionConfigs.new(_selected_network_type, noray_host_input.text, -1, noray_game_id_input.text)
		BADMP.AvailableNetworks.ENET:
			if server_host_input && server_host_input.text && server_port_input && server_port_input.text:
				configs = BADNetworkConnectionConfigs.new(_selected_network_type, server_host_input.text, server_port_input.text.to_int())
		BADMP.AvailableNetworks.STEAM:
			# TODO: add steam config once supported
			print("Steam not supported yet")
		BADMP.AvailableNetworks.OFFLINE:
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, "")

	if configs != null:
		get_parent().join_options_submitted.emit(configs)

func _set_btn_selection_icon(button: Button):
	var btn_pos = button.global_position
	btn_pos.x = btn_pos.x + 300
	$SelectedIcon.position = btn_pos
