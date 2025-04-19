#if !(UNITY_EDITOR || UNITY_STANDALONE)
using BoneLib;
using HarmonyLib;
using Il2CppSLZ.Interaction;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.Data;
using Il2CppSLZ.Marrow.Interaction;
using Il2CppSLZ.ModIO.ApiModels;
using LuaMod.LuaAPI;
using MelonLoader;
using MoonSharp.Interpreter;
using System.Runtime.CompilerServices;
using UnityEngine;
#else
using MoonSharp.Interpreter;
using SLZ.Marrow;
using SLZ.Marrow.Data;
#endif

namespace LuaMod
{



    public class LuaGun : LuaBehaviour
    {

#if !(UNITY_EDITOR || UNITY_STANDALONE)
        [HarmonyPatch(typeof(Gun), nameof(Gun.Fire))]
        private static class Patch_Gun_Fire
        {
            private static bool Prefix(Gun __instance)
            {
                LuaGun LG = __instance.gameObject.gameObject.GetComponent<LuaGun>();

                if (LG != null)
                {
                    //Lua gun
                    return (LG.LuaTriggerPulled());
                }
                else
                {
                    //normal gun
                    return true;
                }



            }

        }


        [HarmonyPatch(typeof(Gun), nameof(Gun.OnFire))]
        private static class Patch_Gun_OnFire
        {
            private static bool Prefix(Gun __instance)
            {
                LuaGun LG = __instance.gameObject.gameObject.GetComponent<LuaGun>();

                if (LG != null)
                {
                    //Lua Gun
                    MelonLoader.MelonLogger.Msg("Calling LuaGun Onfire()");
                    return (LG.OnFire());

                }
                else
                {
                    //Normal gun
                    MelonLoader.MelonLogger.Msg("Calling normal Gun Onfire()");
                    return true;
                }



            }
        }


        [HarmonyPatch(typeof(Gun), nameof(Gun.SpawnCartridge), new Type[] { typeof(Spawnable) })]
        private static class Patch_Gun_SpawnCartridge
        {
            private static bool Prefix(Gun __instance, Spawnable spawnableCartridge)
            {
                LuaGun LG = __instance.gameObject.GetComponent<LuaGun>();

                if (LG != null)
                {
                    // Lua Gun handling
                    MelonLoader.MelonLogger.Msg("Calling LuaGun SpawnCartridge() with cartridge: " + spawnableCartridge);
                    return (LG.LuaSpawnCartridge(spawnableCartridge));
                }

                // Normal gun handling (original method will execute)
                MelonLoader.MelonLogger.Msg("Calling normal Gun SpawnCartridge() with cartridge: " + spawnableCartridge);
                return true;
            }
        }

        [HarmonyPatch(typeof(Gun), nameof(Gun.OnGripAttached), new Type[] { typeof(InteractableHost),typeof(Hand) })]

        private static class Patch_Gun_OnGripAttached
        {
            private static bool Prefix(Gun __instance,InteractableHost host, Hand hand)
            {
                LuaGun LG = __instance.gameObject.GetComponent<LuaGun>();

                if (LG != null)
                {
                    LG.OnGripAttached(host, hand);
                    return true;
                }

                // Normal gun handling (original method will execute)
                MelonLoader.MelonLogger.Msg("Calling normal Gun OnGripAttached() with Interactable Host : " + host.ToString() + " and hand " + hand.ToString());
                return true;
            }
        }



#endif



        public Gun AttachedGun;
        public SlideVirtualController AttachedGunSlide;
        public bool SupressBullet = true; // don't actually fire a bullet

        MoonSharp.Interpreter.DynValue TriggerPulledFunction;
        MoonSharp.Interpreter.DynValue OnFireFunction;
        MoonSharp.Interpreter.DynValue SpawnCartridgeFunction;

        MoonSharp.Interpreter.DynValue OnMagazineEjectFunction;
        MoonSharp.Interpreter.DynValue OnSlideGrabbedFunction;
        MoonSharp.Interpreter.DynValue OnSlideReleasedFunction;
        MoonSharp.Interpreter.DynValue OnSlideUpdateFunction;
        MoonSharp.Interpreter.DynValue OnGripAttachedFunction;


        new public void Start()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            Magazine InsertedMag;
           //AttachedGun._magState.Refill()
            if (ScriptName == "" || ScriptName == null)
            {
                ScriptName = "Spiderman_WebShooter.lua";
            }
           
            this.AttachedGun = this.gameObject.GetComponent<Gun>();
            this.AttachedGunSlide = this.gameObject.GetComponent<SlideVirtualController>();

            AttachedGun.OnMagazineEjectDelegate += (Il2CppSystem.Action)OnMagizineEjected;
            AttachedGun.OnSlideGrabbed += (Il2CppSystem.Action)OnSlideGrabbed;
            AttachedGun.OnSlideReleased += (Il2CppSystem.Action)OnSlideReleased;
            AttachedGun.OnSlideUpdate += (Il2CppSystem.Action<float>)OnSlideUpdate;

           


            base.Start();
#endif
        }

        public void OnGripAttached(InteractableHost host, Hand hand)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnGripAttachedFunction,host,hand);
#endif
        }

        public void OnMagizineEjected()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnMagazineEjectFunction);
#endif
        }

        public void OnSlideGrabbed()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnSlideGrabbedFunction);
#endif
        }
        public void OnSlideReleased()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnSlideReleasedFunction);
#endif
        }

        public void OnSlideUpdate(float pos)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnSlideUpdateFunction,pos);
#endif
        }

        public override bool SetupBehaviourFunctions()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            base.SetupBehaviourFunctions();
            if (BehaviourScript != null)
            {
                TriggerPulledFunction = BehaviourScript.GetGlobal("TriggerPulled");
                OnFireFunction = BehaviourScript.GetGlobal("OnFire");
                SpawnCartridgeFunction = BehaviourScript.GetGlobal("SpawnCartridge");

                OnMagazineEjectFunction = BehaviourScript.GetGlobal("OnMagazineEject");
                OnSlideGrabbedFunction = BehaviourScript.GetGlobal("OnSlideGrabbed");
                OnSlideReleasedFunction = BehaviourScript.GetGlobal("OnSlideReleased");
                OnSlideUpdateFunction = BehaviourScript.GetGlobal("OnSlideUpdate");
                OnGripAttachedFunction = BehaviourScript.GetGlobal("OnGripAttached");

                return true;
            }
            else
            {
                return false;
            }
#endif
            return false;
        }
        
        public DynValue GetFirepointPosition()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if(AttachedGun != null)
            {
                return UserData.Create(AttachedGun.firePointTransform);
            }
            return DynValue.Nil;
#endif
            return null;
        }

        public DynValue GetMagazineRounds()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if(AttachedGun != null)
            {
                if(AttachedGun.internalMagazine != null)
                {
                    return DynValue.NewNumber(AttachedGun.AmmoCount());
                }
            }
            return DynValue.Nil;
#endif
            return null;
        }

        public bool SetMagazineRounds(int rounds)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (AttachedGun != null)
            {
                if (AttachedGun.internalMagazine != null)
                {
                    int currentRounds = AttachedGun._magState.AmmoCount;
                    int dif = (rounds - currentRounds);

                    if (dif > 0)
                    {
                        AttachedGun._magState.AddCartridge(dif);
                    }
                    else if (dif < 0)
                    {
                        //dif is negitive.
                        AttachedGun._magState.ClearMagazine();
                        AttachedGun._magState.AddCartridge(rounds);
                     
                        return true;
                    }
                    
                    return true;
                }
            }
            return false;
#endif
            return false;
        }

        public bool ForceGunFire()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if(AttachedGun != null)
            {
                AttachedGun.Fire();
                return true;
            }
            return false;
#endif
            return false;
        }

        public bool OnFire()
        {
            ///Note: OnFire generates the bullet - return false to prevent bullet firing
            //still generates muzzleflash etc.

#if !(UNITY_EDITOR || UNITY_STANDALONE)
            MelonLoader.MelonLogger.Msg("OnFire called");
            DynValue FireReturn = CallScriptFunction(OnFireFunction);

            if(FireReturn != null&& FireReturn != DynValue.Nil && FireReturn.Type == DataType.Boolean)
            {
                return FireReturn.Boolean;
            }
#endif
            return !SupressBullet;
        }

        public bool LuaTriggerPulled()
        {
            ///Note: TriggerPulled is called every frame when the trigger is held down
            ///regardless of magazine status, bullet chambered etc.

#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(TriggerPulledFunction);
#endif
            return true;
        }

        public bool LuaSpawnCartridge(Spawnable spawnableCartridge)
        {
            ///Note: ??
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            MelonLoader.MelonLogger.Msg("Cardrige barcode: " + spawnableCartridge.crateRef.Barcode.ToString() + " " + spawnableCartridge.crateRef.ToString());
            CallScriptFunction(SpawnCartridgeFunction);
#endif
            return false;
        }

        /*
        public bool IsSlidePulled()
        {
            if(AttachedGunSlide != null)
            {
                return AttachedGunSlide._slideIsPulled;
            }
            return false;
        }
        */


#if !(UNITY_EDITOR || UNITY_STANDALONE)
        public LuaGun(IntPtr ptr) : base(ptr) { }
#endif

    }
}

