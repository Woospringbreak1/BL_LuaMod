-- ConveyorBelt.lua

conveyorDirection = API_Vector.BL_Vector3(-1.0, 0.0, 0)
conveyorSpeed = 2.0

-- Tuning parameters
velocitySnap = 10.0      -- how fast to snap to belt speed (higher = faster)
sideDamping = 20.0         -- how fast to reduce sideways (off-belt) motion
frictionDamping = 1.0     -- how strongly to counter movement relative to belt surface

function Start()
    worldDirection = BL_Host.transform:TransformDirection(conveyorDirection).normalized
end

function OnCollisionStay(collision)
    local other = collision.gameObject
    if not string.match(other.name, "dest_Crate_Lite_1m") then
        return
    end

    local rb = API_GameObject.BL_GetComponent(other.transform.root.gameObject, "Rigidbody")
    if rb == nil then return end

    local velocity = rb.velocity

    -- --- 1. ALIGN TO BELT VELOCITY ---
    local currentAlong = Vector3.Project(velocity, worldDirection)
    local desiredAlong = worldDirection * conveyorSpeed
    local deltaAlong = desiredAlong - currentAlong
    local newVelocity = velocity + deltaAlong * velocitySnap * Time.fixedDeltaTime

    -- --- 2. DAMP SIDEWAYS MOTION (ignore Y axis) ---
    local flatVelocity = API_Vector.BL_Vector3(velocity.x, 0, velocity.z)
    local flatBelt = API_Vector.BL_Vector3(worldDirection.x, 0, worldDirection.z)
    local orthogonal = flatVelocity - Vector3.Project(flatVelocity, flatBelt)
    local correction = -orthogonal * sideDamping * Time.fixedDeltaTime
    newVelocity = newVelocity + API_Vector.BL_Vector3(correction.x, 0, correction.z)

    -- --- 3. FRICTION DAMPING (reduce jitter/shake if crates scrape the belt) ---
    local relativeMotion = velocity - desiredAlong
    local frictionForce = -relativeMotion * frictionDamping * Time.fixedDeltaTime
    newVelocity = newVelocity + frictionForce
    --print("new velocity for " .. other.name .. " " .. tostring(newVelocity))
    -- Apply
    rb.velocity = newVelocity
end
