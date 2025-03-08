using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Vector
    {

        public static readonly API_Vector Instance = new API_Vector();

        public static UnityEngine.Vector3 BL_Vector3(float x, float y, float z)
        {  
            return new UnityEngine.Vector3(x, y, z);
        }

    }
}
