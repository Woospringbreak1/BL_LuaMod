--LuaBehaviour

function Start()
    print("Hello, World!")

end

function  DestroyedByBoss()
print("BUNKER GUN " .. BL_Host.name .. " DESTROYED BY BOSS LASER")
API_GameObject.BL_SpawnByBarcode("c1534c5a-26fd-4606-aa5e-1098426c6173",BL_Host.transform.root.position, Quaternion.identity)
API_GameObject.BL_Destroy(BL_Host.transform.root.gameObject)
end