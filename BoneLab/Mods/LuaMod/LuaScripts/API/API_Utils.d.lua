---@class API_Utils
API_Utils = {}

---@param collection ICollection
---@return int
function API_Utils.BL_CollectionLength(collection) end

---@return string
function API_Utils.BL_GetSceneName() end

---@param gameObject GameObject
---@return string
function API_Utils.BL_GetBarcode(gameObject) end

---@param obj Object
---@param CompType string
---@return DynValue
function API_Utils.BL_ConvertObjectToType(obj, CompType) end

---@param input string
---@return string
function API_Utils.RemoveDoubleSlashes(input) end

---@param target object
---@param fieldName string
---@param index int
---@return DynValue
function API_Utils.BL_GetArrayElement(target, fieldName, index) end

---@param target object
---@param fieldName string
---@param value object
function API_Utils.BL_AppendToArray(target, fieldName, value) end

---@param target object
---@param fieldName string
---@param index int
---@param value object
function API_Utils.BL_SetArrayElement(target, fieldName, index, value) end
