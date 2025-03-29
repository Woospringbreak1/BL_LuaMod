
//using Il2CppSLZ.Marrow.Utilities;
//
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Security;
using UnityEngine;




#if !(UNITY_EDITOR || UNITY_STANDALONE)
using MelonLoader;
#endif

namespace LuaMod
{


#if !(UNITY_EDITOR || UNITY_STANDALONE)
    //[RegisterTypeInIl2Cpp]  //handled by FieldInjector
#endif
    public class LuaBehaviour : MonoBehaviour, ISciptedObject
    {
        public string ScriptName; // set in unity editor
        public TextAsset ScriptAsset;
        public float SlowUpdateTime = 0.5f;
        public List<String> ScriptTags;
        public bool Ready = false;
        public UnityEngine.Object[] Resources;
        

#if !(UNITY_EDITOR || UNITY_STANDALONE)

        protected LuaModScript BehaviourScript;
        protected MoonSharp.Interpreter.DynValue StartFunction;
        protected MoonSharp.Interpreter.DynValue LateStartFunction;
        protected MoonSharp.Interpreter.DynValue UpdateFunction;
        protected MoonSharp.Interpreter.DynValue FixedUpdateFunction;

        protected MoonSharp.Interpreter.DynValue OnEnableFunction;
        protected MoonSharp.Interpreter.DynValue OnDisableFunction;
        protected MoonSharp.Interpreter.DynValue OnDestroyFunction;
        protected MoonSharp.Interpreter.DynValue OnCollisionFunction;
        protected MoonSharp.Interpreter.DynValue SlowUpdateFunction;
        protected MoonSharp.Interpreter.DynValue OnTriggerEnterFunction;

#endif



        public void LoadBehaviourFunctionPointers()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            BehaviourScript.LuaScript.Globals["BL_Host"] = this.gameObject;
            BehaviourScript.LuaScript.Globals["BL_This"] = this;
#endif
        }

        public void Start()
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

           // LoadBehaviourFunctionPointers();

            CallScriptFunction(StartFunction);

            if(SlowUpdateFunction != null && SlowUpdateFunction != DynValue.Nil)
            {
                float invoketime = SlowUpdateTime;
                if (invoketime <= 0.1f)
                {
                    invoketime = 0.1f;
                }
                this.InvokeRepeating("SlowUpdate",UnityEngine.Random.RandomRange(0,3.0f*invoketime),invoketime);
            }


            if (LateStartFunction != null && LateStartFunction != DynValue.Nil)
            {
                this.Invoke("LateStart",1.5f);
            }


#endif 
            Ready = true;
        }
        void OnTriggerEnter(Collider othercol)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnTriggerEnterFunction, othercol);
#endif
        }

        void LateStart()
        {
        #if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(LateStartFunction);
        #endif
        }

        void SlowUpdate()
        {
        #if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(SlowUpdateFunction);
        #endif
        }


        void OnEnable()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnEnableFunction);
#endif
        }

        void OnDisable()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnDisableFunction);
#endif
        }


        public DynValue CallScriptFunction(DynValue DyFunc)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null && DyFunc != null && DyFunc != DynValue.Nil)
            {
                try
                {
                    return(BehaviourScript.LuaScript.Call(DyFunc));
                }
                catch (ScriptRuntimeException ex)
                {

                    MelonLoader.MelonLogger.Warning("exception when calling " + DyFunc.ToString() + " by object " + this.name + " script name " + ScriptName);  
                    MelonLoader.MelonLogger.Error("An error occured! " + ex.DecoratedMessage);
                    throw;
                    
                }
            }
#endif
            return null;

        }

        public void SetScriptVariable(string name,DynValue DyVar)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null && DyVar != null)
            {
                try
                {
                    BehaviourScript.LuaScript.Globals[name] = DyVar;
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLoader.MelonLogger.Error("An error occurred! " + ex.DecoratedMessage);
                    throw;
                }
            }
#endif
        }

        public void CallScriptFunction(DynValue DyFunc, params object[] Args)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null && DyFunc != null && DyFunc != DynValue.Nil)
            {
                try
                {
                    BehaviourScript.LuaScript.Call(DyFunc, Args);
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLoader.MelonLogger.Error("An error occurred! " + ex.DecoratedMessage);
                    throw;
                }
            }
#endif
        }

        public bool CallScriptFunctionDynamic(DynValue DyFunc, params object[] Args)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if (BehaviourScript != null && DyFunc != null && DyFunc != DynValue.Nil)
            {
                try
                {
                    BehaviourScript.LuaScript.Call(DyFunc, Args);
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





        void OnDestroy()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnDestroyFunction);
            BehaviourScript.DestroyScript();
            BehaviourScript = null;

#endif
        }

        // Update is called once per frame
        void Update()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (BehaviourScript != null && BehaviourScript.LuaScript != null)
            {
                BehaviourScript.LuaScript.Globals["BL_deltaTime"] = Time.deltaTime;
                
                CallScriptFunction(UpdateFunction);
            }
#endif
        }

        void FixedUpdate()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(FixedUpdateFunction);
#endif
        }

        void OnCollisionEnter(UnityEngine.Collision collision)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            CallScriptFunction(OnCollisionFunction, collision);
#endif
        }

        public virtual bool SetupBehaviourFunctions()
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

                OnCollisionFunction = BehaviourScript.LuaScript.Globals.Get("OnCollisionEnter");

                SlowUpdateFunction = BehaviourScript.LuaScript.Globals.Get("SlowUpdate");
                OnTriggerEnterFunction = BehaviourScript.LuaScript.Globals.Get("OnTriggerEnter");
                return true;
            }
            else
            {
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

        public bool LoadScript(TextAsset Script)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            if (BehaviourScript.LoadScript(Script, false))
            {
                ScriptAsset = Script;
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
                ScriptName = Script;
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

        public bool CallFunction(string functionname, params DynValue[] args)
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            if(BehaviourScript == null || BehaviourScript.LuaScript == null)
            {
                MelonLogger.Error("Attempted to call function on LuaBehaviour with null BehaviourScript " + functionname + " against " + this.name);
                return false;
            }

           DynValue scriptfunc = BehaviourScript.LuaScript.Globals.Get(functionname);

            if(scriptfunc == null || scriptfunc == DynValue.Nil)
            {
                MelonLogger.Error("Attempted to call invalid function " + functionname + " against " + this.name);
            }

           return(CallScriptFunctionDynamic(scriptfunc,args));
#endif
            return false;
        }

        public List<DynValue> GetScriptTags()
        { 

            List<DynValue> luaArray = new List<DynValue>();
            foreach (string tag in ScriptTags)
            {
                luaArray.Add(DynValue.NewString(tag));
            }

            return luaArray;


        }


#if !(UNITY_EDITOR || UNITY_STANDALONE)
        public LuaBehaviour(IntPtr ptr) : base(ptr) { }
#endif

    }
}
