extends Node

# Autoload: BADAsync
# Util to wait for a callable to complete with timeout threshold
# Source: https://github.com/foxssake/netfox/blob/main/examples/shared/scripts/async.gd

func condition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK
