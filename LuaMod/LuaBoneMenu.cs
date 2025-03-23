using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod
{
    internal class LuaBoneMenu : LuaBehaviour
    {
#if !(UNITY_EDITOR || UNITY_STANDALONE)
        public LuaBoneMenu(IntPtr ptr) : base(ptr) { }
#endif
    }
}
