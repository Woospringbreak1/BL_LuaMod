-- LuaBehaviour
function Start()
    print("Hello, World! from TestProjectile.lua")
    ProjectileSpeed = 0.8
    ProjectileRigidBody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
    --print("time " .. tostring(Time))
    --print("fixed delta time " .. tostring(Time.fixedDeltaTime)) fix later
end

function OnDestroy()
    --print("Out of time - goodbye!")
end

function OnCollisionEnter(collision)
    --print("Collision detected! - number of cotacts: " .. collision.contactCount)
    local contact = collision.GetContact(0)
    TriggerSurfaceImpact(contact.point,contact.normal)

    if(collision.rigidbody ~= nil) then
        print("attacking from OnCollisionEnter")
        DamageEnemy(contact.point,contact.normal,contact.thisCollider,collision.rigidbody.transform.root.gameObject,collision.rigidbody)
    end

    API_GameObject.Destroy(BL_Host.transform.root.gameObject);
end

--function TriggerSurfaceImpact(collision)
 --   local contactpoint = collision.GetContact(0)
   -- local impactPoint = contactpoint.point
    --local impactRotation = Quaternion.LookRotation(Vector3.forward, contactpoint.normal);
    --local ImpactEffect = API_GameObject.BL_SpawnByBarcode("SLZ.BONELAB.Content.Spawnable.BlasterVoid", impactPoint, impactRotation) 
    --DamageEnemy(collision,collision.gameObject.transform.root.gameObject,collision.collider,impactPoint,contactpoint.normal)
--end

function TriggerSurfaceImpact(pos, normal)
    local impactRotation = Quaternion.LookRotation(Vector3.forward, normal)
    local ImpactEffect = API_GameObject.BL_SpawnByBarcode("SLZ.BONELAB.Content.Spawnable.BlasterVoid", pos, impactRotation)
end

function DamageEnemy(pos, normal,collider,gameObject,rigidbody)
    if(gameObject ~= nil) then
        if(rigidbody ~= nil) then    
            print("calling BL_AttackEnemy")
            API_SLZ_Combat.BL_AttackEnemy(gameObject,20,collider,pos,normal)
            API_SLZ_Combat.ApplyForce(rigidbody,pos,normal,10000)
        else
            print("rigidbody is nil")
        end
    else
        print("GameObject is nil")
    end

end


LastPosition = nil
function FixedUpdate()
    if (BL_Host ~= nil) then  
        if (ProjectileRigidBody ~= nil) then    
            LastPosition = BL_Host.transform.position
            local newPosition = BL_Host.transform.position + ((BL_Host.transform.forward * ProjectileSpeed))
            local BackOffsetPosition = LastPosition - ((BL_Host.transform.forward * ProjectileSpeed * 2.0 * API_Player.BL_GetFixedDeltaTime() ))
            ProjectileRigidBody.MovePosition(newPosition, BL_Host.transform.rotation)
            
            raycast = API_GameObject.BL_RayCast(newPosition,BackOffsetPosition)
            if(raycast ~= nil) then 
                TriggerSurfaceImpact(raycast.point,raycast.normal)

                if(raycast.rigidbody ~= nil) then
                    print("attacking from FixedUpdate raycast")
                    DamageEnemy(raycast.point,raycast.normal,raycast.collider,raycast.rigidbody.transform.root.gameObject,raycast.rigidbody)
                end

                API_GameObject.Destroy(BL_Host.transform.root.gameObject);
            end

        else    
            print("ProjectileRigidBody is nil")
        end
    else
        print("BL_Host is nil")
    end 
end