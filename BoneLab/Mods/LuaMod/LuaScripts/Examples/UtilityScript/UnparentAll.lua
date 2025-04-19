-- LuaBehaviour
--used to package physics machiens like the turret that can't handle parenting
function Start()
   children = BL_Host.transform.DetachChildren()
   print("all children detached")
end
