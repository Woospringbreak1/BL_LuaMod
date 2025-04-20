

namespace LuaMod.LuaAPI
{

    public class API_Vector
    {

        public static readonly API_Vector Instance = new API_Vector();

        /// <summary>
        /// Creates a new Vector3
        /// </summary>
        public static UnityEngine.Vector3 BL_Vector3(float x, float y, float z)
        {
            return new UnityEngine.Vector3(x, y, z);
        }


        /// <summary>
        /// Creates a new Vector2
        /// </summary>
        public static UnityEngine.Vector3 BL_Vector2(float x, float y)
        {
            return new UnityEngine.Vector2(x, y);
        }

        /// <summary>
        /// Creates a new Vector4
        /// </summary>
        public static UnityEngine.Vector3 BL_Vector4(float x, float y, float z, float w)
        {
            return new UnityEngine.Vector4(x, y, z, w);
        }
    }
}
