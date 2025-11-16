# Physics Callback Fixes

## Issue
Getting errors about removing CollisionObject nodes during physics callbacks, which is not allowed in Godot and causes undesired behavior.

## Root Cause
When nodes are freed using `queue_free()` directly inside physics callbacks (like `_on_body_entered`), it causes issues because the physics engine is still processing collisions.

## Solution
Use `call_deferred("queue_free")` instead of `queue_free()` to defer the node removal until after the physics processing is complete.

## Files Fixed

### 1. `scripts/player.gd`
**Change**: Removed `get_tree().reload_current_scene()` from `die()` function
- The game manager now handles showing the game over screen
- No scene reload during physics callback
- Game over screen allows player to restart manually

### 2. `scripts/fireball.gd`
**Changes**:
- `_on_body_entered()`: Changed `queue_free()` to `call_deferred("queue_free")`
- `_on_visible_on_screen_notifier_2d_screen_exited()`: Changed `queue_free()` to `call_deferred("queue_free")`

### 3. `scripts/health_pickup.gd`
**Change**: `_on_body_entered()`: Changed `queue_free()` to `call_deferred("queue_free")`

### 4. `scripts/enemy.gd`
**Change**: `die()`: Changed `queue_free()` to `call_deferred("queue_free")`

## Technical Explanation

### What is call_deferred()?
`call_deferred()` schedules a method to be called on the next frame, after the current physics/processing frame is complete. This ensures that we don't modify the scene tree while physics calculations are happening.

### Why does this matter?
When Godot's physics engine processes collisions:
1. It iterates through all collision objects
2. Calls signals like `body_entered`, `area_entered`, etc.
3. If we remove nodes during this iteration, it can cause:
   - Crashes
   - Undefined behavior
   - Memory access violations
   - Inconsistent collision detection

### The Fix Pattern
```gdscript
# ❌ BAD - Direct removal during physics callback
func _on_body_entered(body):
    queue_free()

# ✅ GOOD - Deferred removal
func _on_body_entered(body):
    call_deferred("queue_free")
```

## Testing
All errors should now be resolved. The game will function identically, but without the physics callback warnings.

## Related Files Not Changed
These files already handle physics correctly:
- `spikes.gd` - Uses cooldown system, doesn't free itself
- `fire_wall.gd` - Uses cooldown system, doesn't free itself
- `fire_shooter.gd` - Only spawns fireballs, doesn't handle collisions directly
- `moving_platform.gd` - No collision-based freeing
