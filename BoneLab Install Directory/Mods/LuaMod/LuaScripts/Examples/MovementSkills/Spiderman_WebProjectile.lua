-- LuaBehaviour
function Start()
    print("Hello, World! from Spiderman_WebProjectile.lua")
    ProjectileSpeed = 40
    ProjectileRigidBody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
    Webline = API_GameObject.BL_GetComponent(BL_Host,"LineRenderer")
    OwnerGun = nil -- gun that spawned this projectile
    OwnerGunRB = nil

end

function OnDestroy()
    
end

function OnCollisionEnter(collision)
    if(OwnerGun ~= nil and not Frozen and collision.collider.gameObject.transform.root ~= OwnerGun.transform.root) then
        FreezeProjectile()
        if(collision.rigidbody ~= nil and collision.rigidbody.isKinematic == false) then
            EmbedProjectile(collision.rigidbody)
        end
    end
end



function EmbedProjectile(targetRB)
    ---weld the projectile to the target
    Frozen = true --stop trying to move it
    ProjectileRigidBody.isKinematic = false
    
    local EmbedJoint = API_GameObject.BL_AddComponent(BL_Host,"ConfigurableJoint")
    EmbedJoint.connectedBody = targetRB
    EmbedJoint.xMotion = ConfigurableJointMotion.Locked
    EmbedJoint.yMotion = ConfigurableJointMotion.Locked    
    EmbedJoint.zMotion = ConfigurableJointMotion.Locked  

    EmbedJoint.angularXMotion = ConfigurableJointMotion.Locked
    EmbedJoint.angularXMotion = ConfigurableJointMotion.Locked    
    EmbedJoint.angularZMotion = ConfigurableJointMotion.Locked 
    

    EmbedJoint.enableCollision = false 
    --EmbedJoint.autoConfigureConnectedAnchor = false
    --EmbedJoint.connectedAnchor = API_Vector.BL_Vector3(0,0,0)
    EmbedJoint.anchor = API_Vector.BL_Vector3(0,0,0)

    marrowJoint =API_GameObject.BL_AddComponent(BL_Host,"MarrowJoint")
    marrowEntity = API_GameObject.BL_GetComponent(BL_Host,"MarrowEntity")
    marrowJoint._bodyA =  API_GameObject.BL_GetComponent(BL_Host,"MarrowBody")
    marrowJoint._bodyB =  API_GameObject.BL_GetComponent(targetRB.gameObject,"MarrowBody")
    marrowJoint._entity = marrowEntity
    marrowJoint.CopyJointInfo(EmbedJoint)
    marrowJoint.Validate(EmbedJoint,marrowEntity)


end

function FreezeProjectile()
    --set up a length-limited joint between the projectile and the player
    local RopeLength = (BL_Host.transform.position - OwnerGun.transform.position).magnitude

    
    local RopeJoint = API_GameObject.BL_AddComponent(BL_Host,"ConfigurableJoint")

    RopeJoint.connectedBody = OwnerGunRB
    RopeJoint.xMotion = ConfigurableJointMotion.Limited
    RopeJoint.yMotion = ConfigurableJointMotion.Limited    
    RopeJoint.zMotion = ConfigurableJointMotion.Limited  


    local Ropelimit =RopeJoint.linearLimit
    Ropelimit.limit = RopeLength
    RopeJoint.linearLimit = Ropelimit

    RopeJoint.enableCollision = false 
    RopeJoint.autoConfigureConnectedAnchor = false
    RopeJoint.connectedAnchor = API_Vector.BL_Vector3(0,0,0)
    RopeJoint.anchor = API_Vector.BL_Vector3(0,0,0)

    ProjectileRigidBody.isKinematic = true


    Frozen = true
end


function SetOwnerGun(owner)
    print(BL_Host.name .. " received owner gun: " .. owner.name)
    OwnerGun = owner
    OwnerGunRB = API_GameObject.BL_GetComponent(OwnerGun.gameObject,"Rigidbody")
end

function DrawLineRenderer()
    if(Webline ~= nil) then
        Webline.SetPosition(0,BL_Host.transform.position)
        Webline.SetPosition(1,OwnerGun.transform.position)
    else
        print("Webline LineRenderer is nil")
    end
end

function Update()
    if(OwnerGun ~= nil) then
        DrawLineRenderer()
    end
end


LastPosition = nil
Frozen = false
function FixedUpdate()
    if (BL_Host ~= nil and OwnerGun ~= nil) then  

        if (ProjectileRigidBody ~= nil and not Frozen) then    
            LastPosition = BL_Host.transform.position
            local newPosition = BL_Host.transform.position + ((BL_Host.transform.forward * ProjectileSpeed * Time.fixedDeltaTime))
            local BackOffsetPosition = LastPosition - ((BL_Host.transform.forward * ProjectileSpeed * 2.0 * Time.fixedDeltaTime ))
            ProjectileRigidBody.MovePosition(newPosition, BL_Host.transform.rotation)
            
            raycast = API_Physics.BL_RayCast(newPosition,BackOffsetPosition)
            if(raycast ~= nil and raycast.collider.transform.root ~= OwnerGun.transform.root) then 
                ProjectileRigidBody.position = raycast.point
                FreezeProjectile()

                if(raycast.collider.gameObject.transform.root ~= OwnerGun.transform.root) then
                    if(raycast.rigidbody ~= nil and raycast.rigidbody.isKinematic == false) then
                        EmbedProjectile(raycast.rigidbody)
                    end
                end

            end
           

        else    
            --print("ProjectileRigidBody is nil")
        end
    else
        --print("BL_Host is nil")
    end 
end