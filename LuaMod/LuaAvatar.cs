using Il2CppSLZ.Marrow;
using Il2CppSLZ.VRMK;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod
{
    internal class LuaAvatar : LuaBehaviour 
    {
        public Avatar AttachedAvatar;



        new public void Start()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            MelonLoader.MelonLogger.Msg("LUAGUN start function called");
            Magazine InsertedMag;
            //AttachedGun._magState.Refill()
            if (ScriptName == "" || ScriptName == null)
            {
                ScriptName = "TestAvatar.lua";
            }
            this.AttachedAvatar = this.gameObject.GetComponent<Avatar>();
            

            base.Start();
#endif
        }


#if !(UNITY_EDITOR || UNITY_STANDALONE)
        public LuaAvatar(IntPtr ptr) : base(ptr) { }
#endif

    }

}

