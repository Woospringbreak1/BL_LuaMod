-- LuaBehaviour
function Start()
    ProjectileSpeed = 60.0
    ProjectileLifetime = 20.0
    RemoveProjectileTime = Time.time + ProjectileLifetime
    ProjectileRigidBody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
end

function OnDestroy()

end

function OnCollisionEnter(collision)
    if(OwnerGun ~= nil and collision.collider.gameObject.transform.root ~= OwnerGun.transform.root) then
        local contact = collision.GetContact(0)
        TriggerSurfaceImpact(contact.point,contact.normal)

        if(collision.rigidbody ~= nil) then
            DamageEnemy(contact.point,contact.normal,contact.thisCollider,collision.rigidbody.transform.root.gameObject,collision.rigidbody)
        end

        API_GameObject.BL_Destroy(BL_Host.transform.root.gameObject);
    end
end


function TriggerSurfaceImpact(pos, normal)
    local impactRotation = Quaternion.LookRotation(Vector3.forward, normal)
    local ImpactEffect = API_GameObject.BL_SpawnByBarcode("BonelabMeridian.Luamodexamplecontent.Spawnable.PlasmaImpact", pos, impactRotation)
end

function DamageEnemy(pos, normal,collider,gameObject,rigidbody)
    if(IsValid(rigidbody) and IsValid(gameObject)) then
            API_SLZ_Combat.BL_AttackEnemy(gameObject,7.0,collider,pos,BL_Host.transform.forward)

            local forceToApply  = (1000 * Time.deltaTime)
            rigidbody.AddForceAtPosition(normal*forceToApply, pos)
    end

end

function SetOwnerGun(owner)
    OwnerGun = owner
    OwnerGunRB = API_GameObject.BL_GetComponent(OwnerGun.gameObject,"Rigidbody")
end

LastPosition = nil
function FixedUpdate()
    if (BL_This.Ready and IsValid(ProjectileRigidBody) and OwnerGun ~= nil) then  

        if(Time.time > RemoveProjectileTime) then
            API_GameObject.BL_Destroy(BL_Host.transform.root.gameObject);
            return
        end

        LastPosition = BL_Host.transform.position
        local newPosition = BL_Host.transform.position + ((BL_Host.transform.forward * ProjectileSpeed * Time.fixedDeltaTime))
        local BackOffsetPosition = LastPosition - ((BL_Host.transform.forward * ProjectileSpeed * 2.0 * Time.fixedDeltaTime ))
        ProjectileRigidBody.MovePosition(newPosition, BL_Host.transform.rotation)
        
        raycast = API_Physics.BL_RayCast(newPosition,BackOffsetPosition)
        if(raycast ~= nil and  raycast.collider ~= nil and raycast.collider.transform.root ~= OwnerGun.transform.root) then 
            ProjectileRigidBody.position = raycast.point
            TriggerSurfaceImpact(raycast.point,raycast.normal)

            if(raycast.rigidbody ~= nil) then
                DamageEnemy(raycast.point,raycast.normal,raycast.collider,raycast.rigidbody.transform.root.gameObject,raycast.rigidbody)
            end

            API_GameObject.BL_Destroy(BL_Host.transform.root.gameObject);
        end
    end
end