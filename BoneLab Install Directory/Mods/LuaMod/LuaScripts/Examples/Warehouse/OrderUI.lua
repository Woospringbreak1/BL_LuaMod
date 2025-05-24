function Start()
LockScreen = API_GameObject.BL_FindInChildren(BL_Host,"LockScreen")
OrderScreen = API_GameObject.BL_FindInChildren(BL_Host,"OrderScreen")

LaserCursorToggler = API_GameObject.BL_FindInChildren(BL_Host,"LaserCursorToggler")
LaserCursorToggler.setActive(false)

LASERCURSOR_UI = API_GameObject.BL_FindInChildren(BL_Host,"LASERCURSOR_UI")
LASERCURSOR_UI.setActive(false)
Locked = true
end


function UnlockTerminal()
    print("Unlocking terminal")
    LockScreen.setActive(false)
    OrderScreen.setActive(true)
    LaserCursorToggler.setActive(true)
    LASERCURSOR_UI.setActive(true)
    Locked = false
end


function Update()
    
if(Locked) then
    LaserCursorToggler.setActive(false)
    LASERCURSOR_UI.setActive(false)
end

end