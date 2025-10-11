
function Start()
    WarehouseManager = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("WarehouseManager"),"LuaBehaviour")

    if(WarehouseManager == nil) then
        print("failed to find warehouse manager")
    end
end

function OnTriggerEnter(other)
    local qrCode = API_GameObject.BL_FindInChildren(other.transform.root.gameObject, "QRCode")
    if(IsValid(qrCode)) then
        local qrCodeBehaviour = API_GameObject.BL_GetComponent(qrCode, "LuaBehaviour")   
        if(IsValid(qrCodeBehaviour)) then
            print("valid QR code - loading " .. qrCodeBehaviour.GetScriptVariable("ItemDescription"))
            WarehouseManager.CallFunction("ItemLoaded", qrCodeBehaviour)
            other.transform.root.gameObject.setActive(false)
        end
    end
   
end

