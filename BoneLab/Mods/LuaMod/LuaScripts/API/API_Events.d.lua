---@class API_Events
API_Events = {}

---@param eventName string
---@param Owner LuaBehaviour
---@param func string
---@return boolean
function API_Events.BL_SubscribeEvent(eventName, Owner, func) end

---@param eventName string
---@vararg DynValue
---@return boolean
function API_Events.BL_InvokeEvent(eventName, ...) end
