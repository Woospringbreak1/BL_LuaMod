-- ConveyorBelt.lua

conveyorDirection = API_Vector.BL_Vector3(-1.0,0.0,0)
conveyorSpeed = 0.2
acceleration = 2.0 -- max m/s² allowed to apply along conveyor axis
TrackedBodies = {}

function Start()
    worldDirection = BL_Host.transform:TransformDirection(conveyorDirection).normalized
end

function FixedUpdate()
    for i = #TrackedBodies, 1, -1 do
        local body = TrackedBodies[i]
        if not IsValid(body) then
            table.remove(TrackedBodies, i)
        else
            local currentVelocity = body.velocity
            local targetVelocity = worldDirection * conveyorSpeed
            local delta = targetVelocity - currentVelocity

            -- Only affect motion along conveyor direction
            local deltaAlongBelt = Vector3.Project(delta, worldDirection)
            local deltaMag = deltaAlongBelt.magnitude

            if deltaMag > 0.01 then
                -- Clamp force magnitude to acceleration * mass
                local maxForce = body.mass * acceleration
                local clampedForce = worldDirection * math.min(deltaMag / Time.fixedDeltaTime * body.mass, maxForce)

                body:AddForce(clampedForce, ForceMode.Force)
            end
        end
    end
end

function OnTriggerEnter(other)
    local rb = API_GameObject.BL_GetComponent(other.transform.root.gameObject, "Rigidbody")
    if rb ~= nil then
        table.insert(TrackedBodies, rb)
    end
end

function OnTriggerExit(other)
    local rb = API_GameObject.BL_GetComponent(other.transform.root.gameObject, "Rigidbody")
    if rb ~= nil then
        for i = #TrackedBodies, 1, -1 do
            if TrackedBodies[i] == rb then
                table.remove(TrackedBodies, i)
                break
            end
        end
    end
end
