using UnityEngine;
using MoonSharp.Interpreter;
using System;

#if !(UNITY_EDITOR || UNITY_STANDALONE)
using Il2CppSLZ.Marrow;
using Il2CppSystem.Xml;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Il2CppInterop.Runtime;
using MelonLoader;
using Il2CppInterop.Runtime.Injection;
using static Il2Cpp.Interop;
using System.Windows.Input;
using BoneLib.BoneMenu.UI;
using BoneLib;
using System.Reflection;
using Il2CppInterop.Runtime.Attributes;
using HarmonyLib;
#else
using SLZ.Marrow;
#endif

namespace LuaMod
{
    public class LuaGun2 : Gun//, ISciptedObject
    {
        /*
        public string ScriptName; // set in unity editor
        public TextAsset ScriptAsset;

#if !(UNITY_EDITOR || UNITY_STANDALONE)

        LuaModScript BehaviourScript;

        MoonSharp.Interpreter.DynValue StartFunction;
        MoonSharp.Interpreter.DynValue UpdateFunction;
        MoonSharp.Interpreter.DynValue FixedUpdateFunction;

        MoonSharp.Interpreter.DynValue OnEnableFunction;
        MoonSharp.Interpreter.DynValue OnDisableFunction;
        MoonSharp.Interpreter.DynValue OnDestroyFunction;


#endif


        void Start()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            BehaviourScript = new LuaModScript();

            if (ScriptAsset != null)
            {
                LoadScript(ScriptAsset);
            }
            else if (ScriptName != null && ScriptName != "")
            {
                LoadScript("Mods\\LuaMod\\LuaScripts\\" + ScriptName);
            }

            LoadBehaviourFunctionPointers();


            if (StartFunction != null)
            {
                BehaviourScript.LuaScript.Call(StartFunction);
            }

           // base.Start();
#endif


        }


        void OnEnable()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (OnEnableFunction != null)
            {
                BehaviourScript.LuaScript.Call(OnEnableFunction);
            }
           
#endif
        }

        void OnDisable()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (OnDisableFunction != null)
            {
                BehaviourScript.LuaScript.Call(OnDisableFunction);
            }

#endif
        }


        void OnDestroy()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (OnDestroyFunction != null)
            {
                BehaviourScript.LuaScript.Call(OnDestroyFunction);
            }
            BehaviourScript.DestroyScript();
            BehaviourScript = null;
           // base.OnDestroy();
#endif

        }

        // Update is called once per frame
        void Update()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (UpdateFunction != null)
            {
                try
                {
                    BehaviourScript.LuaScript.Globals["BL_deltaTime"] = Time.deltaTime;
                    BehaviourScript.LuaScript.Call(UpdateFunction);
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLoader.MelonLogger.Error("Doh! An error occured! " + ex.DecoratedMessage);
                    //   throw;
                }

            }
            //base.Update();
#endif

        }

        void FixedUpdate()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (FixedUpdateFunction != null && FixedUpdateFunction != DynValue.Nil)
            {
                BehaviourScript.LuaScript.Call(FixedUpdateFunction);
            }

#endif
      
        }



        */


        /* 
        public override void Fire()
        {
            base.Fire();
        }

      public override int AmmoCount()
      {
          return 0;
          // return base.AmmoCount();
      }

      public override bool HasMagazine()
      {
          return false;
         // return base.HasMagazine();
      }

      public override void OnFire()
      {
        //  base.OnFire();
      }

      public override void OnTriggerGripAttached(Hand hand)
      {
         // base.OnTriggerGripAttached(hand);
      }

      public override void OnTriggerGripDetached(Hand hand)
      {
          //base.OnTriggerGripDetached(hand);
      }

      public override void Awake()
      {
          //base.Awake();
      }

      public override void Reset()
      {
        //  base.Reset();
      }


            */

        /*

        public void LoadBehaviourFunctionPointers()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            BehaviourScript.LuaScript.Globals["BL_Host"] = this.gameObject;
#endif
        }

        public bool LoadScript(TextAsset Script)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (BehaviourScript.LoadScript(Script, false))
            {
                SetupBehaviourFunctions();
                LoadBehaviourFunctionPointers();
                BehaviourScript.PostReloadScript = new LuaModScript.del_postreload(ReloadScript);
                return true;
            }
            else
            {
                //throw exception
                MelonLoader.MelonLogger.Msg("Lua Behaviour asset not found or invalid!");
                return false;
            }
#endif
            return false;
        }
        public bool LoadScript(string Script)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (BehaviourScript.LoadScript(Script, false))
            {
                SetupBehaviourFunctions();
                LoadBehaviourFunctionPointers();
                BehaviourScript.PostReloadScript = new LuaModScript.del_postreload(ReloadScript);
                return true;
            }
            else
            {
                //throw exception
                MelonLoader.MelonLogger.Msg("Lua Behaviour script not found!");
                return false;
            }
#endif
            return false;
        }

        public bool ReloadScript()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            MelonLoader.MelonLogger.Msg("running reload on LuaBehaviour " + this.gameObject.name);
            SetupBehaviourFunctions();
            LoadBehaviourFunctionPointers();
            //reload parameter directory?
            return true;
#endif
            return false;
        }

        public bool SetupBehaviourFunctions()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null)
            {
                StartFunction = BehaviourScript.LuaScript.Globals.Get("Start");
                UpdateFunction = BehaviourScript.LuaScript.Globals.Get("Update");
                FixedUpdateFunction = BehaviourScript.LuaScript.Globals.Get("FixedUpdate");

                OnEnableFunction = BehaviourScript.LuaScript.Globals.Get("OnEnable");
                OnDisableFunction = BehaviourScript.LuaScript.Globals.Get("OnDisable");
                OnDestroyFunction = BehaviourScript.LuaScript.Globals.Get("OnDestroy");
                return true;
            }
            else
            {
                return false;
            }
#endif
            return false;
        }

        public bool CallFunction(string functionname, DynValue[] args)
        {

#if !(UNITY_EDITOR || UNITY_STANDALONE)

            MelonLoader.MelonLogger.Error("don't call me");

#endif
            return false;
           // throw new NotImplementedException();
        }
        */

    }
}
