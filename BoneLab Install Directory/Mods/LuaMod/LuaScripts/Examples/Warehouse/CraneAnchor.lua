
function Start()
    LineRenderer = API_GameObject.BL_GetComponent(BL_Host,"LineRenderer")
    CraneCrabBody = API_GameObject.BL_FindInWorld("CrabBase")
end

function  Update()
    LineRenderer.SetPosition(0,BL_Host.transform.position)
    LineRenderer.SetPosition(1,CraneCrabBody.transform.position)
end

