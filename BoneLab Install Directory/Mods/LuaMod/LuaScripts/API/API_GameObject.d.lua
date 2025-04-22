---@class API_GameObject
API_GameObject = {}

---@return GameObject
function API_GameObject.BL_CreateEmptyGameObject() end

---@param obj Object
---@return bool
function API_GameObject.BL_IsValid(obj) end

---@param original GameObject
---@return GameObject
function API_GameObject.BL_InstantiateGameObject(original) end

---@param gameObject GameObject
---@param name string
---@return DynValue
function API_GameObject.BL_FindInChildren(gameObject, name) end

---@param name string
---@return DynValue
function API_GameObject.BL_FindInWorld(name) end

---@param name string
---@return DynValue
function API_GameObject.BL_FindAllInWorld(name) end

---@param gameObject GameObject
---@param name string
---@return DynValue
function API_GameObject.BL_FindAllInChildren(gameObject, name) end

---@param compType string
---@param includeInactive bool
---@return DynValue
function API_GameObject.BL_FindComponentsInWorld(compType, includeInactive) end

---@param obj GameObject
---@param CompType string
---@return DynValue
function API_GameObject.BL_GetComponent(obj, CompType) end

---@param obj GameObject
---@param CompType string
---@return DynValue
function API_GameObject.BL_AddComponent(obj, CompType) end

---@param obj GameObject
---@param CompType string
---@return DynValue
function API_GameObject.BL_GetComponentInChildren(obj, CompType) end

---@param obj Object
function API_GameObject.BL_Destroy(obj) end

---@param SpawnBCode string
---@param pos Vector3
---@param rotation Quaternion
function API_GameObject.BL_SpawnByBarcode(SpawnBCode, pos, rotation) end

---@param LB LuaBehaviour
---@param VariableName string
---@param SpawnBCode string
---@param pos Vector3
---@param rotation Quaternion
---@param NewParent GameObject
---@param Active bool
function API_GameObject.BL_SpawnByBarcode(LB, VariableName, SpawnBCode, pos, rotation, NewParent, Active) end
