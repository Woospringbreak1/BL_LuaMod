using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Random
    {
        public static readonly API_Random Instance = new API_Random();

        public Vector3 BL_onUnitSphere()
        {
            return UnityEngine.Random.onUnitSphere;
        }
        public float BL_RandomRange(float min,float max)
        {
            return UnityEngine.Random.RandomRange(min,max);
        }

    }
}
