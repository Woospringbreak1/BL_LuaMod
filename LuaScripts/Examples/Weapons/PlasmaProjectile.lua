-- LuaBehaviour
function Start()
    ProjectileSpeed = 0.8
    ProjectileLifetime = 20.0
    RemoveProjectileTime = time.Time + ProjectileLifetime
    ProjectileRigidBody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
end

function OnDestroy()

end

function OnCollisionEnter(collision)
    local contact = collision.GetContact(0)
    TriggerSurfaceImpact(contact.point,contact.normal)

    if(collision.rigidbody ~= nil) then
        DamageEnemy(contact.point,contact.normal,contact.thisCollider,collision.rigidbody.transform.root.gameObject,collision.rigidbody)
    end

    API_GameObject.BL_DestroyGameObject(BL_Host.transform.root.gameObject);
end


function TriggerSurfaceImpact(pos, normal)
    local impactRotation = Quaternion.LookRotation(Vector3.forward, normal)
    local ImpactEffect = API_GameObject.BL_SpawnByBarcode("BonelabMeridian.Luamodexamplecontent.Spawnable.PlasmaImpact", pos, impactRotation)
end

function DamageEnemy(pos, normal,collider,gameObject,rigidbody)
    if(IsValid(rigidbody) and IsValid(gameObject)) then
            API_SLZ_Combat.BL_AttackEnemy(gameObject,7.0,collider,pos,BL_Host.transform.forward)
            API_SLZ_Combat.ApplyForce(rigidbody,pos,normal,1000)

    end

end


LastPosition = nil
function FixedUpdate()
    if (BL_This.Ready and IsValid(ProjectileRigidBody)) then  

        if(time.Time > RemoveProjectileTime) then
            API_GameObject.BL_DestroyGameObject(BL_Host.transform.root.gameObject);
            return
        end

        LastPosition = BL_Host.transform.position
        local newPosition = BL_Host.transform.position + ((BL_Host.transform.forward * ProjectileSpeed))
        local BackOffsetPosition = LastPosition - ((BL_Host.transform.forward * ProjectileSpeed * 2.0 * Time.fixedDeltaTime ))
        ProjectileRigidBody.MovePosition(newPosition, BL_Host.transform.rotation)
        
        raycast = API_Physics.BL_RayCast(newPosition,BackOffsetPosition)
        if(raycast ~= nil) then 
            TriggerSurfaceImpact(raycast.point,raycast.normal)

            if(raycast.rigidbody ~= nil) then
                print("attacking from FixedUpdate raycast")
                DamageEnemy(raycast.point,raycast.normal,raycast.collider,raycast.rigidbody.transform.root.gameObject,raycast.rigidbody)
            end

            API_GameObject.BL_DestroyGameObject(BL_Host.transform.root.gameObject);
        end
    end
end