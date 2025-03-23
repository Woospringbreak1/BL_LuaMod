using Il2CppPuppetMasta;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.PuppetMasta;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod
{
    internal class LuaNPC : LuaBehaviour
    {

        MoonSharp.Interpreter.DynValue OnDeathFunction;
        MoonSharp.Interpreter.DynValue OnResurrectionFunction;

        public AIBrain AttachedNPCBrain;
        public BehaviourBaseNav AttachedNPCBehaviour;
        public PuppetMaster AttachedPuppetMaster;
        new public void Start()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            MelonLoader.MelonLogger.Msg("LUA AI start function called");
            
            
            if (ScriptName == "" || ScriptName == null)
            {
                ScriptName = "PetNullbody.lua";
            }
            this.AttachedNPCBrain = this.gameObject.GetComponent<AIBrain>();
            this.AttachedNPCBehaviour = AttachedNPCBrain.behaviour;
            this.AttachedPuppetMaster = AttachedNPCBrain.puppetMaster;
            //AttachedNPCBehaviour.navTarget
            //AttachedNPCBehaviour.SetAgro(TriggerRefProxy)

                        
            AttachedNPCBrain.onDeathDelegate += new Action<AIBrain>(OnAIBrainDeath);
            AttachedNPCBrain.onResurrectDelegate += new Action<AIBrain>(OnAIBrainResurrect);
            AttachedNPCBehaviour.SwitchLocoState(BehaviourBaseNav.LocoState.Walking, 0, true);
            AttachedNPCBehaviour.SwitchMentalState(BehaviourBaseNav.MentalState.Roam);

            base.Start();
#endif
        }

        private void OnAIBrainDeath(AIBrain aIBrain)
        {
            MelonLoader.MelonLogger.Msg("AI Brain is dead");
            CallScriptFunction(OnDeathFunction);

        }

        private void OnAIBrainResurrect(AIBrain aIBrain)
        {
            MelonLoader.MelonLogger.Msg("AI Brain is dead");
            CallScriptFunction(OnResurrectionFunction);
        }


        public override bool SetupBehaviourFunctions()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)

            base.SetupBehaviourFunctions();

            if (BehaviourScript != null)
            {
                OnDeathFunction = BehaviourScript.LuaScript.Globals.Get("OnDeath");
                OnResurrectionFunction = BehaviourScript.LuaScript.Globals.Get("OnResurrection");
             
                return true;
            }
            else
            {
                return false;
            }
#endif
            return false;
        }


#if !(UNITY_EDITOR || UNITY_STANDALONE)
        public LuaNPC(IntPtr ptr) : base(ptr) { }
#endif
    }
}
