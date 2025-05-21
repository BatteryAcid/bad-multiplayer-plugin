extends Panel

@export var noray_input_panel: Node
@export var host_input: LineEdit

var _selected_network_type = BADMultiplayerManager.AvailableNetworks.ENET

func _ready() -> void:
	_set_btn_selection_icon($HostSubMenu/Local)
	$HostSubMenu/Local.grab_focus()
	
	# TODO: this loop is why it may be better to use an object where we have additional fields like name/enabled
	# TODO: of course this is terrible practice here, but I'm tired and need to get something working before signing off for the day...
	for network_type in BADMultiplayerManager.AvailableNetworks.keys():
		
		var enabled = BADMultiplayerManager.network_types[BADMultiplayerManager.AvailableNetworks[network_type]]

		if BADMultiplayerManager.AvailableNetworks[network_type] == BADMultiplayerManager.AvailableNetworks.ENET:
			$HostSubMenu/Local.visible = enabled
		elif BADMultiplayerManager.AvailableNetworks[network_type] == BADMultiplayerManager.AvailableNetworks.OFFLINE:
			$HostSubMenu/Offline.visible = enabled
		elif BADMultiplayerManager.AvailableNetworks[network_type] == BADMultiplayerManager.AvailableNetworks.NORAY:
			$HostSubMenu/Noray.visible = enabled
		elif BADMultiplayerManager.AvailableNetworks[network_type] == BADMultiplayerManager.AvailableNetworks.STEAM:
			$HostSubMenu/Steam.visible = enabled


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_on_cancel_pressed()

func _on_local_pressed() -> void:
	noray_input_panel.visible = false
	_selected_network_type = BADMultiplayerManager.AvailableNetworks.ENET
	_set_btn_selection_icon($HostSubMenu/Local)

func _on_noray_pressed() -> void:
	noray_input_panel.visible = true
	_selected_network_type = BADMultiplayerManager.AvailableNetworks.NORAY
	_set_btn_selection_icon($HostSubMenu/Noray)

func _on_steam_pressed() -> void:
	print("Steam not supported yet!")
	noray_input_panel.visible = false
	_selected_network_type = BADMultiplayerManager.AvailableNetworks.STEAM
	_set_btn_selection_icon($HostSubMenu/Steam)

func _on_offline_pressed() -> void:
	noray_input_panel.visible = false
	_selected_network_type = BADMultiplayerManager.AvailableNetworks.OFFLINE
	_set_btn_selection_icon($HostSubMenu/Offline)

func _on_cancel_pressed() -> void:
	_selected_network_type = null
	get_parent().host_options_cancelled.emit()

func _on_start_pressed() -> void:
	var configs = null
	
	match _selected_network_type:
		BADMultiplayerManager.AvailableNetworks.ENET:
			# The default "localhost" for host is fine, but it's not used downstream	
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)
		BADMultiplayerManager.AvailableNetworks.NORAY:
			if host_input && host_input.text:
				# TODO: Port is supplied by the network impl script, could allow this to override that...
				configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)
		BADMultiplayerManager.AvailableNetworks.STEAM:
			# The default "localhost" for host is fine, but it's not used downstream
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)
		BADMultiplayerManager.AvailableNetworks.OFFLINE:
			# The default "localhost" for host is fine, it's not used downstream	
			configs = BADNetworkConnectionConfigs.new(_selected_network_type, host_input.text)

	if configs != null:
		get_parent().host_options_submitted.emit(configs)

func _set_btn_selection_icon(button: Button):
	var btn_pos = button.global_position
	btn_pos.x = btn_pos.x + 300
	$SelectedIcon.position = btn_pos
