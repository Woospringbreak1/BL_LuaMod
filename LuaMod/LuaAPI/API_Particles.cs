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
    /// <summary>
    /// Lua-exposed API for working with Unity particle systems and trail segments. - not functional due to Melonloader bugs
    /// </summary>

    public class API_Particles
    {
        public static readonly API_Particles Instance = new API_Particles();

        /// <summary>
        /// Attempts to retrieve particle data from a Unity ParticleSystem.
        /// </summary>
        /// <param name="system">The ParticleSystem to extract particles from.</param>
        /// <param name="size">The number of particles to retrieve.</param>
        /// <param name="offset">The offset index to start reading particles.</param>
        /// <returns>An array of Particle objects if successful; null otherwise. Currently known to cause crashes.</returns>
        /// <remarks>
        /// Calling this method will result in a crash to desktop (CTD). A bug report is open with the MelonLoader team.
        /// </remarks>
        public static Particle[] BL_GetParticles(ParticleSystem system,int size,int offset)
        {

            MelonLogger.Warning("Calling GetParticles causes Crash To Desktop - bug report open with Melonloader team");
            return null;

            if (system == null)
            {
                MelonLogger.Error("BL_GetParticles - supplied particle system is null");
                return null;
            }

            Particle[] Pout = new Particle[size];

            system.GetParticles(Pout,size,offset);
            return Pout;
        }

        /// <summary>
        /// Creates a new array of Vector3s intended for storing trail segments.
        /// </summary>
        /// <param name="size">The size of the array.</param>
        /// <returns>An array of Vector3 initialized to zero.</returns
        public Vector3[] CreateTrailSegmentArray(int size)
        {
            return new Vector3[size];
        }

        private static Vector3[] trailsegments = new Vector3[500];


        /// <summary>
        /// Attempts to retrieve line segment positions from a Unity LineRenderer.
        /// </summary>
        /// <param name="LR">The LineRenderer component to read from.</param>
        /// <returns>DynValue containing the position data, or null if failed. Currently unstable.</returns>
        /// <remarks>
        ///  Calling this method will result in a crash to desktop (CTD). A bug report is open with the MelonLoader team.
        /// </remarks>
        public static DynValue BL_lineRenderer_GetPositions(LineRenderer LR)
        {
            MelonLogger.Warning("Calling GetPositionss causes Crash To Desktop - bug report open with Melonloader team");
            return null;
            
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
