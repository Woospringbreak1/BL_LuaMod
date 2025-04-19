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

        /// <summary>
        /// Luabehaviour variant for attaching to avatars. unless someone finds something interesting to bind this will be removed
        /// </summary>

        new public void Start()
        {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
       
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

