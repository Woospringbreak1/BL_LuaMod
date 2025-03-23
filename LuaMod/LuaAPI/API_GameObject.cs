using Il2CppCysharp.Threading.Tasks;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Data;
using Il2CppSLZ.Marrow.LateReferences;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using MelonLoader;
using MoonSharp.Interpreter;
using System.Reflection;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.UIElements;

//using Il2CppSystem;

namespace LuaMod.LuaAPI
{
    internal class API_GameObject
    {
        public static readonly API_GameObject Instance = new API_GameObject();
        private static List<Type> LoadedTypes = new List<Type>();


        public static void LoadAllAssemblies()
        {
            /// load unity assemblies to allow GetComponent to work
            LoadAssemblyTypes("UnityEngine.Core");
            LoadAssemblyTypes("UnityEngine.CoreModule");
            LoadAssemblyTypes("UnityEngine");
            LoadAssemblyTypes("UnityEngine.PhysicsModule");
            LoadAssemblyTypes("UnityEngine.UIModule");
            LoadAssemblyTypes("UnityEngine.AIModule");
            LoadAssemblyTypes("UnityEngine.AnimationModule");
            LoadAssemblyTypes("UnityEngine.RenderingModule");
            LoadAssemblyTypes("UnityEngine.TextRenderingModule");
            LoadAssemblyTypes("UnityEngine.ParticleSystemModule");
            LoadAssemblyTypes("UnityEngine.TerrainModule");
            LoadAssemblyTypes("UnityEngine.AudioModule");
            LoadAssemblyTypes("UnityEngine.VideoModule");
            LoadAssemblyTypes("UnityEngine.InputLegacyModule");
            LoadAssemblyTypes("UnityEngine.InputSystem");
            LoadAssemblyTypes("UnityEngine.Core");
            LoadAssemblyTypes("UnityEngine.CoreModule");
            LoadAssemblyTypes("UnityEngine");
            LoadAssemblyTypes("Unity.TextMeshPro");
            LoadAssemblyTypes("Il2CppSLZ.Algorithms");
            LoadAssemblyTypes("Il2CppSLZ.Algorithms.Unity");
            LoadAssemblyTypes("Il2CppSLZ.Marrow");
            LoadAssemblyTypes("Il2CppSLZ.Marrow.VoidLogic.Core");
            LoadAssemblyTypes("Il2CppSLZ.Marrow.VoidLogic.Engine");


            PrintAssemblyTypes("Il2CppSLZ.Algorithms");
            PrintAssemblyTypes("Il2CppSLZ.Algorithms.Unity");
            PrintAssemblyTypes("Il2CppSLZ.Marrow");
            PrintAssemblyTypes("Il2CppSLZ.Marrow.VoidLogic.Core");
            PrintAssemblyTypes("Il2CppSLZ.Marrow.VoidLogic.Engine");

            LoadAssemblyTypes();
            //come back for more later...

        }

        private static void LoadAssemblyTypes()
        {
            //load types from this mod
            var types = Assembly.GetExecutingAssembly().GetTypes();
            List<System.Type> AcceptedTypes = new List<System.Type>();

            foreach (System.Type type in types)
            {
                if (InheritsFromUnityComponent(type))
                {
                    AcceptedTypes.Add(type);
                    MelonLoader.MelonLogger.Msg(type.Name + " added to reference list");
                }
                else
                {
                    //MelonLoader.MelonLogger.Warning(type.Name + " Is not a subtype of Component, skipping");
                }
            }

            LoadedTypes.AddRange(AcceptedTypes);

            MelonLoader.MelonLogger.Msg($"Successfully loaded {types.Length} types from local mod assembly");
        }


        public static bool InheritsFromUnityComponent(System.Type type)
        {
            if (type == null)
                return false;

            return type.IsSubclassOf(typeof(UnityEngine.Component)) || type == typeof(UnityEngine.Component);
        }


        private static void PrintAssemblyTypes(string assemblyPathOrName)
        {
            try
            {
                Assembly assembly;

                // Try loading by name first, if that fails, try loading by file path
                try
                {
                    assembly = Assembly.Load(assemblyPathOrName);
                }
                catch (Exception)
                {
                    assembly = Assembly.LoadFrom(assemblyPathOrName); //TODO: THIS IS PROBABLY A SECURITY 
                }

                // Get types and append to the static list
                var types = assembly.GetTypes();
                List<System.Type> AcceptedTypes = new List<System.Type>();

                foreach (System.Type type in types)
                {
                    if (InheritsFromUnityComponent(type))
                    {
                        
                        MelonLoader.MelonLogger.Msg("UserData.RegisterType<" + type.Name + ">();");
                    }
                    else
                    {
                        //MelonLoader.MelonLogger.Warning(type.Name + " Is not a subtype of Component, skipping");
                    }
                }

                LoadedTypes.AddRange(AcceptedTypes);

                MelonLoader.MelonLogger.Msg($"Successfully loaded {AcceptedTypes.Count} types from {assembly.FullName}");
            }
            catch (Exception ex)
            {
                MelonLoader.MelonLogger.Error($"Error loading assembly: {ex.Message}");
            }
        }

        private static void LoadAssemblyTypes(string assemblyPathOrName)
        {
            try
            {
                Assembly assembly;

                // Try loading by name first, if that fails, try loading by file path
                try
                {
                    assembly = Assembly.Load(assemblyPathOrName);
                }
                catch (Exception)
                {
                    assembly = Assembly.LoadFrom(assemblyPathOrName); //TODO: THIS IS PROBABLY A SECURITY 
                }

                // Get types and append to the static list
                var types = assembly.GetTypes();
                List<System.Type> AcceptedTypes = new List<System.Type>();

                foreach (System.Type type in types)
                {
                    if (InheritsFromUnityComponent(type))
                    {
                        AcceptedTypes.Add(type);
                        MelonLoader.MelonLogger.Msg(type.Name + " added to reference list");
                    }
                    else
                    {
                        //MelonLoader.MelonLogger.Warning(type.Name + " Is not a subtype of Component, skipping");
                    }
                }

                LoadedTypes.AddRange(AcceptedTypes);

                MelonLoader.MelonLogger.Msg($"Successfully loaded {AcceptedTypes.Count} types from {assembly.FullName}");
            }
            catch (Exception ex)
            {
                MelonLoader.MelonLogger.Error($"Error loading assembly: {ex.Message}");
            }
        }

        public GameObject BL_CreateEmptyGameObject()
        {
            return new GameObject();
        }

        public bool BL_IsValid(UnityEngine.Object obj)
        {
            return obj != null;
        }

        public GameObject BL_InstantiateGameObject(GameObject original)
        {
            return(GameObject.Instantiate(original));
        }


        public DynValue BL_FindInChildren(GameObject gameObject, string name)
        {
            Transform[] tfs = gameObject.GetComponentsInChildren<Transform>(true);
            

            foreach (Transform t in tfs)
            {
                //MelonLogger.Msg("Trying to compare provided name: " + name + " and " + t.name);
                if (t.name == name)
                {
                 //   MelonLogger.Msg("It was a match!");
                   return(UserData.Create(t));
                }
              //  MelonLogger.Msg("no match!");
            }

            return DynValue.Nil;

        }

        public DynValue BL_FindAllInChildren(GameObject gameObject, string name)
        {
           Transform[] tfs = gameObject.GetComponentsInChildren<Transform>();
            List<DynValue> children = new List<DynValue>();

            foreach (Transform t in tfs) 
            {
                if(t.name == name)
                {  
                    children.Add(UserData.Create(t));
                }
            }

            return UserData.Create(children);  

        }

        public static List<DynValue> BL_GetComponentsInChildren(GameObject obj, string CompType, bool includeInactive = false)
        {
    
            if (obj == null)
            {
                MelonLogger.Error("[BL_GetComponentsInChildren] GameObject is null!");
                return null;
            }

            Type componentType = LoadedTypes.Find(t => t.Name == CompType);
            if (componentType != null)
            {
                // Get the correct generic method
                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "GetComponentsInChildren" && m.IsGenericMethod);

                MethodInfo genericMethod = method.MakeGenericMethod(componentType);

                // Invoke the method with 'includeInactive' parameter
                object[] parameters = new object[] { includeInactive };
                dynamic components = genericMethod.Invoke(obj, parameters);

               // if (components is Array componentArray)
               // {
                    // Convert C# array to Lua-compatible table (array)
                    List<DynValue> luaArray = new List<DynValue>();
                    foreach (object comp in components)
                    {
                        luaArray.Add(UserData.Create(comp));
                    }

                    return luaArray;
               // }
               // else
               // {
               //     MelonLogger.Error($"[BL_GetComponentsInChildren] returned array invalid");
              //  }
            }
            else
            {
                MelonLogger.Error($"[BL_GetComponentsInChildren] Component type '{CompType}' not found!");
            }

            return null;
        }

        public static DynValue BL_GetComponent2(GameObject obj, string CompType)
        {
            //  MeshFilter Test1 = obj.GetComponent<MeshFilter>();
            //   object Test2 = obj.GetComponent<MeshFilter>();

            if (obj == null)
            {
                MelonLoader.MelonLogger.Error("provided GameObject is nil");
                return null;
            }


                System.Type Monoconversiontype = LoadedTypes.Find(t => t.Name == CompType);
            if (Monoconversiontype != null)
            {
                
                System.Reflection.MethodInfo method = typeof(GameObject)
                    .GetMethods(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance)
                    .First(m => m.Name == "GetComponent" && m.IsGenericMethod);

                System.Reflection.MethodInfo genericMethod = method.MakeGenericMethod(Monoconversiontype);
                object ConvertedOutComp = genericMethod.Invoke(obj, null);

                return ConvertedOutComp != null ? UserData.Create(ConvertedOutComp) : DynValue.Nil;
            }
            else
            {
                MelonLoader.MelonLogger.Error("Monoconversiontype is nil");
            }
               

            return DynValue.Nil; // Ensure function always returns a value
        }


        public static DynValue BL_AddComponent(GameObject obj, string CompType)
        {

            if (obj == null)
            {
                MelonLoader.MelonLogger.Error("provided GameObject is nil");
                return null;
            }


            System.Type Monoconversiontype = LoadedTypes.Find(t => t.Name == CompType);
            if (Monoconversiontype != null)
            {

                System.Reflection.MethodInfo method = typeof(GameObject)
                    .GetMethods(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance)
                    .First(m => m.Name == "AddComponent" && m.IsGenericMethod);

                System.Reflection.MethodInfo genericMethod = method.MakeGenericMethod(Monoconversiontype);
                object ConvertedOutComp = genericMethod.Invoke(obj, null);

                return ConvertedOutComp != null ? UserData.Create(ConvertedOutComp) : DynValue.Nil;
            }
            else
            {
                MelonLoader.MelonLogger.Error("Monoconversiontype is nil");
            }


            return DynValue.Nil; // Ensure function always returns a value
        }

        public static DynValue BL_GetComponentInChildren(GameObject obj, string CompType)
        {
            if (obj == null)
            {
                MelonLogger.Error("[BL_GetComponentInChildren] GameObject is null!");
                return DynValue.Nil;
            }

            Type componentType = LoadedTypes.Find(t => t.Name == CompType);
            if (componentType != null)
            {   
                // Find the correct method
                MethodInfo method = typeof(GameObject)
                    .GetMethods(BindingFlags.Public | BindingFlags.Instance)
                    .First(m => m.Name == "GetComponentInChildren" && m.IsGenericMethod);
                
                MethodInfo genericMethod = method.MakeGenericMethod(componentType);

                // Invoke with the bool parameter
                object[] parameters = new object[] { };
                object component = genericMethod.Invoke(obj, parameters);

                return component != null ? UserData.Create(component) : DynValue.Nil;
            }
            else
            {
                MelonLogger.Error($"[BL_GetComponentInChildren] Component type '{CompType}' not found!");
            }

            return DynValue.Nil;
    }
        /*
    private static MonoBehaviour GetMonoBehaviour(GameObject obj, string CompType)
        {

            // doesn't work with textmeshpro - why?

            Component[] Comps = obj.GetComponentsInChildren<Component>(); // probably change this back?
           // Component[] Comps = obj.GetComponents<Component>();

            foreach (Component comp in Comps)
            {
                System.Type type = comp.GetType();

                if (type.Name == CompType)
                {
                    //MelonLoader.MelonLogger.Warning("Component of" + obj.name + " " + type.Name + " matches desired type " + CompType);
                    return (MonoBehaviour)comp;
                }
                else
                {
                    //MelonLoader.MelonLogger.Warning("Component of" + obj.name + " " + type.Name + " does not match desired type " + CompType);
                }
            }
            return null;
        }
        */

        public static float TimeSinceOpen()
        {
            return(Time.realtimeSinceStartup);
        }

        /*
        public static DynValue BL_GetComponent(GameObject obj, string CompType)
        {
            System.Type Monoconversiontype = LoadedTypes.Find(t => t.Name == CompType);
            if (Monoconversiontype != null)
            {
                // doesn't work with textmeshpro - why?
                
                if (Monoconversiontype.IsSubclassOf(typeof(UnityEngine.MonoBehaviour)))
                {
                    //different approach for monobehaviours. need to check that namespaces function
                    return UserData.Create(GetMonoBehaviour(obj, CompType));
               }

                //otherwise, dynamically cast to the appropriate Component subclass
                Il2CppSystem.Object OutComp = obj.GetComponentByName(CompType);


                System.Reflection.MethodInfo method = typeof(Il2CppSystem.Object).GetMethod("TryCast", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance).MakeGenericMethod(Monoconversiontype);
                Il2CppSystem.Object ConvertedOutComp = (Il2CppSystem.Object)method.Invoke(OutComp, null);
                DynValue DV = UserData.Create(ConvertedOutComp);
                return DV;
            }
            else
            {
                MelonLoader.MelonLogger.Warning("Component type " + CompType + " not found in unity assemblies");
                return null;
            }

        }
        */


        public static void BL_DestroyGameObject(GameObject obj)
        {
            GameObject.Destroy(obj);
        }

        public static void DestroyRoot(GameObject obj)
        {
            GameObject.Destroy(obj.transform.root.gameObject);
        }


        
        
        public static SpawnableCrate BL_GetCrateReference(string SpawnBCode)
        {
            return null;
          //  AssetSpawner.
           // SpawnableCrateReference crateReference = new SpawnableCrateReference(SpawnBCode);
           // (GameObject)crateReference.Crate.MainAsset.Asset;
           // MelonLoader.MelonLogger.Msg("Crate gameobject name " + crateReference.Crate.MainGameObject.Asset.name);
           // return crateReference.Crate;            
        }
        
        public static GameObject BL_SpawnByBarcode(string SpawnBCode, Vector3 pos, UnityEngine.Quaternion rotation)
        {
            GameObject spawnedCrate = null;

            Action<GameObject> captureSpawnedCrate = (GameObject obj) =>
            {
                spawnedCrate = obj;
            };
            BoneLib.HelperMethods.SpawnCrate(SpawnBCode, pos, rotation, Vector3.one, true, captureSpawnedCrate);
            if (spawnedCrate != null)
            {

                return spawnedCrate;
            }
            else
            {
                MelonLoader.MelonLogger.Error("Spawned crate was null");
                return null;
            }

            return null;

        }

        public static void BL_SpawnByBarcode_LuaVar(LuaBehaviour LB,string VariableName,string SpawnBCode, Vector3 pos, UnityEngine.Quaternion rotation, GameObject NewParent, bool Active = true)
        {
            
            Action<Poolee> captureSpawnedCrate = (Poolee obj) =>
            {
                // spawnedCrate = obj;
                MelonLogger.Msg("WORKING " + obj.name);
                LB.SetScriptVariable(VariableName, UserData.Create(obj.gameObject));

               // outobj =  obj.gameObject;
            };

            SpawnableCrateReference crateReference = new SpawnableCrateReference(SpawnBCode);
            Spawnable spawnable = new Spawnable()
            {
                crateRef = crateReference
            };

            AssetSpawner.Register(spawnable);
            UniTask<Poolee> task = AssetSpawner.SpawnAsync(spawnable, pos, rotation, new Il2CppSystem.Nullable<Vector3>(Vector3.one),NewParent != null ? NewParent.transform : null, true, new Il2CppSystem.Nullable<int>());
            task.ContinueWith(captureSpawnedCrate);
      
        }

        /*
        public static IEnumerator BL_SpawnByBarcode_Ref(Script script, string VariableName, string SpawnBCode, Vector3 pos, UnityEngine.Quaternion rotation, GameObject NewParent, bool Active = true)
        {
            GameObject outobj = null;
            Action<Poolee> captureSpawnedCrate = (Poolee obj) =>
            {
                // spawnedCrate = obj;
                MelonLogger.Msg("WORKING " + obj.name);
                script.Globals["VariableName"] = UserData.Create(obj.gameObject);

                // outobj =  obj.gameObject;
            };

            SpawnableCrateReference crateReference = new SpawnableCrateReference(SpawnBCode);
            Spawnable spawnable = new Spawnable()
            {
                crateRef = crateReference
            };

            AssetSpawner.Register(spawnable);
            UniTask<Poolee> task = AssetSpawner.SpawnAsync(spawnable, pos, rotation, new Il2CppSystem.Nullable<Vector3>(Vector3.one), NewParent.transform, true, new Il2CppSystem.Nullable<int>());
            yield return task;

        }
        */


        public static GameObject BL_GetPrefabReference(string PrefabName)
        {

            throw new NotImplementedException();
            /*
            IEnumerable<AssetBundle> bundles = (IEnumerable<AssetBundle>)AssetBundle.GetAllLoadedAssetBundles();
            AssetBundle Bundle = AssetBundle.LoadFromFile( "33.33.Level.LevelTest.bundle");
            GameObject prefab = HelperMethods.LoadPersistentAsset<GameObject>(Bundle, PrefabName);
            //LuaBundle = HelperMethods.LoadEmbeddedAssetBundle(Assembly.GetExecutingAssembly(), "WeatherElectric.LabCam.Resources.LabCamWindows.bundle");
            // HelperMethods.LoadPersistentAsset<RenderTexture>(LuaBundle, "Assets/LabCam/LowQuality.renderTexture");

            ///Uses Resources.Load to load a prefab. Don't use this for spawning
           // GameObject prefab = (Resources.Load(PrefabName, Il2CppType.Of<GameObject>())) as GameObject;
            if (prefab != null)
            {
                return prefab;
            }
            */
            return null;
        }

        public static GameObject InstantiatePrefab(string PrefabName)
        {
            throw new NotImplementedException();
        }
    }
}
