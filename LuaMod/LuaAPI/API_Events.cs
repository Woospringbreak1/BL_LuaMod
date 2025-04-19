using HarmonyLib;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Combat;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.Combat;
using Il2CppSLZ.Marrow.Utilities;
using MoonSharp.Interpreter;
using System.Runtime.CompilerServices;

using UnityEngine.Events;
using UnityEngine.UIElements;

namespace LuaMod.LuaAPI
{

    public struct EventListner
    {
        public string function;
        public LuaBehaviour owner;
    }

    /// <summary>
    /// NOTE: THIS CLASS PROBABLY A MEMORY LEAK - NEED TO DESTROY SCRIPT REFERENCES WHEN DESTROYED
    /// </summary>

    public class API_Events
    {

        [HarmonyPatch(typeof(PlayerDamageReceiver), "ReceiveAttack")]
        private static class Patch_Player_OnReceiveDamage
        {
            private static bool Prefix(Health __instance,Attack attack)
            {
                BL_InvokeEvent("Player_OnReceiveDamage", UserData.Create(attack));
                return true;

            }

        }

        [HarmonyPatch(typeof(ObjectDestructible), "ReceiveAttack")]
        private static class Patch_ObjectDestructible_OnReceiveDamage
        {
            private static bool Prefix(ObjectDestructible __instance, Attack attack)
            {
                BL_InvokeEvent("Object_OnReceiveDamage", UserData.Create(__instance),  UserData.Create(attack));
                return true;

            }

        }


        static API_Events()
        {
            SetUpEvents();
        }



        public static readonly API_Events Instance = new API_Events();
        public static Dictionary<string, List<EventListner>> EventListeners = new Dictionary<string, List<EventListner>>();
        
        
        
        
        public static bool BL_SubscribeEvent(UnityEvent Uevent, LuaBehaviour Owner, string func)
        {
            
            return true;
        }



        private bool UnityEvent(UnityEvent Uevent)
        {
           
            return true;
        }



        public static bool BL_SubscribeEvent(string eventName, LuaBehaviour Owner, string func)
        {
            List<EventListner> ListenerList;

            if (!EventListeners.ContainsKey(eventName))
            {
                ListenerList = new List<EventListner>();
            }
            else
            {
                ListenerList = EventListeners[eventName];
            }
           
           // MelonLoader.MelonLogger.Msg("adding " + Owner.name + " to listner list for " + eventName);

            EventListner EL = new EventListner();
            EL.owner = Owner;
            EL.function = func;
            ListenerList.Add(EL);

            EventListeners[eventName] = ListenerList;
            return true;
        }

        public static bool BL_InvokeEvent(string eventName,params DynValue[] args )
        {
            //MelonLoader.MelonLogger.Msg("attempting to invoke event " + eventName);
            if (!EventListeners.ContainsKey(eventName))
            {
               // MelonLoader.MelonLogger.Msg("invoking event " + eventName + " failed, no listners");
               return false;
            }

            List<EventListner> ListenerList = EventListeners[eventName];

            foreach (EventListner Ls in ListenerList)
            {
                if (Ls.owner != null && Ls.function != "")
                {
                 //   MelonLoader.MelonLogger.Msg("invoking event " + eventName + " against " + Ls.owner.name);
                    Ls.owner.CallFunction(Ls.function,args);
                }
            }
           
            return true;
        }


        public static void SetUpEvents()
        {
            BoneLib.Hooking.OnPlayerDeath += Event_Hooking_OnPlayerDeath;
            BoneLib.Hooking.OnPlayerDeathImminent += Event_Hooking_OnPlayerDeathImminent;
            BoneLib.Hooking.OnGrabObject += Event_Hooking_OnGrabObject;
            BoneLib.Hooking.OnGripAttached += Event_Hooking_OnGripAttached;
            BoneLib.Hooking.OnGripDetached += Event_Hooking_OnGripDetached;
            //BoneLib.Hooking.OnLevelLoaded += Event_Hooking_OnLevelLoaded;
            BoneLib.Hooking.OnMarrowGameStarted += Event_Hooking_OnMarrowGameStarted;
            BoneLib.Hooking.OnNPCBrainDie += Event_Hooking_OnNPCBrainDie;
            BoneLib.Hooking.OnNPCBrainResurrected += Event_Hooking_OnNPCBrainResurrected;
            BoneLib.Hooking.OnNPCKillEnd += Event_Hooking_OnNPCKillEnd;
            BoneLib.Hooking.OnNPCKillStart += Evemt_Hooking_OnNPCKillStart;
            BoneLib.Hooking.OnPostFireGun += Event_Hooking_OnPostFireGun;
            BoneLib.Hooking.OnPreFireGun += Event_Hooking_OnPreFireGun;
            BoneLib.Hooking.OnReleaseObject += Event_Hooking_OnReleaseObject;
            BoneLib.Hooking.OnSwitchAvatarPostfix += Event_Hooking_OnSwitchAvatarPostfix;
            BoneLib.Hooking.OnSwitchAvatarPrefix += Event_Hooking_OnSwitchAvatarPrefix;
            BoneLib.Hooking.OnUIRigCreated += Event_Hooking_OnUIRigCreated;
            BoneLib.Hooking.OnWarehouseReady += Event_Hooking_OnWarehouseReady;

            BoneLib.BoneMenu.FloatElement.OnValueChanged += Event_FloatElement_OnValueChanged;
            BoneLib.BoneMenu.Dialog.OnDialogClosed += Event_Dialog_OnDialogClosed;

        
        }

        private static void Event_Dialog_OnDialogClosed(BoneLib.BoneMenu.Dialog obj)
        {
            BL_InvokeEvent("BoneMenu_Dialog_OnDialogClosed", UserData.Create(obj));
        }

        private static void Event_FloatElement_OnValueChanged(BoneLib.BoneMenu.Element arg1, float arg2)
        {
            BL_InvokeEvent("BoneMenu_Float_OnValueChanged",UserData.Create(arg1),DynValue.NewNumber(arg2));
        }

        private static void Event_Hooking_OnWarehouseReady()
        {
            BL_InvokeEvent("OnWarehouseReady");
        }

        private static void Event_Hooking_OnUIRigCreated()
        {
            BL_InvokeEvent("OnUIRigCreated");
        }

        private static void Event_Hooking_OnSwitchAvatarPrefix(Il2CppSLZ.VRMK.Avatar obj)
        {
            BL_InvokeEvent("OnSwitchAvatarPostfix", UserData.Create(obj));
        }

        private static void Event_Hooking_OnSwitchAvatarPostfix(Il2CppSLZ.VRMK.Avatar obj)
        {
            BL_InvokeEvent("OnSwitchAvatarPostfix", UserData.Create(obj));
        }

        private static void Event_Hooking_OnReleaseObject(Hand obj)
        {
            BL_InvokeEvent("OnPreFireGun", UserData.Create(obj));
        }

        private static void Event_Hooking_OnPreFireGun(Gun obj)
        {
            BL_InvokeEvent("OnPreFireGun", UserData.Create(obj));
        }

        private static void Event_Hooking_OnPostFireGun(Gun obj)
        {
            BL_InvokeEvent("OnPostFireGun", UserData.Create(obj));
        }

        private static void Evemt_Hooking_OnNPCKillStart(Il2CppSLZ.Marrow.PuppetMasta.BehaviourBaseNav obj)
        {
            BL_InvokeEvent("OnNPCKillStart", UserData.Create(obj));
        }

        private static void Event_Hooking_OnNPCKillEnd(Il2CppSLZ.Marrow.PuppetMasta.BehaviourBaseNav obj)
        {
            BL_InvokeEvent("OnNPCKillEnd", UserData.Create(obj));
        }

        private static void Event_Hooking_OnNPCBrainResurrected(Il2CppSLZ.Marrow.AI.AIBrain obj)
        {
            BL_InvokeEvent("OnNPCBrainResurrected", UserData.Create(obj));
        }

        private static void Event_Hooking_OnNPCBrainDie(Il2CppSLZ.Marrow.AI.AIBrain obj)
        {
            BL_InvokeEvent("OnNPCBrainDie", UserData.Create(obj));
        }

        private static void Event_Hooking_OnMarrowGameStarted()
        {
            BL_InvokeEvent("OnMarrowGameStarted");
        }

        private static void Event_Hooking_OnGripDetached(Grip arg1, Hand arg2)
        {
            BL_InvokeEvent("OnGripDetached", UserData.Create(arg1), UserData.Create(arg2));
        }

        private static void Event_Hooking_OnGripAttached(Grip arg1, Hand arg2)
        {
            BL_InvokeEvent("OnGripAttached", UserData.Create(arg1), UserData.Create(arg2));
        }

        private static void Event_Hooking_OnGrabObject(UnityEngine.GameObject arg1, Hand arg2)
        {
            BL_InvokeEvent("OnGrabObject",UserData.Create(arg1),UserData.Create(arg2));
        }

        private static void Event_Hooking_OnPlayerDeath()
        {
            BL_InvokeEvent("OnPlayerDeath");
        }

        private static void Event_Hooking_OnPlayerDeathImminent(bool IsDying)
        {
            BL_InvokeEvent("OnPlayerDeathImminent", DynValue.NewBoolean(IsDying));
        }
    }
}
