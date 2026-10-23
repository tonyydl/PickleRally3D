Pickle Rally 3D - Web prototype

Serve this entire folder over HTTP or HTTPS. Do not double-click index.html.
For a local preview with Python installed:
    python -m http.server 8060 --bind 127.0.0.1
Then open http://127.0.0.1:8060/ in a desktop browser.

For hosting, upload the complete folder, preserving all filenames.
The ZIP has index.html at its root, suitable for an HTML game upload to itch.io.
This single-threaded build does not require cross-origin isolation headers.
WebAssembly and WebGL 2.0 support are required. Keyboard and mouse required.
Click the game to focus it and allow audio playback before playing.

WASD: move and aim; left mouse: Drive / serve / next rally
Right mouse: Dink / Drop; Space: Lob; Shift + left mouse: Smash
Esc: pause / resume; R: restart

Made with Godot Engine. See GODOT_LICENSE.txt and GODOT_COPYRIGHT.txt.
Noto Sans TC by the Noto Project Authors. See NOTO_FONT_LICENSE.txt.
