!#/bin/bash
	killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

	# Launch the bar
		polybar -q main -c "/home/denis/.config/polybar/custom/config.ini" &
        
