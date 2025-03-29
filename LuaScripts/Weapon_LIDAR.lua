--LuaBehaviour



function Start()
    print("Hello, World from LIDAR!")
    LIDARDots = API_GameObject.BL_GetComponent2(BL_Host,"ParticleSystem")
   -- FirePoint = API_GameObject.BL_FindInChildren(BL_Host,"FirePoint")
    
   -- print(tostring(API_Particles))
   -- print(tostring(API_Particles.BL_GetParticles))
   -- print(tostring(LIDARDots))
    ParticleArray = API_Particles.BL_GetParticles(LIDARDots,200,2);
    --numParticlesAlive = ParticleArray.Length

    --print("Number of particles: " .. tostring(ParticleArray) .. " " .. tostring(ParticleArray.Length))
  --  print(tostring(ParticleArray[1].position))
end

RandomAngle = 30
LaserMaxRange = 100
function RaycastLIDAR()
    -- Create a random rotation within a cone of RandomAngle degrees around FirePoint.forward
    local angle = API_Random.BL_RandomRange(0, RandomAngle)
    local axis = API_Random.BL_onUnitSphere()
    local coneRotation = Quaternion.AngleAxis(angle, axis)
    local randomDirection = coneRotation * FirePoint.forward

    -- Perform the raycast using the randomly adjusted direction
    LIDAROut = API_Physics.BL_RayCast(FirePoint.position, randomDirection, LaserMaxRange)

    -- Check hit result and mark the point if hit is valid
    if LIDAROut ~= nil and (LIDAROut.rigidbody == nil or LIDAROut.rigidbody.kinematic) then
       -- MarkDot(LIDAROut.point, LIDAROut.normal)
    end
end

ParticlePos = 0
LastParticlePos = 0
BatchSize = 100
function MarkDot(pos, normal)
    if(ParticlePos > numParticlesAlive -2) then
        SendParticles(LastParticlePos,ParticlePos)
        ParticlePos = 0
        LastParticlePos = 0
    elseif(ParticlePos-LastParticlePos >= BatchSize) then
        SendParticles(LastParticlePos,ParticlePos)
        LastParticlePos = ParticlePos
    end

    ParticleArray[ParticlePos].position = pos
    Pcolor = ParticleArray[ParticlePos].startColor
    Pcolor.r = normal.x
    Pcolor.g = normal.y
    Pcolor.b = normal.z
    ParticleArray[ParticlePos].startColor = Pcolor
    ParticlePos = ParticlePos + 1
end

function SendParticles(startpos,endpos)
    local size = endpos-startpos
 LIDARDots.SetParticles(ParticleArray, size, startpos)
end

function PlayLIDARSound()
    if(not LIDARFireSound.isPlaying) then
        LIDARFireSound.Play()
    end
end

function Update()
    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        print("script not ready")
        return
    end

    if(LIDARDots == nil) then
        print("LIDAR components invalid")
        return
    end

    if(Firing) then
      --  BL_This.SetMagazineRounds(320)
       -- RaycastLIDAR()
    end

        BL_This.AttachedGun.hammerState = HammerStates.COCKED
        if (BL_This.AttachedGun.isTriggerPulled) then
            Firing = true
        else
            Firing = false

            if(ParticlePos ~= LastParticlePos) then
           --     SendParticles(LastParticlePos,ParticlePos)
           --     LastParticlePos = ParticlePos
            end

        end

end