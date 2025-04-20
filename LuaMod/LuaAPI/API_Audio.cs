using Il2CppSLZ.Marrow.Audio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Audio;
using static Il2CppSLZ.SFX.SimpleSFX;

namespace LuaMod.LuaAPI
{
    /// <summary>
    /// Lua-exposed API for playing sounds. Stub, use AudioSources etc.
    /// </summary>
    public class API_Audio
    {
        public static readonly API_Audio Instance = new API_Audio();

        public bool BL_Play3DOneShot(AudioClip Clip,Vector3 position,float volume = 1,float pitch = 1, float spatialBlend = 1)
        {
            BoneLib.Audio.Play2DOneShot(Clip, BoneLib.Audio.SoftInteraction, volume, pitch);
            return true;
        }

    }
}
