using BoneLib;
using Il2Cpp;
using Il2CppPuppetMasta;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Audio;
using Il2CppSLZ.Marrow.Blueprints;
using Il2CppSLZ.Marrow.Circuits;
using Il2CppSLZ.Marrow.Combat;
using Il2CppSLZ.Marrow.Forklift;
using Il2CppSLZ.Marrow.Input;
using Il2CppSLZ.Marrow.Interaction;
using Il2CppSLZ.Marrow.LateReferences;
using Il2CppSLZ.Marrow.Mechanics;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.PuppetMasta;
using Il2CppSLZ.Marrow.Redacted;
using Il2CppSLZ.Marrow.SceneStreaming;
using Il2CppSLZ.Marrow.Utilities;
using Il2CppSLZ.Marrow.VoidLogic;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppSLZ.Marrow.Zones;
using Il2CppSLZ.SFX;
using Il2CppSLZ.VFX;
using Il2CppSLZ.VRMK;
using Il2CppSteam.VR.Features;
using Il2CppTMPro;
using LuaMod.BoneMenu;
using LuaMod.LuaAPI;
using MelonLoader;
using MoonSharp.Interpreter;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Animations.Rigging;
using UnityEngine.Video;
using static Il2CppSLZ.Bonelab.SceneAmmoUI;
using static UnityEngine.ParticleSystem;
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
            UserData.RegisterType<Particle[]>();
            //lua API
            UserData.RegisterType<API_GameObject>();
            UserData.RegisterType<API_Input>();
            UserData.RegisterType<API_Player>();
            UserData.RegisterType<API_Vector>();
            UserData.RegisterType<API_Events>();
            UserData.RegisterType<API_SLZ_Combat>();
            UserData.RegisterType<API_SLZ_NPC>();
            UserData.RegisterType<API_SLZ_VoidLogic>();
            UserData.RegisterType<API_Physics>();
            UserData.RegisterType<API_Random>();
            UserData.RegisterType<API_Utils>();
            UserData.RegisterType<API_BoneMenu>();
            UserData.RegisterType<API_Audio>();
            UserData.RegisterType<API_Particles>();
            

            UserData.RegisterType<LuaBehaviour>();
            UserData.RegisterType<LuaGun>();
            UserData.RegisterType<LuaNPC>();

            RegisterUnityTypes();
            RegisterSLZTypes();

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
            UserData.RegisterType<UnityEngine.Time>();
            UserData.RegisterType<Camera>();
           
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

            
            //TextMeshPro

            UserData.RegisterType<TextMeshPro>();

            //BoneMenu
            UserData.RegisterType<BoneLib.BoneMenu.Page>();
            UserData.RegisterType<BoneLib.BoneMenu.BoolElement>();
            UserData.RegisterType<BoneLib.BoneMenu.Dialog>();
            UserData.RegisterType<BoneLib.BoneMenu.Element>();
            UserData.RegisterType<BoneLib.BoneMenu.ElementProperties>();
            UserData.RegisterType<BoneLib.BoneMenu.EnumElement>();
            UserData.RegisterType<BoneLib.BoneMenu.FloatElement>();
            //UserData.RegisterType<BoneLib.BoneMenu.FunctionElement>(); //naughty
            UserData.RegisterType<LuaFunctionElement>(); //use this instead
            UserData.RegisterType<BoneLib.BoneMenu.PageLinkElement>();
            UserData.RegisterType<BoneLib.BoneMenu.StringElement>();
            UserData.RegisterType<BoneLib.BoneMenu.SubPage>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.BackspaceKey>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.DoubleZeroKey>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.EnterKey>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIBoolElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIDialog>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIElementDrawer>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIEnumElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIFloatElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIFunctionElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIInfoBox>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIIntElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIMenu>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIPool>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIPoolee>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.GUIStringElement>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.Key>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.Keyboard>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.ShiftKey>();
            UserData.RegisterType<BoneLib.BoneMenu.UI.SpaceKey>();
            /*
            //SLZ
            UserData.RegisterType<EnemyDamageReceiver>();
            UserData.RegisterType<AIBrain>();
            UserData.RegisterType<AIManager>();
            UserData.RegisterType<BehaviourCrablet>();
            UserData.RegisterType<BehaviourGrabbableBaseNav>();
            UserData.RegisterType<PuppetMaster>();
            UserData.RegisterType<BehaviourBase>();
            UserData.RegisterType<BehaviourBaseNav>();
            UserData.RegisterType<BehaviourPowerLegs>();
            UserData.RegisterType<BehaviourAnimatedStagger>();
            UserData.RegisterType<BehaviourBaseTurret>();
            UserData.RegisterType<BehaviourFall>();
            UserData.RegisterType<BehaviourGrabbableBaseNav>();
            UserData.RegisterType<BehaviourHead>();
            UserData.RegisterType<BehaviourTemplate>();
            UserData.RegisterType<BehaviourFall>();
            UserData.RegisterType<Il2CppSLZ.Bonelab.AccordionSliderDoor>();
            UserData.RegisterType<Il2CppSLZ.Bonelab.ActionDirector>();
            //UserData.RegisterType<Il2CppSLZ.Marrow.>();

            UserData.RegisterType<Attack>();
            UserData.RegisterType<Gun>();
            UserData.RegisterType<Magazine>();
            UserData.RegisterType<MagazineState>();

            UserData.RegisterType<MarrowBody>();
            UserData.RegisterType<MarrowEntity>();
            UserData.RegisterType<MarrowJoint>();

            
            UserData.RegisterType<SpawnableCrate>();

            UserData.RegisterType<Hand>();
            UserData.RegisterType<Grip>();

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
            */
        }


        private void RegisterUnityTypes()
        {
            UserData.RegisterType<Animation>();
            UserData.RegisterType<AnimationClip>();
            UserData.RegisterType<AnimationClipPair>();
            UserData.RegisterType<AnimationCurve>();
            UserData.RegisterType<AnimationEvent>();
            UserData.RegisterType<AnimationState>();
            UserData.RegisterType<Animator>();
            UserData.RegisterType<AnimatorClipInfo>();
            UserData.RegisterType<AnimatorControllerParameter>();
            UserData.RegisterType<AnimatorOverrideController>();
            UserData.RegisterType<AnimatorStateInfo>();
            UserData.RegisterType<AnimatorTransitionInfo>();
            UserData.RegisterType<AnimatorUtility>();
            UserData.RegisterType<ArticulationBody>();
            UserData.RegisterType<AudioChorusFilter>();
            UserData.RegisterType<AudioClip>();
            UserData.RegisterType<AudioDistortionFilter>();
            UserData.RegisterType<AudioEchoFilter>();
            UserData.RegisterType<AudioHighPassFilter>();
            UserData.RegisterType<AudioListener>();
            UserData.RegisterType<AudioLowPassFilter>();
            UserData.RegisterType<AudioRenderer>();
            UserData.RegisterType<AudioReverbFilter>();
            UserData.RegisterType<AudioReverbZone>();
            UserData.RegisterType<AudioSettings>();
            UserData.RegisterType<AudioSource>();
            UserData.RegisterType<Behaviour>();
            UserData.RegisterType<BillboardAsset>();
            UserData.RegisterType<BillboardRenderer>();
            UserData.RegisterType<BoneWeight>();
            UserData.RegisterType<BoneWeight1>();
            UserData.RegisterType<BoundingSphere>();
            UserData.RegisterType<Bounds>();
            UserData.RegisterType<BoundsInt>();
            UserData.RegisterType<BoxCollider>();
            UserData.RegisterType<BoxCollider2D>();
            UserData.RegisterType<BuoyancyEffector2D>();
            UserData.RegisterType<Camera>();
            UserData.RegisterType<Canvas>();
            UserData.RegisterType<CanvasGroup>();
            UserData.RegisterType<CanvasRenderer>();
            UserData.RegisterType<CapsuleCollider>();
            UserData.RegisterType<CapsuleCollider2D>();
            UserData.RegisterType<CharacterController>();
            UserData.RegisterType<CharacterInfo>();
            UserData.RegisterType<CharacterJoint>();
            UserData.RegisterType<CircleCollider2D>();
            UserData.RegisterType<Cloth>();
            UserData.RegisterType<ClothSphereColliderPair>();
            UserData.RegisterType<Collider>();
            UserData.RegisterType<Collider2D>();
            UserData.RegisterType<Collision>();
            UserData.RegisterType<Collision2D>();
            UserData.RegisterType<Color>();
            UserData.RegisterType<Color32>();
            UserData.RegisterType<ColorUtility>();
            UserData.RegisterType<CombineInstance>();
            UserData.RegisterType<Component>();
            UserData.RegisterType<CompositeCollider2D>();
            UserData.RegisterType<ConfigurableJoint>();
            UserData.RegisterType<ConfigurableJointMotion>();
            UserData.RegisterType<ConstantForce>();
            UserData.RegisterType<ConstantForce2D>();
            UserData.RegisterType<ContactFilter2D>();
            UserData.RegisterType<ContactPoint>();
            UserData.RegisterType<ContactPoint2D>();
            UserData.RegisterType<ControllerColliderHit>();
            UserData.RegisterType<Cubemap>();
            UserData.RegisterType<CubemapArray>();
            UserData.RegisterType<CullingGroup>();
            UserData.RegisterType<CullingGroupEvent>();
            UserData.RegisterType<CustomCollider2D>();
            UserData.RegisterType<CustomRenderTexture>();
            UserData.RegisterType<DetailInstanceTransform>();
            UserData.RegisterType<DetailPrototype>();
            UserData.RegisterType<DistanceJoint2D>();
            UserData.RegisterType<DrivenRectTransformTracker>();
            UserData.RegisterType<DynamicGI>();
            UserData.RegisterType<EdgeCollider2D>();
            UserData.RegisterType<Effector2D>();
            UserData.RegisterType<ExitGUIException>();
            UserData.RegisterType<FixedJoint>();
            UserData.RegisterType<FixedJoint2D>();
            UserData.RegisterType<Flare>();
            UserData.RegisterType<FlareLayer>();
            UserData.RegisterType<FrictionJoint2D>();
            UserData.RegisterType<FrustumPlanes>();
            UserData.RegisterType<ForceMode>();
            UserData.RegisterType<GameObject>();
            UserData.RegisterType<GeometryUtility>();
            UserData.RegisterType<Gradient>();
            UserData.RegisterType<GradientAlphaKey>();
            UserData.RegisterType<GradientColorKey>();
            UserData.RegisterType<Grid>();
            UserData.RegisterType<GridBrushBase>();
            UserData.RegisterType<GridLayout>();
            UserData.RegisterType<GUI>();
            UserData.RegisterType<GUIContent>();
            UserData.RegisterType<GUILayout>();
            UserData.RegisterType<GUILayoutOption>();
            UserData.RegisterType<GUILayoutUtility>();
            UserData.RegisterType<GUISettings>();
            UserData.RegisterType<GUISkin>();
            UserData.RegisterType<GUIStyle>();
            UserData.RegisterType<GUIStyleState>();
            UserData.RegisterType<GUIUtility>();
            UserData.RegisterType<Hash128>();
            UserData.RegisterType<HDROutputSettings>();
            UserData.RegisterType<HingeJoint>();
            UserData.RegisterType<HingeJoint2D>();
            UserData.RegisterType<HumanBone>();
            UserData.RegisterType<HumanDescription>();
            UserData.RegisterType<HumanLimit>();
            UserData.RegisterType<HumanPoseHandler>();
            UserData.RegisterType<HumanTrait>();
            UserData.RegisterType<Input>();
            UserData.RegisterType<Joint>();
            UserData.RegisterType<Joint2D>();
            UserData.RegisterType<JointDrive>();
            UserData.RegisterType<JointLimits>();
            UserData.RegisterType<JointMotor>();
            UserData.RegisterType<JointSpring>();
            UserData.RegisterType<Keyframe>();
            UserData.RegisterType<LayerMask>();
            UserData.RegisterType<LensFlare>();
            UserData.RegisterType<Light>();
            UserData.RegisterType<LightBakingOutput>();
            UserData.RegisterType<LightingSettings>();
            UserData.RegisterType<LightmapData>();
            UserData.RegisterType<LightmapSettings>();
            UserData.RegisterType<LightProbeGroup>();
            UserData.RegisterType<LightProbeProxyVolume>();
            UserData.RegisterType<LightProbes>();
            UserData.RegisterType<LineRenderer>();
            UserData.RegisterType<LineUtility>();
            UserData.RegisterType<LocalizationAsset>();
            UserData.RegisterType<LOD>();
            UserData.RegisterType<LODGroup>();
            UserData.RegisterType<Material>();
            UserData.RegisterType<MaterialPropertyBlock>();
            UserData.RegisterType<Mathf>();
            UserData.RegisterType<Matrix4x4>();
            UserData.RegisterType<Mesh>();
            UserData.RegisterType<MeshCollider>();
            UserData.RegisterType<MeshFilter>();
            UserData.RegisterType<MeshRenderer>();
            UserData.RegisterType<ModifiableContactPair>();
            UserData.RegisterType<ModifiableMassProperties>();
            UserData.RegisterType<MonoBehaviour>();
            UserData.RegisterType<Motion>();
            UserData.RegisterType<NavMeshAgent>();
            UserData.RegisterType<UnityEngine.Object>();
            UserData.RegisterType<ParticleSystem>();
            UserData.RegisterType<Particle>();
            UserData.RegisterType<Physics>();
            UserData.RegisterType<Physics2D>();
            UserData.RegisterType<PhysicsMaterial2D>();
            UserData.RegisterType<Plane>();
            UserData.RegisterType<PlatformEffector2D>();
            UserData.RegisterType<Quaternion>();
            UserData.RegisterType<Ray>();
            UserData.RegisterType<Ray2D>();
            UserData.RegisterType<Rect>();
            UserData.RegisterType<RectTransform>();
            UserData.RegisterType<ReflectionProbe>();
            UserData.RegisterType<RenderTexture>();
            UserData.RegisterType<Renderer>();
            UserData.RegisterType<Rigidbody>();
            UserData.RegisterType<Rigidbody2D>();
            UserData.RegisterType<Shader>();
            UserData.RegisterType<Sprite>();
            UserData.RegisterType<SpriteRenderer>();
            UserData.RegisterType<SoftJointLimit>();
            UserData.RegisterType<TextAsset>();
            UserData.RegisterType<TextMesh>();
            UserData.RegisterType<Texture>();
            UserData.RegisterType<Texture2D>();
            UserData.RegisterType<Time>();
            UserData.RegisterType<TrailRenderer>();
            UserData.RegisterType<Transform>();
            UserData.RegisterType<Vector2>();
            UserData.RegisterType<Vector3>();
            UserData.RegisterType<Vector4>();
            UserData.RegisterType<VideoPlayer>();
            UserData.RegisterType<WheelCollider>();
            UserData.RegisterType<WheelJoint2D>();
            UserData.RegisterType<WindZone>();

        }

        public void RegisterSLZTypes()
        {
            UserData.RegisterType<Gun.HammerStates>();
            UserData.RegisterType<Attack>();
            UserData.RegisterType<SpawnDeathEvent>();
            UserData.RegisterType<SanityTester>();
            UserData.RegisterType<TextureStreamingSummary>();
            UserData.RegisterType<PosePredictionFeatureExample>();
            UserData.RegisterType<RefreshRateFeatureExample>();
            UserData.RegisterType<FadeVolume>();
            UserData.RegisterType<PlayerRemappingConfigurator>();
            UserData.RegisterType<DecalProjector>();
            UserData.RegisterType<Il2CppSLZ.VRMK.Avatar>();
            UserData.RegisterType<AvatarExtension>();
            UserData.RegisterType<Il2CppSLZ.Bonelab.Saveable>();
            UserData.RegisterType<AvatarGrip>();
            UserData.RegisterType<BarrelGrip>();
            UserData.RegisterType<BodyVirtualController>();
            UserData.RegisterType<BoxGrip>();
            UserData.RegisterType<MarrowEntityPoseDecorator>();
            UserData.RegisterType<CylinderGrip>();
            UserData.RegisterType<DualHingeVirtualController>();
            UserData.RegisterType<ForcePullGrip>();
            UserData.RegisterType<GenericGrip>();
            UserData.RegisterType<Grip>();
            UserData.RegisterType<Hand>();
            UserData.RegisterType<HandgunVirtualController>();
            UserData.RegisterType<HandReciever>();
            UserData.RegisterType<HingeVirtualController>();
            UserData.RegisterType<InteractableHost>();
            UserData.RegisterType<InteractableHostManager>();
            UserData.RegisterType<InteractionVolume>();
            UserData.RegisterType<InventoryHand>();
            UserData.RegisterType<InventoryHandReceiver>();
            UserData.RegisterType<InventorySlot>();
            UserData.RegisterType<InventorySlotReceiver>();
            UserData.RegisterType<LadderPlatform>();
            UserData.RegisterType<LadderVirtualController>();
            UserData.RegisterType<PumpShotgunVirtualController>();
            UserData.RegisterType<RifleVirtualController>();
            UserData.RegisterType<Servo>();
            UserData.RegisterType<SlideVirtualController>();
            UserData.RegisterType<SlotContainer>();
            UserData.RegisterType<SphereGrip>();
            UserData.RegisterType<StaticSlideVirtualController>();
            UserData.RegisterType<SwingVirtualController>();
            UserData.RegisterType<TargetGrip>();
            UserData.RegisterType<VirtualControllerOverride>();
            UserData.RegisterType<WeaponSlot>();
            UserData.RegisterType<WorldGrip>();
            UserData.RegisterType<AlignPlug>();
            UserData.RegisterType<AmmoPlug>();
            UserData.RegisterType<AmmoSocket>();
            UserData.RegisterType<DebugDraw>();
            UserData.RegisterType<LineMesh>();
            UserData.RegisterType<CameraSettings>();
            UserData.RegisterType<PlayerTriggerProxy>();
            UserData.RegisterType<Player_Health>();
            UserData.RegisterType<AmmoInventory>();
            UserData.RegisterType<Constrainer>();
            UserData.RegisterType<ConstraintTracker>();
            UserData.RegisterType<DevManipulatorGun>();
            UserData.RegisterType<FlyingGun>();
            UserData.RegisterType<GravityManipulatorJob>();
            UserData.RegisterType<Gun>();
            UserData.RegisterType<GunManager>();
            UserData.RegisterType<InventoryAmmoReceiver>();
            UserData.RegisterType<Magazine>();
            UserData.RegisterType<SlideMover>();
            UserData.RegisterType<BallisticPassthrough>();
            UserData.RegisterType<FirearmCartridge>();
            UserData.RegisterType<ImpactProperties>();
            UserData.RegisterType<ImpactPropertiesManager>();
            UserData.RegisterType<Projectile>();
            UserData.RegisterType<StabSlash>();
            UserData.RegisterType<Haptor>();
            UserData.RegisterType<Health>();
            UserData.RegisterType<Inventory>();
            UserData.RegisterType<PlayerDamageReceiver>();
            UserData.RegisterType<AnimationRig>();
            UserData.RegisterType<AnimInputRig>();
            UserData.RegisterType<ArtRig>();
            UserData.RegisterType<BaseController>();
            UserData.RegisterType<ControllerRig>();
            UserData.RegisterType<GameWorldSkeletonRig>();
            UserData.RegisterType<HeptaRig>();
            UserData.RegisterType<InterpRig>();
            UserData.RegisterType<MirrorControllerRig>();
            UserData.RegisterType<OpenController>();
            UserData.RegisterType<OpenControllerRig>();
            UserData.RegisterType<PhysicsRig>();
            UserData.RegisterType<PhysSoftBody>();
            UserData.RegisterType<PhysTorso>();
            UserData.RegisterType<RemapRig>();
            UserData.RegisterType<Il2CppSLZ.Marrow.Rig>();
            UserData.RegisterType<RigManager>();
            UserData.RegisterType<SkeletonHand>();
            UserData.RegisterType<CollisionSFX>();
            UserData.RegisterType<CollisionSfxManager>();
            UserData.RegisterType<GravGunSFX>();
            UserData.RegisterType<GunSFX>();
            UserData.RegisterType<HandSFX>();
            UserData.RegisterType<HeadSFX>();
            UserData.RegisterType<ImpactSFX>();
            UserData.RegisterType<ImpactSfxManager>();
            UserData.RegisterType<MotorSFX>();
            UserData.RegisterType<PrismaticSFX>();
            UserData.RegisterType<RollingSFX>();
            UserData.RegisterType<ShellSFX>();
            UserData.RegisterType<WindBuffetSFX>();
            UserData.RegisterType<Atv>();
            UserData.RegisterType<Seat>();
            UserData.RegisterType<ObjectDestructible>();
            UserData.RegisterType<ParticleSpread>();
            UserData.RegisterType<ParticleSpreadManager>();
            UserData.RegisterType<ParticleTint>();
            UserData.RegisterType<SpawnFragment>();
            UserData.RegisterType<SpawnFragmentArray>();
            UserData.RegisterType<TextureArrayApplicator>();
            UserData.RegisterType<CollisionCollector>();
            UserData.RegisterType<CollisionStay>();
            UserData.RegisterType<CollisionStaySensor>();
            UserData.RegisterType<HandPoseAnimator>();
            UserData.RegisterType<Mirror>();
            UserData.RegisterType<PhysGrounder>();
            UserData.RegisterType<PhysHand>();
            UserData.RegisterType<PhysLimb>();
            UserData.RegisterType<PlayerAvatarArt>();
            UserData.RegisterType<RealHeptaAvatar>();
            UserData.RegisterType<SLZ_Body>();
            UserData.RegisterType<TestContactMod>();
            UserData.RegisterType<ZoneTriggerNode>();
            UserData.RegisterType<RecycleDecorator>();
            UserData.RegisterType<SpawnDecorator>();
            UserData.RegisterType<Zone>();
            UserData.RegisterType<ZoneCuller>();
            UserData.RegisterType<ZoneGun>();
            UserData.RegisterType<CrateSpawnSequencer>();
            UserData.RegisterType<RandomizeCrate>();
            UserData.RegisterType<SceneChunk>();
            UserData.RegisterType<SpawnerToggle>();
            UserData.RegisterType<SpawnForce>();
            UserData.RegisterType<Zone3dSound>();
            UserData.RegisterType<ZoneAggro>();
            UserData.RegisterType<ZoneAmbience>();
            UserData.RegisterType<ZoneChunkLoader>();
            UserData.RegisterType<ZoneEnabler>();
            UserData.RegisterType<ZoneEvents>();
            UserData.RegisterType<ZoneItem>();
            UserData.RegisterType<ZoneLight>();
            UserData.RegisterType<ZoneLinkEvents>();
            UserData.RegisterType<ZoneLinkItem>();
            UserData.RegisterType<ZoneLoadLevel>();
            UserData.RegisterType<ZoneMusic>();
            UserData.RegisterType<ZoneOcclusion>();
            UserData.RegisterType<ZoneTriggerSource>();
            UserData.RegisterType<ZoneLink>();
            UserData.RegisterType<CrateSpawner>();
            UserData.RegisterType<CrateSpawnerGrid>();
            UserData.RegisterType<AddNode>();
            UserData.RegisterType<BaseNode>();
            UserData.RegisterType<ButtonNode>();
            UserData.RegisterType<CounterNode>();
            UserData.RegisterType<DivideNode>();
            UserData.RegisterType<EqualNode>();
            UserData.RegisterType<GreaterThanEqualNode>();
            UserData.RegisterType<GreaterThanNode>();
            UserData.RegisterType<LessThanEqualNode>();
            UserData.RegisterType<LessThanNode>();
            UserData.RegisterType<LeverNode>();
            UserData.RegisterType<MaxNode>();
            UserData.RegisterType<MemoryNode>();
            UserData.RegisterType<MinNode>();
            UserData.RegisterType<MultiplyNode>();
            UserData.RegisterType<PassthroughNode>();
            UserData.RegisterType<RatchetNode>();
            UserData.RegisterType<RemapNode>();
            UserData.RegisterType<SequencerNode>();
            UserData.RegisterType<SliderNode>();
            UserData.RegisterType<SubtractNode>();
            UserData.RegisterType<ToggleButtonNode>();
            UserData.RegisterType<ToggleNode>();
            UserData.RegisterType<XorNode>();
            UserData.RegisterType<DamageVolume>();
            UserData.RegisterType<EventAdapter>();
            UserData.RegisterType<LegacySoundPlayer>();
            UserData.RegisterType<LinearJoint>();
            UserData.RegisterType<MaterialSwitcher>();
            UserData.RegisterType<RotatingJoint>();
            UserData.RegisterType<TextAdapter>();
            UserData.RegisterType<ToneGenerator>();
            UserData.RegisterType<PowerSource>();
            UserData.RegisterType<TransformSensor>();
            UserData.RegisterType<VoidLogicSpawnExport>();
            UserData.RegisterType<VoidLogicSpawnImport>();
            UserData.RegisterType<VoidLogicSpawnInput>();
            UserData.RegisterType<VoidLogicSpawnOutput>();
            UserData.RegisterType<PlayerMarker>();
            UserData.RegisterType<SceneBootstrapper>();
            UserData.RegisterType<AnimationBlocker>();
            UserData.RegisterType<BehaviourBase>();
            UserData.RegisterType<BehaviourBaseNav>();
            UserData.RegisterType<BehaviourPuppet>();
            UserData.RegisterType<BreakJointOnPuppet>();
            UserData.RegisterType<JointBreakBroadcaster>();
            UserData.RegisterType<MuscleCollisionBroadcaster>();
            UserData.RegisterType<MuscleCollisionBroadcasterSensor>();
            UserData.RegisterType<Muscle>();
            UserData.RegisterType<Muscle.State>();
            UserData.RegisterType<PID_Controller>();
            UserData.RegisterType<PressureSensor>();
            UserData.RegisterType<PuppetMaster>();
            UserData.RegisterType<PuppetMasterSettings>();
            UserData.RegisterType<SkinnedBoneRebind>();
            UserData.RegisterType<AssetSpawner>();
            UserData.RegisterType<DespawnDelay>();
            UserData.RegisterType<Poolee>();
            UserData.RegisterType<SpawnEvents>();
            UserData.RegisterType<Authenticator>();
            UserData.RegisterType<AuthenticatorDock>();
            UserData.RegisterType<AuthenticatorDockDecorator>();
            UserData.RegisterType<Battery>();
            UserData.RegisterType<BatteryHolder>();
            UserData.RegisterType<BatteryHolderDecorator>();
            UserData.RegisterType<Il2CppSLZ.Marrow.Plug>();
            UserData.RegisterType<System.Net.Sockets.Socket>();
            UserData.RegisterType<LiteLoco>();
            UserData.RegisterType<TempSelectionBase>();
            UserData.RegisterType<MarrowBehaviour>();
            UserData.RegisterType<ObjectCleanupEvents>();
            UserData.RegisterType<ObjectCleanupVolume>();
            UserData.RegisterType<UtilitySpawnables>();
            UserData.RegisterType<LinkLateReferenceSubscriptions>();
            UserData.RegisterType<SceneExportTable>();
            UserData.RegisterType<ExportTable>();
            UserData.RegisterType<ArtCull>();
            UserData.RegisterType<MarrowBody>();
            UserData.RegisterType<Tracker>();
            UserData.RegisterType<MarrowEntity>();
            UserData.RegisterType<MarrowJoint>();
            UserData.RegisterType<OverlapStateHelper>();
            UserData.RegisterType<OverlapTrigger>();
            UserData.RegisterType<RigidbodySettings>();
            UserData.RegisterType<PolyLine>();
            UserData.RegisterType<Il2CppSLZ.Marrow.Interaction.SplineJoint>();
            UserData.RegisterType<XRUICursor>();
            UserData.RegisterType<XRUICursorReceiver>();
            UserData.RegisterType<ModIOManager>();
            UserData.RegisterType<VisualDamageController>();
            UserData.RegisterType<Actuator>();
            UserData.RegisterType<AngularVelocityActuator>();
            UserData.RegisterType<AngularXDriver>();
            UserData.RegisterType<EventActuator>();
            UserData.RegisterType<LinearXDriver>();
            UserData.RegisterType<MaterialSwitchActuator>();
            UserData.RegisterType<ActuatorSocket>();
            UserData.RegisterType<Circuit>();
            UserData.RegisterType<ActuatorSocketDecorator>();
            UserData.RegisterType<ButtonDecorator>();
            UserData.RegisterType<SwitchDecorator>();
            UserData.RegisterType<ExternalActuator>();
            UserData.RegisterType<ExternalCircuit>();
            UserData.RegisterType<AddCircuit>();
            UserData.RegisterType<FlipflopCircuit>();
            UserData.RegisterType<MultiplyCircuit>();
            UserData.RegisterType<RemapCircuit>();
            UserData.RegisterType<ValueCircuit>();
            UserData.RegisterType<XorCircuit>();
            UserData.RegisterType<AngularXSensor>();
            UserData.RegisterType<AngularYSensor>();
            UserData.RegisterType<AngularZSensor>();
            UserData.RegisterType<ButtonController>();
            UserData.RegisterType<CircuitSocket>();
            UserData.RegisterType<HingeController>();
            UserData.RegisterType<LinearXSensor>();
            UserData.RegisterType<SliderController>();
            UserData.RegisterType<ZoneCircuit>();
            UserData.RegisterType<BillOfMaterials>();
            UserData.RegisterType<BlueprintSpawner>();
            UserData.RegisterType<Audio2dManager>();
            UserData.RegisterType<Audio3dManager>();
            UserData.RegisterType<AudioPlayer>();
            UserData.RegisterType<FootstepSFX>();
            UserData.RegisterType<MusicAmbience2dSFX>();
            UserData.RegisterType<AIBrain>();
            UserData.RegisterType<AIManager>();
            UserData.RegisterType<Encounter>();
            UserData.RegisterType<EncounterMonitor>();
            UserData.RegisterType<RoamArea>();
            UserData.RegisterType<SlotPosition>();
            UserData.RegisterType<SpawnAgro>();
            UserData.RegisterType<SpawnAISettings>();
            UserData.RegisterType<TriggerRefProxy>();
            UserData.RegisterType<VoidLogicSubgraph>();
            UserData.RegisterType<VoidLogicManager>();
            UserData.RegisterType<TriggeredAudio>();
            UserData.RegisterType<AgentLinkControl>();
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


            if (Input.GetKeyDown(KeyCode.F5))
            {
                if (BoneLib.Player.LeftHand != null)
                {
                    Transform T = BoneLib.Player.LeftHand.transform;
                    API_GameObject.BL_SpawnByBarcode(BoneLib.CommonBarcodes.NPCs.Ford, T.position, T.rotation); 
                }
            }

            if (Input.GetKeyDown(KeyCode.F6))
            {
                GameObject Ford = GameObject.Find("NPC_Ford_BWOrig [0]");
                if (Ford != null)
                {
                    LuaNPC LG = Ford.GetComponent<AIBrain>().gameObject.AddComponent<LuaNPC>();
                }
                else
                {
                    LoggerInstance.Msg("No Ford located");
                }
            }

            if (Input.GetKeyDown(KeyCode.F8))
            {
               GameObject TestObject = new GameObject();
               TestObject.SetActive(false);
               TestObject.name = "TestObject";
               LineRenderer line = TestObject.AddComponent<LineRenderer>();
               line.numPositions = 5;
               Vector3[] pos = new Vector3[5];
               line.GetPositions(pos);
               TestObject.SetActive(true);
              
            }
        }

        public override void OnSceneWasInitialized(int buildIndex, string sceneName)
        {
            base.OnSceneWasInitialized(buildIndex, sceneName);
        }


        public override void OnInitializeMelon()
        {
       
        }


        public override void OnLateInitializeMelon()
        {
            API_GameObject.LoadAllAssemblies();
            LoadTypes();
            FieldInjector.SerialisationHandler.Inject<LuaBehaviour>();
            FieldInjector.SerialisationHandler.Inject<LuaGun>();
            FieldInjector.SerialisationHandler.Inject<LuaNPC>();
            FieldInjector.SerialisationHandler.Inject<LuaResources>();

            GameObject LuaMenu = new GameObject();
            GameObject.DontDestroyOnLoad(LuaMenu);
            LuaMenu.SetActive(false);
            LuaMenu.name = "LuaMenu";
            LuaBehaviour LuaMenuBehaviour = LuaMenu.AddComponent<LuaBehaviour>();
            LuaMenuBehaviour.ScriptName = ("TestBoneMenu.lua");
            LuaMenu.SetActive(true);
            
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