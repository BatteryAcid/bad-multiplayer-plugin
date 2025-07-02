extends Panel

@export var noray_input_panel: Node
@export var host_input: LineEdit

var _selected_network_type = BADMP.AvailableNetworks.ENET

func _ready() -> void:
	_set_btn_selection_icon($HostSubMenu/Local)
	$HostSubMenu/Local.grab_focus()

	for network_type in BADMP.AvailableNetworks.keys():
		var enabled = BADMP.available_networks[BADMP.AvailableNetworks[network_type]].enabled

		match BADMP.AvailableNetworks[network_type]:
			BADMP.AvailableNetworks.ENET:
				$HostSubMenu/Local.visible = enabled
			BADMP.AvailableNetworks.OFFLINE:
				$HostSubMenu/Offline.visible = enabled
			BADMP.AvailableNetworks.NORAY:
				$HostSubMenu/Noray.visible = enabled
			BADMP.AvailableNetworks.STEAM:
				$HostSubMenu/Steam.visible = enabled

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_on_cancel_pressed()

func _on_local_pressed() -> void:
	noray_input_panel.visible = false
	_selected_network_type = BADMP.AvailableNetworks.ENET
	_set_btn_selection_icon($HostSubMenu/Local)

func _on_noray_pressed() -> void:
	noray_input_panel.visible = true
	_selected_network_type = BADMP.AvailableNetworks.NORAY
	_set_btn_selection_icon($HostSubMenu/Noray)

func _on_steam_pressed() -> void:
	print("Steam not supported yet!")
	noray_input_panel.visible = false
	_selected_network_type = BADMP.AvailableNetworks.STEAM
	_set_btn_selection_icon($HostSubMenu/Steam)

func _on_offline_pressed() -> void:
	noray_input_panel.visible = false
	_selected_network_type = BADMP.AvailableNetworks.OFFLINE
	_set_btn_selection_icon($HostSubMenu/Offline)

func _on_cancel_pressed() -> void:
	_selected_network_type = null
	get_parent().host_options_cancelled.emit()

func _on_start_pressed() -> void:
	var configs = null

	match _selected_network_type:
		BADMP.AvailableNetworks.ENET:
			# The default "localhost" for host is fine, but it's not used downstream	
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)
		BADMP.AvailableNetworks.NORAY:
			if host_input && host_input.text:
				configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)
		BADMP.AvailableNetworks.STEAM:
			# The default "localhost" for host is fine, but it's not used downstream
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)
		BADMP.AvailableNetworks.OFFLINE:
			# The default "localhost" for host is fine, it's not used downstream	
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)

	if configs != null:
		get_parent().host_options_submitted.emit(configs)

func _set_btn_selection_icon(button: Button):
	var btn_pos = button.global_position
	btn_pos.x = btn_pos.x + 300
	$SelectedIcon.position = btn_pos
