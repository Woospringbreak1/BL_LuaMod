using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine.Assertions;
using UnityEngine;
using Il2CppInterop.Runtime;
using BoneLib;
using System.Reflection;
using MelonLoader;
using Unity.Mathematics;
using Il2CppSLZ.Marrow.Warehouse;
using MoonSharp.Interpreter;
using static Il2CppGoogle.Protobuf.Reflection.FieldOptions.Types;
using UnityEngine.Playables;
using System.Diagnostics.CodeAnalysis;
using Il2CppInterop.Runtime.InteropTypes;
using UnityEngine.Bindings;

//using Il2CppSystem;

namespace LuaMod.LuaAPI
{
    internal  class API_GameObject
    {
        public static readonly API_GameObject Instance = new API_GameObject();
        private static List<Type> LoadedTypes = new List<Type>();


        public static void LoadAllAssemblies()
        {
            /// load unity assemblies to allow GetComponent to work
            LoadAssemblyTypes("UnityEngine.Core");
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
                    if(InheritsFromUnityComponent(type))
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


        
        private static MonoBehaviour GetMonoBehaviour(GameObject obj, string CompType)
        {
            Component[] Comps = obj.GetComponents<Component>();

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

        public static DynValue BL_GetComponent(GameObject obj, string CompType)
        {
            System.Type Monoconversiontype = LoadedTypes.Find(t => t.Name == CompType);
            if (Monoconversiontype != null)
            {

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
        
        public static Rigidbody BL_GetRigidBody(GameObject obj)
        {
            return obj.GetComponent<Rigidbody>();
        }

        public static SphereCollider BL_GetSphereCollider(GameObject obj)
        {
            return obj.GetComponent<SphereCollider>();
        }


        public static void Destroy(GameObject obj)
        {
            GameObject.Destroy(obj);
        }

        public static void DestroyRoot(GameObject obj)
        {
            GameObject.Destroy(obj.transform.root.gameObject);
        }

        public static GameObject BL_SpawnByBarcode(string SpawnBCode,Vector3 pos, UnityEngine.Quaternion rotation)
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
        public static GameObject BL_GetPrefabReference(string PrefabName)
        {
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
            return null;
        }
    }
}
