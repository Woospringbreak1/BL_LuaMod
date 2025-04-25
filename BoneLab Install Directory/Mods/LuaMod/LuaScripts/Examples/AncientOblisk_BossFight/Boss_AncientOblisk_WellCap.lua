--LuaBehaviour

function Start()
    Boss = API_GameObject.BL_FindInWorld("AncientObliskV2")
    BossLuaBehaviour = API_GameObject.BL_GetComponent(Boss,"LuaBehaviour")
end

Started = false
function  OnBecameVisible()
    --print("WELL CAP VISIBLE")
    if(not Started ) then
        BossLuaBehaviour.CallFunction("WellcapVisible")
        Started = true
    end
end