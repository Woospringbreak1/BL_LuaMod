--LuaBehaviour


function Start()
    print("Hello, World from lua test gun!")
    --print("locating LuaGun")

    print("locating Rigidbody")
    TestRigidbody = API_GameObject.BL_GetComponent2(BL_Host,"Rigidbody")
     print("CastTestRigidbody mass: " .. TestRigidbody.mass)
    
    print("locating LuaGun")
    Luascript = API_GameObject.BL_GetComponent2(BL_Host,"LuaGun")
    print("active script: " .. Luascript.ScriptName)

    API_Events.BL_SubscribeEvent("Player_OnReceiveDamage",BL_This,"PlayerEventTest")
    API_Events.BL_SubscribeEvent("OnNPCKillEnd",BL_This,"PlayerEventTest3")
    API_Events.BL_SubscribeEvent("TestLuaEvent",BL_This,"PlayerEventTest2")
    API_Events.BL_SubscribeEvent("Object_OnReceiveDamage",BL_This,"PlayerEventTest4")
    API_Events.BL_InvokeEvent("TestLuaEvent")
end

function PlayerEventTest(Attack)
   -- print("PlayerHealth_OnReceivedDamage event received! " .. tostring(Attack))
   -- print("attack damage: " .. tostring(Attack.damage))
end

function PlayerEventTest2(Attack)
    --print("custom event from LUA")
end

function PlayerEventTest3(NPC)
   -- print("NPC Killed :( " .. NPC.name)
end

function PlayerEventTest4(Object, Attack)
   -- print(Object.name .. " received damage: ")
   -- print(" received damage: " .. tostring(Attack.damage))
end


function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

end

function OnFire()
    -- Note: OnFire is called when the weapon is fired

    print("spawning projectile from Lua test gun!")
    Fpoint = Luascript.GetFirepointPosition()
    Pos = Fpoint.position + Fpoint.forward*0.2--BL_Host.transform.position + (BL_Host.transform.forward*0.5)
    Rot = BL_Host.transform.rotation;
    ProjectileInstance = API_GameObject.BL_SpawnByBarcode("33.33.Spawnable.PlasmaProjectile", Pos, Rot) 

end