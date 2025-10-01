# Cannonball Simulation (Haxe/OpenFL)

Interactive 2D cannonball playground built with **Haxe + OpenFL**.  
This simulation incorporates **all major physical properties and influences on a projectile**:  
- **Gravity**
- **Air resistance (drag)** calculated from the ball’s **diameter** and cross-sectional area
- **Wind force** (with adjustable speed and direction)
- **Mass and initial velocity**
- Launch angle and initial height

The project lets you compare trajectories **with vs without drag**, visualizing the difference between idealized and realistic projectile motion.
The project also includes a **target practice mode**, where the user enters the X and Y coordinates of a target and then inputs all projectile parameters in an attempt to hit it.

## ✨ Features
- User inputs: angle, speed, height, mass, diameter, wind speed
- **Air resistance** (drag) modeled via cross-sectional area from diameter
- **Two modes**: with drag (red) and optional comparison without drag (blue)
- **Shooting target** where user trying to hit set target
- Real-time animation + basic range/height updates
- Smooth HTML5 build via OpenFL

## 🛠️ Developer Setup (Haxe/OpenFL)
If you want to build from source:

1. Install Haxe and OpenFL:
   ```bash
   haxelib install openfl
   haxelib install lime
   haxelib run openfl setup
   ```
2. HTML5 debug build:
   ```bash
   openfl test html5 -debug
   # or
   haxe debug.hxml
   ```
3. Release build:
   ```bash
   openfl build html5 -final
   # or
   haxe release.hxml
   ```

## 📁 Project Structure
```
.
├── index.html                 # HTML entry (loads CannonSimulation.js)
├── CannonSimulation.js        # Prebuilt JS bundle (HTML5)
├── project.xml                # OpenFL project config
├── Main.hx                    # App logic (inputs, physics, rendering)
├── ApplicationMain.hx         # Generated glue (OpenFL/Lime bootstrap)
├── ManifestResources.hx       # Generated resources manifest
├── debug.hxml / release.hxml  # Haxe build configs
├── images & assets            
└── Export/                    
```

## ⚙️ Physics Notes
The simulation models projectile motion using:
- Gravitational acceleration
- Aerodynamic drag proportional to cross-sectional area from diameter
- Wind speed and direction affecting drag
- Initial mass, velocity, and angle
- Optional comparison mode: with drag (red) vs without drag (blue)

## 🧭 Roadmap / Ideas
- Target practice mode (hit a moving target)
- UI polishing and nicer HUD

