using Il2CppCysharp.Threading.Tasks;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Circuits;
using Il2CppSLZ.Marrow.Data;
using Il2CppSLZ.Marrow.LateReferences;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppSLZ.SFX;
using MelonLoader;
using MoonSharp.Interpreter;
using System.Reflection;

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.UIElements;

//using Il2CppSystem;

namespace LuaMod.LuaAPI
{


    /// <summary>
    /// Lua-exposed API for GameObject manipulation in Bonelab.
    /// Provides methods for spawning, destroying, and modifying Unity GameObjects from Lua scripts.
    /// </summary>
    public class API_GameObject
    {
        /// <summary>
        /// Singleton instance of the API_GameObject class.
        /// </summary>
        public static readonly API_GameObject Instance = new API_GameObject();

        /// <summary>
        /// Creates a new empty GameObject in the scene.
        /// </summary>
        public GameObject BL_CreateEmptyGameObject()
        {
            return LuaSafeCall.Run(() =>
            {
                return new GameObject();
            }, "BL_CreateEmptyGameObject()");
        }

        /// <summary>
        /// Returns true if the given Unity Object is valid (not null).
        /// </summary>
        public static bool BL_IsValid(UnityEngine.Object obj)
        {
            return obj != null;
        }

        /// <summary>
        /// Instantiates a new GameObject based on the provided original.
        /// </summary>
        public GameObject BL_InstantiateGameObject(GameObject original)
        {
            return LuaSafeCall.Run(() =>
            {
                return GameObject.Instantiate(original);
            }, "BL_InstantiateGameObject()");
        }

        /// <summary>
        /// Finds a child GameObject by name under the specified parent GameObject.
        /// </summary>
        public DynValue BL_FindInChildren(GameObject gameObject, string name)
        {
            return LuaSafeCall.Run(() =>
            {
                Transform[] tfs = gameObject.GetComponentsInChildren<Transform>(true);
                foreach (Transform t in tfs)
                {
                    if (t.name == name)
                        return UserData.Create(t.gameObject);
                }
                return DynValue.Nil;
            }, $"BL_FindInChildren('{name}')");
        }

        /// <summary>
        /// Finds a GameObject in the scene by name.
        /// </summary>
        public DynValue BL_FindInWorld(string name)
        {
            return LuaSafeCall.Run(() =>
            {
                GameObject gameObject = GameObject.Find(name);
                return gameObject != null ? UserData.Create(gameObject) : DynValue.Nil;
            }, $"BL_FindInWorld('{name}')");
        }

        /// <summary>
        /// Finds all GameObjects in the scene with the specified name.
        /// </summary>
        public DynValue BL_FindAllInWorld(string name)
        {
            return LuaSafeCall.Run(() =>
            {
                GameObject[] allObjects = GameObject.FindObjectsOfType<GameObject>(true);
                List<DynValue> matches = new List<DynValue>();

                foreach (GameObject go in allObjects)
                {
                    if (go.name == name)
                        matches.Add(UserData.Create(go));
                }

                return matches.Count > 0 ? UserData.Create(matches) : DynValue.Nil;
            }, $"BL_FindAllInWorld('{name}')");
        }


        /// <summary>
        /// Finds all child GameObjects with the specified name.
        /// </summary>
        public DynValue BL_FindAllInChildren(GameObject gameObject, string name)
        {
            return LuaSafeCall.Run(() =>
            {
                Transform[] tfs = gameObject.GetComponentsInChildren<Transform>();
                List<DynValue> children = new List<DynValue>();

                foreach (Transform t in tfs)
                {
                    if (t.name == name)
                        children.Add(UserData.Create(t.gameObject));
                }

                return children.Count > 0 ? UserData.Create(children) : DynValue.Nil;
            }, $"BL_FindAllInChildren('{name}')");
        }


        /// <summary>
        /// Gets all components of the specified type in the GameObject's children.
        /// </summary>
        public List<DynValue> BL_GetComponentsInChildren(GameObject obj, string CompType, bool includeInactive = false)
        {
            return LuaSafeCall.Run(() =>
            {
                if (obj == null) throw new ScriptRuntimeException("GameObject is null");

                Type componentType = LuaMod.LoadedTypes.Find(t => t.Name == CompType);
                if (componentType == null) throw new ScriptRuntimeException($"Component type '{CompType}' not found");

                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "GetComponentsInChildren" && m.IsGenericMethod);

                MethodInfo genericMethod = method.MakeGenericMethod(componentType);
                dynamic components = genericMethod.Invoke(obj, new object[] { includeInactive });

                List<DynValue> luaArray = new List<DynValue>();
                foreach (object comp in components)
                    luaArray.Add(UserData.Create(comp));

                return luaArray.Count > 0 ? luaArray : null;
            }, $"BL_GetComponentsInChildren('{CompType}')");
        }

        /// <summary>
        /// Gets all components of the specified type in the world. Don't overuse this function.
        /// </summary>
        public DynValue BL_FindComponentsInWorld(string compType, bool includeInactive = false)
        {
            return LuaSafeCall.Run(() =>
            {
                Type componentType = LuaMod.LoadedTypes.Find(t => t.Name == compType);
                if (componentType == null)
                    throw new ScriptRuntimeException($"Component type '{compType}' not found");

                // Use Unity's generic FindObjectsOfType<T>(bool includeInactive)
                MethodInfo method = typeof(UnityEngine.Object)
                    .GetMethods(BindingFlags.Public | BindingFlags.Static)
                    .FirstOrDefault(m =>
                        m.Name == "FindObjectsOfType" &&
                        m.IsGenericMethod &&
                        m.GetParameters().Length == 1 &&
                        m.GetParameters()[0].ParameterType == typeof(bool));

                MethodInfo genericMethod = method.MakeGenericMethod(componentType);
                object results = genericMethod.Invoke(null, new object[] { includeInactive });

                List<DynValue> luaArray = new List<DynValue>();
                foreach (object comp in (IEnumerable<object>)results)
                    luaArray.Add(UserData.Create(comp));

                return luaArray.Count > 0 ? UserData.Create(luaArray) : DynValue.Nil;
            }, $"BL_FindComponentsInWorld('{compType}')");
        }


        /// <summary>
        /// Gets a component of the specified type on the GameObject.
        /// </summary>
        public DynValue BL_GetComponent(GameObject obj, string CompType)
        {
            return LuaSafeCall.Run(() =>
            {
                if (obj == null) throw new ScriptRuntimeException("GameObject is null");

                Type type = LuaMod.LoadedTypes.Find(t => t.Name == CompType);
                if (type == null) throw new ScriptRuntimeException($"Component type '{CompType}' not found");

                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "GetComponent" && m.IsGenericMethod);

                MethodInfo genericMethod = method.MakeGenericMethod(type);
                object component = genericMethod.Invoke(obj, null);

                return component != null ? UserData.Create(component) : DynValue.Nil;
            }, $"BL_GetComponent('{CompType}')");
        }


        /// <summary>
        /// Gets all components of the specified type on the GameObject.
        /// </summary>
        public List<DynValue> BL_GetComponents(GameObject obj, string CompType)
        {
            return LuaSafeCall.Run(() =>
            {
                if (obj == null) throw new ScriptRuntimeException("GameObject is null");

                Type componentType = LuaMod.LoadedTypes.Find(t => t.Name == CompType);
                if (componentType == null) throw new ScriptRuntimeException($"Component type '{CompType}' not found");

                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "GetComponents" && m.IsGenericMethod);

                MethodInfo genericMethod = method.MakeGenericMethod(componentType);
                dynamic components = genericMethod.Invoke(obj, new object[] { });

                List<DynValue> luaArray = new List<DynValue>();
                foreach (object comp in components)
                    luaArray.Add(UserData.Create(comp));

                return luaArray.Count > 0 ? luaArray : null;
            }, $"BL_GetComponents('{CompType}')");
        }

        /// <summary>
        /// Adds a component of the specified type to the GameObject.
        /// </summary>
        public DynValue BL_AddComponent(GameObject obj, string CompType)
        {
            return LuaSafeCall.Run(() =>
            {
                if (obj == null) throw new ScriptRuntimeException("GameObject is null");

                Type type = LuaMod.LoadedTypes.Find(t => t.Name == CompType);
                if (type == null) throw new ScriptRuntimeException($"Component type '{CompType}' not found");

                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "AddComponent" && m.IsGenericMethod);

                MethodInfo genericMethod = method.MakeGenericMethod(type);
                object component = genericMethod.Invoke(obj, null);

                return component != null ? UserData.Create(component) : DynValue.Nil;
            }, $"BL_AddComponent('{CompType}')");
        }

        /// <summary>
        /// Gets a component of the specified type from the GameObject's children.
        /// </summary>
        public DynValue BL_GetComponentInChildren(GameObject obj, string CompType)
        {
            
            return LuaSafeCall.Run(() =>
            {
                if (obj == null) throw new ScriptRuntimeException("GameObject is null");

                Type componentType = LuaMod.LoadedTypes.Find(t => t.Name == CompType);
                if (componentType == null) throw new ScriptRuntimeException($"Component type '{CompType}' not found");

                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "GetComponentInChildren" && m.IsGenericMethod);

                MethodInfo genericMethod = method.MakeGenericMethod(componentType);
                object component = genericMethod.Invoke(obj, new object[] { });

                return component != null ? UserData.Create(component) : DynValue.Nil;
            }, $"BL_GetComponentInChildren('{CompType}')");
        }


        /// <summary>
        /// Destroys the specified Unity Object.
        /// </summary>
        public static void BL_Destroy(UnityEngine.Object obj)
        {
            if (obj != null)
            {
                UnityEngine.Object.Destroy(obj);
            }
        }

        /// <summary>
        /// Spawns a crate by barcode at the specified position and rotation.
        /// </summary>
        public static void BL_SpawnByBarcode(string SpawnBCode, Vector3 pos, UnityEngine.Quaternion rotation)
        {
            LuaSafeCall.Run(() =>
            {
                BoneLib.HelperMethods.SpawnCrate(SpawnBCode, pos, rotation, Vector3.one, true, null);
            }, $"BL_SpawnByBarcode('{SpawnBCode}')");
        }

        /// <summary>
        /// Spawns a crate by barcode and assigns it to a LuaBehaviour script variable.
        /// Note: Crate spawning is asyncronous, so the variable won't be valid immediently
        /// </summary>
        public static void BL_SpawnByBarcode(LuaBehaviour LB, string VariableName, string SpawnBCode, Vector3 pos, UnityEngine.Quaternion rotation, GameObject NewParent, bool Active = true)
        {
            LuaSafeCall.Run(() =>
            {
                if (LB == null)
                    throw new Exception("LuaBehaviour is null");

                Action<Poolee> captureSpawnedCrate = (Poolee obj) =>
                {
                    if (obj == null || obj.gameObject == null)
                        throw new ScriptRuntimeException("Spawned crate is null or missing GameObject");

                    LB.SetScriptVariable(VariableName, UserData.Create(obj.gameObject));
                };

                var crateReference = new SpawnableCrateReference(SpawnBCode);
                var spawnable = new Spawnable() { crateRef = crateReference };

                AssetSpawner.Register(spawnable);

                UniTask<Poolee> task = AssetSpawner.SpawnAsync(
                    spawnable,
                    pos,
                    rotation,
                    new Il2CppSystem.Nullable<Vector3>(Vector3.one),
                    NewParent != null ? NewParent.transform : null,
                    Active,
                    new Il2CppSystem.Nullable<int>()
                );

                task.ContinueWith(captureSpawnedCrate);
            }, $"BL_SpawnByBarcode_LuaVar('{SpawnBCode}', var: '{VariableName}')");
        }

        /// <summary>
        /// Creates a DataCardReference for the given EntityPose barcode.
        /// </summary>
        public DataCardReference<EntityPose> BL_EntityPose(string barcode)
        {
            return new DataCardReference<EntityPose>(barcode);
        }




    }
}
