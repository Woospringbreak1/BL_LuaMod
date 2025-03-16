using BoneLib;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Circuits;
using Il2CppSLZ.Marrow.Combat;
using Il2CppSLZ.Marrow.Interaction;
using Il2CppSLZ.Marrow.VoidLogic;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppTMPro;
using LuaMod.LuaAPI;
using MelonLoader;
using MoonSharp.Interpreter;
using UnityEngine;
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

            //Moonsharp

            UserData.RegisterType<List<DynValue>>();
            UserData.RegisterType<List<string>>();


            //unity
            //UserData.RegisterType<UnityEngine.Object>();
            UserData.RegisterType<UnityEngine.Vector3>();
            UserData.RegisterType<Transform>();
            UserData.RegisterType<Quaternion>();
            UserData.RegisterType<GameObject>();
            UserData.RegisterType<Component>();
            UserData.RegisterType<MonoBehaviour>();
            UserData.RegisterType<Time>();
            UserData.RegisterType<UnityEngine.Color>();
            UserData.RegisterType<Renderer>();
            UserData.RegisterType<Bounds>();
            UserData.RegisterType<Vector2>();
            UserData.RegisterType<Matrix4x4>();

            //unity physics
            UserData.RegisterType<Physics>();
            UserData.RegisterType<Rigidbody>();
            UserData.RegisterType<SphereCollider>();
            UserData.RegisterType<BoxCollider>();
            UserData.RegisterType<CapsuleCollider>();
            UserData.RegisterType<Collision>();
            UserData.RegisterType<ContactPoint>();
            UserData.RegisterType<RaycastHit>();
            UserData.RegisterType<HingeJoint>();
            UserData.RegisterType<Joint>();
            UserData.RegisterType<JointMover>();
            UserData.RegisterType<JointMotor>();
            UserData.RegisterType<JointLimits>();
            UserData.RegisterType<JointDrive>();
            UserData.RegisterType<JointSpring>();
            UserData.RegisterType<JointVisual>();
            UserData.RegisterType<ConfigurableJoint>();
            UserData.RegisterType<Collider[]>();
            UserData.RegisterType<Collider>();
            UserData.RegisterType<QueryTriggerInteraction>();

            //lua API
            UserData.RegisterType<API_GameObject>();
            UserData.RegisterType<API_Input>();
            UserData.RegisterType<API_Player>();
            UserData.RegisterType<API_Vector>();
            UserData.RegisterType<API_Event>();
            UserData.RegisterType<API_SLZ_Combat>();
            UserData.RegisterType<API_SLZ_NPC>();
            UserData.RegisterType<API_SLZ_VoidLogic>();
            UserData.RegisterType<API_Physics>();
            
            UserData.RegisterType<LuaBehaviour>();
            UserData.RegisterType<LuaGun>();


            //TextMeshPro

            UserData.RegisterType<TextMeshPro>();

            //SLZ
            UserData.RegisterType<EnemyDamageReceiver>();
            UserData.RegisterType<Attack>();
            UserData.RegisterType<Gun>();
            UserData.RegisterType<Magazine>();
            UserData.RegisterType<MagazineState>();

            UserData.RegisterType<MarrowBody>();
            UserData.RegisterType<MarrowEntity>();
            UserData.RegisterType<MarrowJoint>();

            UserData.RegisterType<AIBrain>();
            
            UserData.RegisterType<SpawnableCrate>();

            //void logic
            UserData.RegisterType<BaseNode>();
            UserData.RegisterType<LeverNode>();
            UserData.RegisterType<IVoidLogicActuator>();
            UserData.RegisterType<IVoidLogicNode>();
            UserData.RegisterType<IVoidLogicSensor>();

            //circuits
            UserData.RegisterType<Circuit>();
            UserData.RegisterType<CircuitSocket>();
            UserData.RegisterType<AddCircuit>();
            UserData.RegisterType<ExternalCircuit>();
            UserData.RegisterType<FlipflopCircuit>();
            UserData.RegisterType<MultiplyCircuit>();
            UserData.RegisterType<RemapCircuit>();
            UserData.RegisterType<ValueCircuit>();
            UserData.RegisterType<XorCircuit>();
            UserData.RegisterType<ZoneCircuit>();
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

            if (Input.GetKeyDown(KeyCode.F1))
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
                if (BoneLib.Player.LeftHand != null)
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


        public override void OnInitializeMelon()
        {
            
            LogHelper.LoggerInstance = LoggerInstance;
   



        }

        public override void OnLateInitializeMelon()
        {
            API_GameObject.LoadAllAssemblies();
            LoadTypes();
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