---@class API_BoneMenu
API_BoneMenu = {}

---@type Page
API_BoneMenu.BL_Page = nil

---@param page Page
---@param name string
---@param color Color
---@param owner LuaBehaviour
---@param func string
---@return LuaFunctionElement
function API_BoneMenu.BL_CreateFunction(page, name, color, owner, func) end

---@param page Page
---@return boolean
function API_BoneMenu.BL_DeletePage(page) end
