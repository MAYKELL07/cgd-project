# CGD Project - Platformer Game

## Overview
A 2D platformer game built with Godot 4.3 featuring moving platforms, enemies, hazards, and collectibles.

## Game Objective
Reach the red X button in the top right corner to complete the level and advance to the next one.

## Controls
- **A / Left Arrow**: Move Left
- **D / Right Arrow**: Move Right  
- **W / Up Arrow / Space**: Jump
- **E / Left Mouse Button**: Attack (kills enemies in range for score)

## Features Implemented

### Player System
- Health system with visual feedback when damaged
- Movement and jumping mechanics
- Attack system to defeat enemies (E key or Left Mouse)
- Death and respawn system
- Brief invulnerability after taking damage

### Enemies
- Walking enemies that patrol back and forth
- Flying enemies that move horizontally
- Enemies damage the player on contact
- Award score points when killed
- Configurable movement speed and distance

### Moving Platforms
- Platforms that move horizontally or vertically
- Configurable movement distance and speed
- Player can ride on platforms

### Hazards
1. **Spinning Fire Walls**: Rotating obstacles that damage player
2. **Fire Shooters**: Stationary turrets that shoot fireballs
3. **Fireballs**: Projectiles that damage player and disappear on impact
4. **Spikes**: Static ground hazards that damage on contact

### Collectibles
- **Health Pickups**: Green orbs that restore player health

### UI System
- **Health Bar**: Shows current/max health with visual bar
- **Score Display**: Tracks points earned from defeating enemies
- **Timer**: Displays elapsed time in MM:SS format

### Level System
- Exit button (red X) in top right corner
- Loads next level when player reaches it
- Proper collision layers for all game objects

## Project Structure
```
cgd-project/
├── scenes/
│   ├── player/
│   │   └── player.tscn
│   ├── enemies/
│   │   └── enemy.tscn
│   ├── platforms/
│   │   └── moving_platform.tscn
│   ├── hazards/
│   │   ├── fire_wall.tscn
│   │   ├── fire_shooter.tscn
│   │   ├── fireball.tscn
│   │   └── spikes.tscn
│   ├── collectibles/
│   │   └── health_pickup.tscn
│   ├── ui/
│   │   └── game_ui.tscn
│   └── levels/
│       ├── exit_button.tscn
│       └── level_1.tscn
└── scripts/
	├── player.gd
	├── enemy.gd
	├── moving_platform.gd
	├── fire_wall.gd
	├── fire_shooter.gd
	├── fireball.gd
	├── spikes.gd
	├── health_pickup.gd
	├── game_ui.gd
	├── exit_button.gd
	└── game_manager.gd
```

## How to Customize

### Creating New Enemies
1. Instantiate the enemy scene
2. Set `enemy_type` to "walking" or "flying"
3. Adjust `move_speed`, `move_distance`, `damage`, and `score_value`
4. Add to "enemies" group for score tracking

### Creating New Platforms
1. Instantiate the moving platform scene
2. Set `direction` (e.g., Vector2.RIGHT, Vector2.UP)
3. Adjust `move_distance` and `move_speed`

### Creating Fire Shooters
1. Instantiate the fire shooter scene
2. Set `shoot_direction` (e.g., Vector2.RIGHT, Vector2.DOWN)
3. Adjust `shoot_interval` and `fireball_speed`

### Creating New Levels
1. Duplicate level_1.tscn
2. Arrange platforms, enemies, and hazards
3. Place exit button in desired location
4. Update exit button's `next_level_path` property

## Collision Layers
- Layer 1: Player
- Layer 2: Enemies
- Layer 3: Hazards (Fire, Spikes)
- Layer 4: Collectibles
- Layer 5: Goal (Exit Button)

## Tips for Players
- Use the attack (E or Left Click) to defeat enemies and gain score
- Watch for enemy patrol patterns
- Time your jumps on moving platforms
- Collect health pickups before difficult sections
- Fireballs can be dodged by timing your movement
- The timer tracks your speed - try to beat your best time!

## Future Enhancements
- Add visual attack animation
- Implement checkpoint system
- Add sound effects and music
- Create multiple levels
- Add particle effects for better visual feedback
- Implement lives system
- Add power-ups (speed boost, invincibility, etc.)
- Add enemy varieties with different behaviors
