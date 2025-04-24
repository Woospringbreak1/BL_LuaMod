
//using Il2CppSLZ.Marrow.Utilities;
//
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Security;
using UnityEngine;
using UnityEngine.ProBuilder.MeshOperations;






#if !(UNITY_EDITOR || UNITY_STANDALONE)
using MelonLoader;
#endif

namespace LuaMod
{


#if !(UNITY_EDITOR || UNITY_STANDALONE)
    //[RegisterTypeInIl2Cpp]  //handled by FieldInjector
#endif
    public class LuaBehaviour : MonoBehaviour//, ISciptedObject
    {
        /// <summary>
        /// The name of the Lua script file (used if ScriptAsset is null).
        /// </summary>
        public string ScriptName; 

        /// <summary>
        /// A Unity TextAsset that contains the Lua script.
        /// </summary
        public TextAsset ScriptAsset;

        /// <summary>
        /// The interval at which the SlowUpdate function is called in seconds.
        /// </summary>
        public float SlowUpdateTime = 0.5f;


        /// <summary>
        /// Optional list of tags associated with this Lua Behaviour.
        /// </summary>
        public List<String> ScriptTags;

        /// <summary>
        /// Indicates whether this LuaBehaviour is initialized and ready.
        /// </summary>
        public bool Ready = false;

        

#if !(UNITY_EDITOR || UNITY_STANDALONE)

        public LuaModScript BehaviourScript;
        protected MoonSharp.Interpreter.DynValue StartFunction;
        protected MoonSharp.Interpreter.DynValue LateStartFunction;
        protected MoonSharp.Interpreter.DynValue UpdateFunction;
        protected MoonSharp.Interpreter.DynValue FixedUpdateFunction;
        protected MoonSharp.Interpreter.DynValue AwakeFunction;

        protected MoonSharp.Interpreter.DynValue OnEnableFunction;
        protected MoonSharp.Interpreter.DynValue OnDisableFunction;
        protected MoonSharp.Interpreter.DynValue OnDestroyFunction;
        protected MoonSharp.Interpreter.DynValue OnCollisionEnterFunction;
        protected MoonSharp.Interpreter.DynValue OnCollisionExitFunction;
        protected MoonSharp.Interpreter.DynValue OnCollisionStayFunction;
        protected MoonSharp.Interpreter.DynValue SlowUpdateFunction;
        protected MoonSharp.Interpreter.DynValue LateUpdateFunction;
        protected MoonSharp.Interpreter.DynValue OnTriggerEnterFunction;
        protected MoonSharp.Interpreter.DynValue OnTriggerExitFunction;
        protected MoonSharp.Interpreter.DynValue OnTriggerStayFunction;
        protected MoonSharp.Interpreter.DynValue OnBecameInvisibleFunction;
        protected MoonSharp.Interpreter.DynValue OnBecameVisibleFunction;
        protected MoonSharp.Interpreter.DynValue OnParticleSystemStoppedFunction;
        protected MoonSharp.Interpreter.DynValue OnParticleCollisionFunction;
        protected MoonSharp.Interpreter.DynValue OnParticleTriggerFunction;
        protected MoonSharp.Interpreter.DynValue OnParticleUpdateJobScheduledFunction;
        protected MoonSharp.Interpreter.DynValue OnTransformChildrenChangedFunction;
        protected MoonSharp.Interpreter.DynValue OnTransformParentChangedFunction;
        protected MoonSharp.Interpreter.DynValue OnJointBreakFunction;
      


#endif


        [MoonSharpHidden]
        public void LoadBehaviourFunctionPointers()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

#endif
        }
        [MoonSharpHidden]
        public void Start()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            BehaviourScript = new LuaModScript();
            bool ScriptLoaded = false;

            if (ScriptName != "" && LoadScript(Security.GetRelativeScriptPath(ScriptName)))
            {
                ScriptLoaded = true;
            }
            else if (ScriptAsset != null && LoadScript(ScriptAsset))
            {
                ScriptLoaded = true;
            }

            if (!ScriptLoaded)
            {
                MelonLogger.Warning("No Valid script for LuaBehaviour " + this.name);
                Ready = false;
                return;
            }

            CallScriptFunction(StartFunction);

            if (SlowUpdateFunction != null && SlowUpdateFunction != DynValue.Nil)
            {
                SetSlowUpdate(true, SlowUpdateTime);
            }


            if (LateStartFunction != null && LateStartFunction != DynValue.Nil)
            {
                this.Invoke("LateStart",1.5f);
            }


#endif 
            Ready = true;
        }


        public void SetSlowUpdate(bool running, float time)
        {
            float invoketime = Mathf.Max(time, 0.1f);
            this.SlowUpdateTime = invoketime;

            CancelInvoke("SlowUpdate");

            if (running)
            {
                InvokeRepeating("SlowUpdate", UnityEngine.Random.Range(0f, 3.0f * invoketime), invoketime);
            }
        }


        [MoonSharpHidden]
        void OnTriggerEnter(Collider othercol)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnTriggerEnterFunction, othercol);
#endif
        }
        [MoonSharpHidden]
        void OnTriggerExit(Collider othercol)
        {
        #if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnTriggerExitFunction, othercol);
        #endif
        }

        [MoonSharpHidden]
        void OnTriggerStay(Collider othercol)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnTriggerStayFunction, othercol);
#endif
        }
        [MoonSharpHidden]
        void LateStart()
        {
        #if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(LateStartFunction);
        #endif
        }
        [MoonSharpHidden]
        void LateUpdate()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(LateUpdateFunction);
#endif
        }

        [MoonSharpHidden]
        void OnBecameInvisible()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnBecameInvisibleFunction);
#endif
        }

        [MoonSharpHidden]
        void OnBecameVisible()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnBecameVisibleFunction);
#endif
        }

        [MoonSharpHidden]
        void SlowUpdate()
        {
        #if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (!Ready || !BehaviourScript.ScriptIsValid())
            {
                return;
            }

        
            CallScriptFunction(SlowUpdateFunction);
        #endif
        }

        [MoonSharpHidden]
        void OnEnable()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnEnableFunction);
#endif
        }
        [MoonSharpHidden]
        void OnDisable()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnDisableFunction);
#endif
        }
        [MoonSharpHidden]
        void Awake()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(AwakeFunction);
#endif
        }

        [MoonSharpHidden]
        void OnDestroy()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnDestroyFunction);
            BehaviourScript.DestroyScript();
            BehaviourScript = null;

#endif
        }

        [MoonSharpHidden]
        void Update()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(UpdateFunction);
#endif
        }
        [MoonSharpHidden]
        void FixedUpdate()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(FixedUpdateFunction);
#endif
        }
        [MoonSharpHidden]
        void OnCollisionEnter(UnityEngine.Collision collision)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnCollisionEnterFunction, collision);
#endif
        }
        [MoonSharpHidden]
        void OnCollisionExit(UnityEngine.Collision collision)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnCollisionExitFunction, collision);
#endif
        }
        [MoonSharpHidden]
        void OnCollisionStay(UnityEngine.Collision collision)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnCollisionStayFunction, collision);
#endif
        }
        void OnOnJointBreak(float breakForce)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnJointBreakFunction, breakForce);
#endif
        }

        [MoonSharpHidden]
        void OnParticleCollision(GameObject other)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnParticleCollisionFunction, other);
#endif
        }
        [MoonSharpHidden]
        void OnParticleSystemStopped()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnParticleSystemStoppedFunction);
#endif
        }
        [MoonSharpHidden]
        void OnParticleTrigger()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnParticleTriggerFunction);
#endif
        }
        [MoonSharpHidden]
        void OnParticleUpdateJobScheduled()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnParticleUpdateJobScheduledFunction);
#endif
        }
        [MoonSharpHidden]
        void OnTransformChildrenChanged()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnTransformChildrenChangedFunction);
#endif
        }
        [MoonSharpHidden]
        void OnTransformParentChanged()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnTransformParentChangedFunction);
#endif
        }



        [MoonSharpHidden]
        public DynValue CallScriptFunction(DynValue DyFunc,params object[] Args)
        {
            
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (DyFunc == null || DyFunc.Type == DataType.Nil || DyFunc.Type == DataType.Void || BehaviourScript == null || !BehaviourScript.ScriptIsValid())
            {
                return null;
            }

            return LuaSafeCall.Run(() =>
            {
                try
                {
                    return BehaviourScript.CallScriptFunction(DyFunc, Args);
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLogger.Warning($"[CallScriptFunction] Exception when calling {DyFunc.Function.ToString()} on '{this.name}' (script: {ScriptName})");
                    MelonLogger.Error(ex.DecoratedMessage);
                    throw;
                }
            }, $"CallScriptFunction(type: {DyFunc?.Type}, value: {DyFunc?.ToString() ?? "nil"}) on '{this.name}'");
#else
    return null;
#endif
        }

        public void SetScriptVariable(string name, DynValue DyVar)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null && BehaviourScript.ScriptIsValid() && DyVar != null)
            {
                LuaSafeCall.Run(() =>
                {
                    BehaviourScript.SetGlobal(name,DyVar);
                }, $"SetScriptVariable('{name}')");
            }
            else
            {
                MelonLogger.Warning("attempting to set script variable failed " +  name + " " + DyVar.ToString() + " " + "BehaviourScript not null " + (BehaviourScript != null) + " script valid: " + BehaviourScript.ScriptIsValid());
            }
#endif
        }

        public DynValue GetScriptVariable(string name)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            return LuaSafeCall.Run(() =>
            {
                if (BehaviourScript != null && BehaviourScript.ScriptIsValid())
                {
                    DynValue val = BehaviourScript.GetGlobal(name);
                    if (val == null || val.Type == DataType.Nil || val.Type == DataType.Void)
                    {
                        MelonLogger.Warning($"[GetScriptVariable] Variable '{name}' is nil or missing on script '{ScriptName}' (object: '{this.name}')");
                        return DynValue.Nil;
                    }

                    return val;
                }
                else
                {
                    MelonLogger.Warning($"[GetScriptVariable] Cannot access variable '{name}' - BehaviourScript is null or invalid on object '{this.name}'");
                    return DynValue.Nil;
                }
            }, $"GetScriptVariable('{name}')");
#else
    return DynValue.Nil;
#endif
        }


        [MoonSharpHidden]
        public bool CallScriptFunctionDynamic(DynValue DyFunc, params object[] Args)
        {
            //call a script function - errors do not interupt script, just print and returns success/failure
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null && DyFunc != null && DyFunc != DynValue.Nil)
            {
                try
                {
                    BehaviourScript.CallScriptFunction(DyFunc, Args);
                    return true;
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLoader.MelonLogger.Error("An error occurred! " + ex.DecoratedMessage);
                    return false;
                }
            }
            MelonLoader.MelonLogger.Error("Error when calling function " + DyFunc.ToPrintString() + " " + BehaviourScript.ToString());
            return false;
#endif
            return false;
        }



        [MoonSharpHidden]
        public virtual bool SetupBehaviourFunctions()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null)
            {
                StartFunction = BehaviourScript.GetGlobal("Start");
                LateStartFunction = BehaviourScript.GetGlobal("LateStart");
                UpdateFunction = BehaviourScript.GetGlobal("Update");
                LateUpdateFunction = BehaviourScript.GetGlobal("LateUpdate");
                FixedUpdateFunction = BehaviourScript.GetGlobal("FixedUpdate");
                AwakeFunction = BehaviourScript.GetGlobal("Awake");

                OnEnableFunction = BehaviourScript.GetGlobal("OnEnable");
                OnDisableFunction = BehaviourScript.GetGlobal("OnDisable");
                OnDestroyFunction = BehaviourScript.GetGlobal("OnDestroy");

                OnCollisionEnterFunction = BehaviourScript.GetGlobal("OnCollisionEnter");
                OnCollisionExitFunction = BehaviourScript.GetGlobal("OnCollisionExit");
                OnCollisionStayFunction = BehaviourScript.GetGlobal("OnCollisionStay");

                SlowUpdateFunction = BehaviourScript.GetGlobal("SlowUpdate");
                OnTriggerEnterFunction = BehaviourScript.GetGlobal("OnTriggerEnter");
                OnTriggerExitFunction = BehaviourScript.GetGlobal("OnTriggerExit");
                OnTriggerStayFunction = BehaviourScript.GetGlobal("OnTriggerStay");
                OnJointBreakFunction = BehaviourScript.GetGlobal("OnJointBreak");
                OnParticleSystemStoppedFunction = BehaviourScript.GetGlobal("OnParticleSystemStopped");
                OnTransformChildrenChangedFunction = BehaviourScript.GetGlobal("OnTransformChildrenChanged");
                OnTransformParentChangedFunction = BehaviourScript.GetGlobal("OnTransformParentChanged");
                OnBecameInvisibleFunction = BehaviourScript.GetGlobal("OnBecameInvisible");
                OnBecameVisibleFunction = BehaviourScript.GetGlobal("OnBecameVisible");
                OnParticleCollisionFunction = BehaviourScript.GetGlobal("OnParticleCollision");
                OnParticleTriggerFunction = BehaviourScript.GetGlobal("OnParticleTrigger");
                OnParticleUpdateJobScheduledFunction = BehaviourScript.GetGlobal("OnParticleUpdateJobScheduled");
                return true;
            }
            else
            {
                return false;
            }
#endif
            return false;
        }
        [MoonSharpHidden]
        public bool ReloadScript()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            MelonLoader.MelonLogger.Msg("running reload on LuaBehaviour " + this.gameObject.name);
            SetupBehaviourFunctions();
            //reload parameter directory?
            return true;
#endif
            return false;
        }
        [MoonSharpHidden]
        public bool LoadScript(TextAsset Script)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (BehaviourScript.LoadScript(Script, false,this))
            {
                ScriptAsset = Script;
                SetupBehaviourFunctions();
                BehaviourScript.PostReloadScript = new LuaModScript.del_postreload(ReloadScript);
                return true;
            }
            else
            {
                //throw exception
                MelonLoader.MelonLogger.Msg("Lua Behaviour asset not found, blocked, or invalid! " + Script.name);
                return false;
            }
#endif
            return false;
        }
        [MoonSharpHidden]
        public bool LoadScript(string Script)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (BehaviourScript.LoadScript(Script, false,this))
            {
               //ScriptName = Script;
                SetupBehaviourFunctions();
                BehaviourScript.PostReloadScript = new LuaModScript.del_postreload(ReloadScript);
                return true;
            }
            else
            {
                //throw exception
                MelonLoader.MelonLogger.Msg(this.name + " " + "Lua Behaviour script not found or blocked! " + Script);
                return false;
            }
#endif
            return false;
        }


        public void CallFunctionULTEvent(string functionname,int param1, float param2,string param3,UnityEngine.Object param4 )
        {
            ///Simple CallFunction for ULTEvent use - maybe be possible to use the generic version by abusing the inspector debug mode.
            ///Param4 will need to be cast using API_Utils.BL_ConvertObjectToType()
            DynValue p1 = DynValue.NewNumber(param1);
            DynValue p2 = DynValue.NewNumber(param2);
            DynValue p3 = DynValue.NewString(param3);
            DynValue p4;
            if (param4 != null)
            {
                p4 = UserData.Create(param4);
            }
            else
            {
                p4 = DynValue.Nil;
            }

            CallFunction(functionname, p1, p2, p3,p4);
        }

        public bool CallFunction(string functionname, params DynValue[] args)
        {
            ///called from lua scripts, doesn't throw exceptions on missing functions.
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            return LuaSafeCall.Run(() =>
            {
                if (BehaviourScript == null || !BehaviourScript.ScriptIsValid())
                {
                    MelonLogger.Warning($"[CallFunction] Script is invalid or null when calling '{functionname}' on '{this.name}'");
                    return false;
                }

                DynValue scriptfunc = BehaviourScript.GetGlobal(functionname);

                if (scriptfunc == null || scriptfunc == DynValue.Nil)
                {
                    MelonLogger.Warning($"[CallFunction] Lua function '{functionname}' is nil or missing on '{this.name}'");
                    return false;
                }

                return CallScriptFunctionDynamic(scriptfunc, args);
            }, $"CallFunction('{functionname}')");
#else
    return false;
#endif
        }



#if !(UNITY_EDITOR || UNITY_STANDALONE)
        [MoonSharpHidden]
        public LuaBehaviour(IntPtr ptr) : base(ptr) { }
#endif

    }
}
