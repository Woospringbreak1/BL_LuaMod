---@meta

---@class API_GameObject
---@field Instance API_GameObject
API_GameObject = {}

---Loads all Unity/Il2Cpp assemblies.
function API_GameObject.LoadAllAssemblies() end

---@param obj UnityEngine.Object
---@return boolean
function API_GameObject.BL_IsValid(obj) end

---@return GameObject
function API_GameObject.BL_CreateEmptyGameObject() end

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

---@param gameObject GameObject
---@param name string
---@return DynValue[]
function API_GameObject.BL_FindAllInChildren(gameObject, name) end

---@param obj GameObject
---@param CompType string
---@param includeInactive boolean?
---@return DynValue[]
function API_GameObject.BL_GetComponentsInChildren(obj, CompType, includeInactive) end

---@param obj GameObject
---@param CompType string
---@return DynValue
function API_GameObject.BL_GetComponent2(obj, CompType) end

---@param obj GameObject
---@param CompType string
---@return DynValue[]
function API_GameObject.BL_GetComponents(obj, CompType) end

---@param obj GameObject
---@param CompType string
---@return DynValue
function API_GameObject.BL_AddComponent(obj, CompType) end

---@param obj GameObject
---@param CompType string
---@return DynValue
function API_GameObject.BL_GetComponentInChildren(obj, CompType) end

---@return number
function API_GameObject.TimeSinceOpen() end

---@param obj GameObject
function API_GameObject.BL_Destroy(obj) end

---@param obj GameObject
function API_GameObject.DestroyRoot(obj) end

---@param SpawnBCode string
---@return SpawnableCrate
function API_GameObject.BL_GetCrateReference(SpawnBCode) end

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
---@param Active boolean?
function API_GameObject.BL_SpawnByBarcode_LuaVar(LB, VariableName, SpawnBCode, pos, rotation, NewParent, Active) end

---@param PrefabName string
---@return GameObject
function API_GameObject.BL_GetPrefabReference(PrefabName) end

---@param PrefabName string
---@return GameObject
function API_GameObject.InstantiatePrefab(PrefabName) end
