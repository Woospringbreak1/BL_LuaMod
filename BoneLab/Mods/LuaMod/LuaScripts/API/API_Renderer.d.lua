---@class API_Renderer
API_Renderer = {}

---@param renderer MeshRenderer
---@return int
function API_Renderer.BL_GetMaterialCount(renderer) end

---@param renderer MeshRenderer
---@param index int
---@return DynValue
function API_Renderer.BL_GetMaterialAt(renderer, index) end

---@param renderer MeshRenderer
---@param index int
---@param mat Material
function API_Renderer.BL_SetMaterialAt(renderer, index, mat) end

---@param script Script
---@param renderer MeshRenderer
---@return Table
function API_Renderer.BL_GetAllMaterials(script, renderer) end

---@param renderer MeshRenderer
---@param matTable Table
function API_Renderer.BL_SetAllMaterials(renderer, matTable) end
