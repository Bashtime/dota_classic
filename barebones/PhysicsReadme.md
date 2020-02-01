# **BMD's Lua Unit Physics Library**
--------------------------------
See [CollidersReadme.md](https://github.com/bmddota/barebones/blob/source2/CollidersReadme.md) for documentation and examples on using Colliders.

#### **How to install:**
- Drop physics.lua in with your vscripts
- Add require( 'physics' ) somewhere in your lua instantiation path

#### **How to use:**
- To turn any dota unit into a Physics unit, run
  Physics:Unit(unitEntity)
- This adds a bunch of new functions to the unit which allow for it to simulate physics
- All velocity/acceleration vectors are in hammer units per second or hammer units per second squared

**Physics Library Functions**
=============================
#### **Physics:Unit (unit)**
  Makes a unit into a "physics" unit which can be manipulated using the PhysicsUnit functions

#### **Physics:GenerateAngleGrid()**
  This function is used to generate and apply an angle grid (calculated GNV normal map) for the current map so as to yield better bounces for PHYSICS_NAV_BOUNCE and PHYSICS_NAV_SLIDE collisions.

#### **Physics:AngleGrid (anggrid, angoffsets)**
  This function is an advanced means of setting a normal map for GridNav collisions so as to yield better bounces for PHYSICS_NAV_BOUNCE and PHYSICS_NAV_SLIDE collisions.

#### **IsPhysicsUnit (unit)**
  This global function returns true if the unit in question has been converted to a "physics" unit.



**PhysicsUnit Functions:**
=============================
#### **AdaptiveNavGridLookahead (boolean)**
  Whether this unit should use an adaptive navgrid lookahead system to more reliably detect GNV collisions at high speed

#### **AddPhysicsAcceleration (accelerationVector)**
  Adds a new acceleration vector to the current internal acceleration vector.

#### **AddPhysicsVelocity (velocityVector)**
  Adds a new velocity vector to the current internal velocity vector.  This is effectively a force push on the unit.

#### **AddStaticVelocity (name, velocityVector)**
  Adds a new velocity vector to the current internal static velocity vector of the given name.

#### **ClearStaticVelocity ()**
  Clears all current static velocity vectors, effectively setting them to (0,0,0)

#### **CutTrees (boolean)**
  Sets whether this unit should automatically cut trees when it collides with them or not.  Default is false.

#### **FollowNavMesh (boolean)**
  Whether this unit should respect the NavMesh when moving and exhibit NavCollisionType behavior when interacting with a NavGrid block

#### **GetAutoUnstuck ()**
  Whether this unit will be returned to its last known good position in the event that it is determined to be stuck in unpathable terrain.  Default is true.

#### **GetBounceMultiplier ()**
  Returns the float representing the multiplier to apply to a unit's velocity's magnitude in the event that they bounce via PHYSICS_NAV_BOUNCE.  Default is 1.0 (aka no velocity magnitude change)

#### **GetBoundOverride ()**
  Returns the current boundary radius override for this unit, which will be used when blocking the unit out from navigation grid collisions so that it doesn't get stuck.  Default is the larget value of "unit:GetPaddedCollisionRadius() + 1" or "math.max(unit:GetBoundingMaxs().x, unit:GetBoundingMaxs().y)"

#### **GetLastGoodPosition ()**
  Returns the vector position which was the last known position that the unit was in that was unblocked/pathable.

#### **GetNavCollisionType ()**
  Returns the current GridNav Collision Type (PHYSICS_NAV_NOTHING, PHYSICS_NAV_HALT, PHYSICS_NAV_SLIDE, PHYSICS_NAV_BOUNCE, or PHYSICS_NAV_GROUND)

#### **GetNavGridLookahead ()**
  Returns the current number of Navigation Grid lookahead points.  See SetNavGridLookahead for more details. Default is 1

#### **GetNavGroundAngle ()**
  Returns the current terrain angle that will cause PHYSICS_NAV_GROUND based navigation to slide.

#### **GetPhysicsAcceleration ()**
  Returns the current acceleration vector.  Default is (0,0,0)

#### **GetPhysicsBoundingRadius ()**
  Returns the current bounding radius used for navgrid collision.  Default is the PaddedCollisionRadius of a unit.

#### **GetPhysicsFlatFriction ()**
  Returns the current flat friction amount.  Default is 0

#### **GetPhysicsFriction ()**
  Returns the current friction multiplier and flat friction amount.  Default is .05, 0

#### **GetPhysicsVelocity ()**
  Returns the current velocity vector.  Default is (0,0,0)

#### **GetPhysicsVelocityMax ()**
  Returns the maximum velocity.  Default is 0, representing an unlimited velocity

#### **GetRebounceFrames ()**
  Returns the number of rebounce frames to wait between PHYSICS_NAV_BOUNCE collisions.  Default is 2.

#### **GetStaticVelocity (name)**
  Returns the current static velocity force for the given name.

#### **GetStuckTimeout ()**
  Returns the number of frames necessary to determine if a unit is stuck in unpathable terrain and to activate AutoUnstuck

#### **GetSlideMultiplier ()**
  Returns the slide multipler value. Default is 0.1

#### **GetTotalVelocity ()**
  Returns the unit's total velocity (i.e. Physics velocity + slide velocity + standard right-click movement).  This is nonfunctional while a unit is hibernating, and will return Vector(0,0,0) on the first frame that a Physics unit is created, but a correct value thereafter.

#### **GetVelocityClamp ()**
  Returns the current velocity clamp in hammer units per second.  Default is 20 hammer units per second

#### **Hibernate (boolean)**
  Whether this unit should Hibernate when there is no sliding/acceleration/velocity.  When hibernating the unit performs no physics calculation until new force/acceleration/sliding is applied.  Additionally, OnPhysicsFrame will not be called if this unit is hibernating.Default is that a unit will hibernate.

#### **IsAdaptiveNavGridLookahead ()**
  Returns whether this unit will use an adaptive navgrid lookahead system to more reliably detect GNV collisions at high speed

#### **IsCutTrees ()**
  Returns whether this unit is currently set to automatically cut trees it collides with.  Default is false

#### **IsFollowNavMesh ()**
  Returns whether this unit will respect the navigation mesh when moving the unit around.

#### **IsHibernate ()**
  Returns whether this unit should hibernate when there are no physics calculations to be performed

#### **IsInSimulation ()**
  Returns whether this unit is currently in an active physics simulation or not.

#### **IsLockToGround ()**
  Returns whether this unit will lock the unit to the ground while performing position calculations. 

#### **IsPreventDI ()**
  Returns whether this unit will be prevented from influencing the direction of the physics calculations.

#### **IsSlide ()**
  Returns whether this unit is currently sliding

#### **OnBounce (function(unit, normal))**
  Set the callback function to be executed when a PHYSICS_NAV_BOUNCE is occuring, but after the velocity rebound calculation has been performed and applied.  The function passed in has two parameters given to it, the unit in question and the normal vector of the surface that the unit is bouncing off of.

#### **OnPreBounce (function(unit, normal))**
  Set the callback function to be executed when a PHYSICS_NAV_BOUNCE is occuring, but before the velocity rebound calculation has been performed and applied.  The function passed in has two parameters given to it, the unit in question and the normal vector of the surface that the unit is bouncing off of.

#### **OnHibernate (function(unit))**
  Set the callback function (with one parameter, the unit in question) to be executed in the event that this unit begins hibernating.

#### **OnSlide (function(unit, normal))**
  Set the callback function to be executed when a PHYSICS_NAV_SLIDE is occuring, but after the velocity direction nullification has been performed and applied.  The function passed in has two parameters given to it, the unit in question and the normal vector of the surface that the unit is sliding off of.

#### **OnPreSlide (function(unit, normal))**
  Set the callback function to be executed when a PHYSICS_NAV_SLIDE is occuring, but before the velocity direction nullification has been performed and applied.  The function passed in has two parameters given to it, the unit in question and the normal vector of the surface that the unit is sliding off of.

#### **OnPhysicsFrame (function(unit))**
  Set the callback function (with one parameter, the unit in question) to be executed every frame for this unit so long as it is not hibernating. You can use this function to do additional calculations/collision detection/velocity modification.

#### **PreventDI (boolean)**
  Whether to prevent this unit from influencing the direction of the simulation.  The default is false

#### **SetAutoUnstuck (boolean)**
  Whether to return this unit to its last known good position in the event that the library determines them to be "stuck" for enough frames in an unpathable area.  Default is true.

#### **SetBounceMultiplier (bounceMultipler)**
  Sets the magnitude to adjust the velocity of a unit in the event of a PHYSICS_NAV_BOUNCE bounce.  .5 would halve the total velocity of the unit, while 2.0 would double it on bounce. Default is 1.0. 

#### **SetBoundOverride (bound)**
  Sets the current boundary radius override for this unit, which will be used when blocking the unit out from navigation grid collisions so that it doesn't get stuck.

#### **SetGroundBehavior (groundBehavior)**

 - PHYSICS_GROUND_NOTHING: The unit will be able to pass through terrain and will not change its z-coordinate in any way concerning terrain
 - PHYSICS_GROUND_ABOVE: The unit will follow the ground so long as the ground is "above" the unit.  If the unit is above the ground, it will not lock to the ground.
 - PHYSICS_GROUND_LOCK: The unit will remain attached to the ground regardless of z-coordinate position/velocity/acceleration

#### **SetNavCollisionType (navCollisionType)**
  Sets the behavior that the physics system will use when this unit collides with the GridNav mesh.  Possibilities are PHYSICS_NAV_NOTHING, PHYSICS_NAV_HALT, PHYSICS_NAV_SLIDE, or PHYSICS_NAV_BOUNCE.  Default is PHYSICS_NAV_SLIDE
  
 - PHYSICS_NAV_NOTHING: The unit will continue normal velocity/position calculations, potentially bumping up against the nav mesh multiple times
 - PHYSICS_NAV_HALT: The unit will halt its velocity immediately in all directions
 - PHYSICS_NAV_SLIDE: The unit will halt its velocity in only the x or y direction depending on the collision direction with the GridNav
 - PHYSICS_NAV_BOUNCE: The unit will bounce off of the GridNav mesh face it contacts with, continuing on in a different direction with the same velocity magnitude
 - PHYSICS_NAV_GROUND: The unit will travel along the ground based on the slope of the terrain, ignoring the GNV entirely.  If the slope of the terrain exceeds the slope limit set with SetNavGroundAngle, then the unit will slide down the terrain.

#### **SetNavGridLookahead (lookaheadPoints)**
  Sets the number of navigation grid lookahead points to use when determining a navigation grid collision for PHYSICS_NAV_HALT/NOTHING/SLIDE/BOUCE.  The physics system will lookahead to the 1..lookaheadPoints-1 / lookaheadPoints the distance to the next position in order to determine if the unit will pass into an unwalkable location during the next frame. Increasing this number allows for higher speed collisions with the navigation grid and helps to prevent units from slipping through the grid by using speed.  Default is 1.  Note: This adds a lot of calculations even at 3 or 4, so be careful with this value for performance reasons.

#### **SetNavGroundAngle (angle)**
  Sets the current terrain angle that will cause PHYSICS_NAV_GROUND based navigation to slide.

#### **SetPhysicsAcceleration (accelerationVector)**
  Sets the internal acceleration vector to the given vector, eliminating any existing acceleration

#### **SetPhysicsBoundingRadius (boundingRadius)**
  Sets the internal bounding radius used for navgrid collision.

#### **SetPhysicsFlatFriction (flatFriction)**
  Sets the flat friction amount.  The default is 0.

#### **SetPhysicsFriction (frictionMultiplier[, flatFriction])**
  Sets the friction multiplier and/or flat friction amount.  The default is .05 and 0.  Not providing flatFriction will keep the current value.

#### **SetPhysicsVelocity (velocityVector)**
  Sets the internal velocity vector to the given vector, eliminating any existing velocity

#### **SetPhysicsVelocityMax (maxVelocity)**
  Sets the maximum velocity that the unit will clamp to during the simulation.  Default is 0, which in unlimited

#### **SetRebounceFrames (rebounceFrames)**
  Sets the number of frames to wait between PHYSICS_NAV_BOUNCE gridnav collisions before allowing for another collision to take place.  Default is 5 (aka 1/6 of a second)

#### **SetSlideMultiplier (slideMultiplier)**
  Sets the slide multiplier.  The default is 0.1

#### **SetStaticVelocity (name, velocityVector)**
  Sets the internal static velocity vector to the given vector for this named static velocity vector, eliminating any existing static velocity for this named vector

#### **SetStuckTimeout (stuckFrames)**
  Sets the number of frames to wait before determining that the player is "stuck" in an unpathable area before returning them via AutoUnstuck to their last known good position.  The default is 3 frames (aka .1 seconds).

#### **SetVelocityClamp (clamp)**
  Sets the velocity magnitude clamp for stopping physics calculations/hibernating.  The default is 20 hammer units per second

#### **SkipSlide (frames)**
  Sets the number of frames for which to skip the slide calculation for this unit.  This is useful when you need to reposition a unit (respawn/blink/etc) but don'target want the Physics library slide calculation to add in a massive sliding velocity due to that teleport.  In the same frame as the respawn/blink you should issue a  unit:SkipSlide(2).  Slide calculations will resume when all SkipSlide frames are counted out.

#### **Slide (boolean)**
  Whether this unit should be sliding or not.  Sliding units accelerate based on their direction of travel in addition to their normal movespeed motion.

#### **StartPhysicsSimulation ()**
  Restart the physics simulation if it has been stopped by StopPhysicsSimulation

#### **StopPhysicsSimulation ()**
  Stop the physics simulation from executing any more for this unit
  
  

**Examples:** 
=============================
Give a unit sliding motion
-----------------------------
    Physics:Unit(hero)
    hero:Slide(true)

Push a unit to the left
-----------------------------
    Physics:Unit(hero)
    hero:AddPhysicsVelocity(Vector(-1000, 0, 0))

Start an accelerating "tractor beam" pulling one unit towards another without their influence
-----------------------------
    Physics:Unit(target)
    target:SetPhysicsVelocityMax(500)
    target:PreventDI()
    
    local direction = source:GetAbsOrigin() - target:GetAbsOrigin()
    direction = direction:Normalized()
    target:SetPhysicsAcceleration(direction * 50)
    
    target:OnPhysicsFrame(function(unit)
      -- Retarget acceleration vector
      local distance = source:GetAbsOrigin() - target:GetAbsOrigin()
      local direction = distance:Normalized()
      target:SetPhysicsAcceleration(direction * 50)
      
      -- Stop if reached the unit
      if distance:Length() < 100 then
        target:SetPhysicsAcceleration(Vector(0,0,0))
        target:SetPhysicsVelocity(Vector(0,0,0))
        target:OnPhysicsFrame(nil)
      end
    end)