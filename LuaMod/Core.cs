using MelonLoader;
using MoonSharp;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;
using System;
using System.IO;
using UnityEngine;
using BoneLib;
using static UnityEngine.ResourceManagement.ResourceProviders.AssetBundleResource;
using Unity.Mathematics;
using System.Reflection;
using Il2CppInterop.Runtime;
using LuaMod.LuaAPI;
using HarmonyLib;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow.Combat;
[assembly: MelonInfo(typeof(LuaMod.Core), "LuaMod", "1.0.0", "pc", null)]
[assembly: MelonGame("Stress Level Zero", "BONELAB")]

namespace LuaMod
{


    public class Core : MelonMod
    {

        AssetBundle LuaBundle;
        public void LoadTypes()
        {
           // LuaBundle = HelperMethods.LoadEmbeddedAssetBundle(Assembly.GetExecutingAssembly(), "WeatherElectric.LabCam.Resources.LabCamWindows.bundle");
           // HelperMethods.LoadPersistentAsset<RenderTexture>(LuaBundle, "Assets/LabCam/LowQuality.renderTexture");

            //unity 

            UserData.RegisterType<UnityEngine.Vector3>();
            UserData.RegisterType<Transform>();
            UserData.RegisterType<Quaternion>();
            UserData.RegisterType<GameObject>();
            UserData.RegisterType<Component>();
            UserData.RegisterType<MonoBehaviour>();

            //unity physics
            UserData.RegisterType<Rigidbody>();
            UserData.RegisterType<SphereCollider>();
            UserData.RegisterType<BoxCollider>();
            UserData.RegisterType<CapsuleCollider>();
            UserData.RegisterType<Collision>();
            UserData.RegisterType<ContactPoint>();


            //lua API
            UserData.RegisterType<API_GameObject>();
            UserData.RegisterType<API_Input>();
            UserData.RegisterType<API_Player>();
            UserData.RegisterType<API_Vector>();
            UserData.RegisterType<API_Event>();
            UserData.RegisterType<API_SLZ_Combat>();
            UserData.RegisterType<API_SLZ_NPC>();
            
            UserData.RegisterType<LuaBehaviour>();
            UserData.RegisterType<LuaGun>();

            
            //SLZ
            UserData.RegisterType<EnemyDamageReceiver>();
            UserData.RegisterType<Attack>();



            API_GameObject.LoadAllAssemblies();
        }
        public void ReloadScripts()
        {
            
        }

        public override void OnUpdate()
        {
            if (Input.GetKey(KeyCode.LeftControl) && Input.GetKey(KeyCode.LeftShift) && Input.GetKey(KeyCode.R))
            {
                ReloadScripts();
            }

            if(Input.GetKeyDown(KeyCode.F1))
            {
                LoggerInstance.Msg("F1 pressed!");
                SpawnCube();
            }

            if (Input.GetKeyDown(KeyCode.F2))
            {
                LoggerInstance.Msg("F2 pressed - reloading scripts");
                ScriptManager.ReloadScripts();
            }

            if (Input.GetKeyDown(KeyCode.F3))
            {
                if(BoneLib.Player.LeftHand != null)
                {
                    Transform T = BoneLib.Player.LeftHand.transform;
                    API_GameObject.BL_SpawnByBarcode("c1534c5a-683b-4c01-b378-6795416d6d6f", T.position, T.rotation); //ammo box light
                    API_GameObject.BL_SpawnByBarcode("c1534c5a-fcfc-4f43-8fb0-d29531393131", T.position, T.rotation); //M1911
                }
            }

            if (Input.GetKeyDown(KeyCode.F4))
            {
                GameObject M1911 = GameObject.Find("handgun_1911 [0]");
                if (M1911 != null)
                {
                    LuaGun LG = M1911.GetComponent<Gun>().gameObject.AddComponent<LuaGun>();
                }
                else
                {
                    LoggerInstance.Msg("No 1911 located");
                }
            }
        }
        /*
        [HarmonyPatch(typeof(LuaGun), nameof(LuaGun.Fire))]
        private static class Patch_LuaGun_Fire
        {
            private static void Prefix()
            {
                MelonLoader.MelonLogger.Msg("firing Lua Gun");
            }
        }
          */


        public override void OnInitializeMelon()
        {
            LoadTypes();
            LogHelper.LoggerInstance = LoggerInstance;
            FieldInjector.SerialisationHandler.Inject<LuaBehaviour>();
            FieldInjector.SerialisationHandler.Inject<LuaGun>();



        }


        public void SpawnCube()
        {
            if (BoneLib.Player.Avatar != null)
            {
            
                
                Vector3 PlayerPos = BoneLib.Player.Head.position;
                LoggerInstance.Msg("player head position: " + PlayerPos.ToString());
                
                GameObject exampleOne = GameObject.CreatePrimitive(PrimitiveType.Cube); //GameObject.Instantiate(Resources.Load("rifle_M16_LaserForegrip_crazy", Il2CppType.Of<GameObject>())) as GameObject;

                LuaBehaviour Lbehaviour = exampleOne.AddComponent<LuaBehaviour>();
                //Lbehaviour.LoggerInstance = LoggerInstance;
                Lbehaviour.LoadScript("Mods\\LuaMod\\LuaScripts\\TestA.lua");

                LoggerInstance.Msg("game object spawned.");
                LoggerInstance.Msg(exampleOne.name);

                Transform examplePos = exampleOne.transform;

                MeshRenderer meshRenderer = exampleOne.GetComponent<MeshRenderer>();

                BoxCollider collider = examplePos.GetComponent<BoxCollider>();
                collider.enabled = false;
                examplePos.position = PlayerPos;
                HelperMethods.SpawnCrate("Authorr.LuaModTest.Spawnable.RifleM16LaserForegripcrazy", PlayerPos);
                
                meshRenderer.material = BoneLib.Player.Avatar.GetComponent<SkinnedMeshRenderer>().materials[0];
                

              

            }
            else
            {
                LoggerInstance.Msg("no player yet");
            }

        }

        public override void OnSceneWasLoaded(int buildIndex, string sceneName)
        {
           

        }

    }
}