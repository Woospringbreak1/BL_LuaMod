-- LuaBehaviour Script Stub Template
-- Remove any functions you don't use for a performance boost

function Awake()
    print("Awake called")
end

function Start()
    print("Start called")
end

function LateStart()
    print("LateStart called")
end

function OnEnable()
    print("OnEnable called")
end

function OnDisable()
    print("OnDisable called")
end

function OnDestroy()
    print("OnDestroy called")
end

function Update()
    -- Called every frame
end

function LateUpdate()
    -- Called every frame after Update
end

function FixedUpdate()
    -- Called every fixed timestep (physics)
end

function SlowUpdate()
    -- Called at custom interval defined in LuaBehaviour.SlowUpdateTime
end

function OnTriggerEnter(other)
    print("OnTriggerEnter:", other)
end

function OnTriggerExit(other)
    print("OnTriggerExit:", other)
end

function OnTriggerStay(other)
    print("OnTriggerStay:", other)
end

function OnCollisionEnter(collision)
    print("OnCollisionEnter:", collision)
end

function OnCollisionExit(collision)
    print("OnCollisionExit:", collision)
end

function OnCollisionStay(collision)
    print("OnCollisionStay:", collision)
end

function OnJointBreak(breakForce)
    print("OnJointBreak:", breakForce)
end

function OnBecameVisible()
    print("OnBecameVisible called")
end

function OnBecameInvisible()
    print("OnBecameInvisible called")
end

function OnParticleSystemStopped()
    print("OnParticleSystemStopped called")
end

function OnParticleCollision(other)
    print("OnParticleCollision with", other)
end

function OnParticleTrigger()
    print("OnParticleTrigger called")
end

function OnParticleUpdateJobScheduled()
    print("OnParticleUpdateJobScheduled called")
end

function OnTransformChildrenChanged()
    print("OnTransformChildrenChanged called")
end

function OnTransformParentChanged()
    print("OnTransformParentChanged called")
end
