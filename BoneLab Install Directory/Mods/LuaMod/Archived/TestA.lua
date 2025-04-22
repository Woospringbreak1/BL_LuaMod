--LuaBehaviour


function Start()
    print("Hello, World from TestA!")
end


OneOnly = false
function Update()

    if(API_Input.BL_LeftController_IsGrabbed()) then
        if(OneOnly == false) then
            OneOnly = true 
            print("A is down")
                LeftController = API_Input.BL_LeftHand()
                if(LeftController ~= nil) then  
                    print("spawning projectile")
                    ProjectileInstance = API_GameObject.BL_SpawnByBarcode("33.33.Spawnable.PlasmaProjectile", LeftController.transform.position, LeftController.transform.rotation) 
                    print("projectile spawned")
                else
                    print("controller is nil")
                end
        end
    else
        OneOnly = false
    end
    
    
end