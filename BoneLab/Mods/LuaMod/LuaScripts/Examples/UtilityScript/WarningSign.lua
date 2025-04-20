---this script is used to display the "Lua code mode required" sign to the players without the mod, by deleting on spawn - if Lua mod is installed.

function Start()
print("The LUA modding framework must be installed - deleting warning sign")
API_GameObject.BL_Destroy(BL_Host.transform.root.gameObject)
end
