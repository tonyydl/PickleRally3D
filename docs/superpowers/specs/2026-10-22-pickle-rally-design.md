# Pickle Rally 3D — playable singles prototype

Build a Windows-first, bright low-poly Godot 4.7.2 / GDScript project in its own directory. The existing MyFirstGame is a separate tower defense game and is untouched. User requested direct implementation after a short plan, so no design approval stop.

One metre per unit: court 6.096 × 13.4112 m, kitchen 2.1336 m each side; 0.8636 m net centre / 0.9144 m edges. Player on +Z, AI on -Z; third-person elevated camera behind the player, framing the whole court. Exaggerate ball visuals and forgiving paddle reach for readability. Primitive meshes, procedural animations and synthesized audio require no external assets.

Use a deterministic ballistic simulation rather than a free rigid body, for reliable target assistance, swept net collision and repeatable tests. Shots solve an arc to a coarse directional target; no input aims safely centre, A/D aim left/right, W/S adjust depth. A brief click buffer permits early input. WASD also moves. Serve from behind the baseline, diagonally according to server score parity; AI serves automatically after an explicit next-rally click.

Separate Rules (pure rally/scoring state), Flight (ballistic state and collisions), Actor (movement/visuals), Court (environment), HUD (Chinese labels and controls), Match (input/AI/orchestration). Serve bounce and return bounce are mandatory before volleys. Kitchen includes its line and foot radius; volley momentum into kitchen loses the rally until the next bounce. Other lines are in; kitchen line on serve is out. Only server scores; receiver wins cause side-out. First to 11 with 2 point margin, terminal win state, restart and pause.

Stages remain launchable: court/movement/flight, then AI, then rules/UI. No doubles, multiplayer, customization or mobile. Baseline deterministic tests cover physics, regulations, long AI rallies and scene controls. Validate actual rendered Windows view and human input in addition to headless tests.

References: https://www.usapickleball.org/docs/rules/USAP-Rules-Summary.pdf and https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html . Simplifications: automatic legal underhand service animation; no spin, body-hit/over-net paddle or referee/appeal system.
