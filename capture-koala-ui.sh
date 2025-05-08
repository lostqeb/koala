#!/bin/bash

# Launch koala-ui in a new terminal window (adjust terminal if needed)
gnome-terminal -- bash -c "koala-ui; exec bash" &

# Wait for the UI to open
sleep 3

# Take a screenshot of the active window using scrot (requires 'scrot')
scrot -u ~/koala-ui-screenshot.png

echo "✅ Screenshot saved to: ~/koala-ui-screenshot.png"
