
#if !(UNITY_EDITOR || UNITY_STANDALONE)
#endif

using MoonSharp.Interpreter;
using UnityEngine;

namespace LuaMod
{
    internal interface ISciptedObject
    {

        public void LoadBehaviourFunctionPointers();
        public bool SetupBehaviourFunctions();
        public bool ReloadScript();
        public bool LoadScript(TextAsset Script);
        public bool LoadScript(string Script);
        public bool CallFunction(string functionname, params DynValue[] args);
    }
}
