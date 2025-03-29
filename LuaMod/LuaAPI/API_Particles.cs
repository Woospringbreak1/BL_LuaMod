using Il2CppInterop.Runtime.InteropTypes.Arrays;
using Il2CppVoxelization;
using MelonLoader;
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using static UnityEngine.ParticleSystem;

namespace LuaMod.LuaAPI
{
    internal class API_Particles
    {
        public static readonly API_Particles Instance = new API_Particles();
        public static void BL_GetParticles(ParticleSystem system,int size,int offset)
        {

            if (system == null)
            {
                MelonLogger.Error("BL_GetParticles - supplied particle system is null");
                return;
            }

            Particle[] Pout = new Particle[size];

            system.GetParticles(Pout,size,offset);
            //return Pout;
           return;
        }
        
        public Vector3[] CreateTrailSegmentArray(int size)
        {
            return new Vector3[size];
        }

        private static Vector3[] trailsegments = new Vector3[500];
        public static DynValue BL_lineRenderer_GetPositions(LineRenderer LR)
        {
            //Il2CppStructArray<Vector3> Pos = new Il2CppStructArray<Vector3>(LR.positionCount);

            int i = 0;
            while (i < 500)
            {
                trailsegments[i] = Vector3.zero;
                i++;
            }

            if (LR == null)
            {
                MelonLogger.Error("BL_lineRenderer_GetPositions - supplied line renderer is null");
                return null;
            }

            //Vector3[] LineSegments = new Vector3[LR.numPositions];
            LR.GetPositions(trailsegments);

            return null;//UserData.Create(LineSegments);
        }
    }
}
