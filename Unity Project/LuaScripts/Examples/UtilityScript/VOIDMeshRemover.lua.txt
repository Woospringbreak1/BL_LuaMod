function Start()

    -- delete all VOID meshes created by CrateSpawners

    CrateSpawners = API_GameObject.BL_FindComponentsInWorld("CrateSpawner",true)

    if(CrateSpawners ~= nil and IsValid(CrateSpawners)) then
        for _,spawner in ipairs(CrateSpawners) do
            local meshRenderer = API_GameObject.BL_GetComponent(spawner.gameObject,"MeshRenderer")
            if( meshRenderer ~= nil) then
                API_GameObject.BL_Destroy(meshRenderer) 
            end
        end
    end

    --delete this script to save resources

    API_GameObject.BL_Destroy(BL_This) 

end