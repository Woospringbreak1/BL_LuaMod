function Start()

    -- delete all VOID meshes created by CrateSpawners

    CrateSpawners = API_GameObject.BL_GetComponentsInChildren(BL_Host,"CrateSpawner")


    for _,spawner in ipairs(CrateSpawners) do
        local meshRenderer = API_GameObject.BL_GetComponent(spawner.gameObject,"MeshRenderer")
        API_GameObject.BL_Destroy(meshRenderer) 
    end


    --delete this script to save resources

    API_GameObject.BL_Destroy(BL_This) 

end