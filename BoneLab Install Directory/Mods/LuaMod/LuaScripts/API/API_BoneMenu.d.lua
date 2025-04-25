---@class API_BoneMenu
API_BoneMenu = {}

---@param page Page
---@param name string
---@param color Color
---@param owner LuaBehaviour
---@param function string
---@return LuaFunctionElement
function API_BoneMenu.BL_CreateFunction(page, name, color, owner, functionName) end

---@param page Page
---@return bool
function API_BoneMenu.BL_DeletePage(page) end

---@param page Page
---@param name string
---@param color Color
---@param start float
---@param increment float
---@param min float
---@param max float
---@param owner LuaBehaviour
---@param function string
---@return FloatElement
function API_BoneMenu.BL_CreateFloatElement(page, name, color, start, increment, min, max, owner, functionName) end

function API_BoneMenu.InvokeFloatAction() end
