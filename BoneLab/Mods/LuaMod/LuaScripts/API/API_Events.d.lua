---@class API_Events
API_Events = {}

---@param Uevent UnityEvent
---@param Owner LuaBehaviour
---@param func string
---@return bool
function API_Events.BL_SubscribeEvent(Uevent, Owner, func) end

---@param eventName string
---@param Owner LuaBehaviour
---@param func string
---@return bool
function API_Events.BL_SubscribeEvent(eventName, Owner, func) end

---@param eventName string
---@param DynValue params
---@return bool
function API_Events.BL_InvokeEvent(eventName, DynValue) end

function API_Events.SetUpEvents() end
