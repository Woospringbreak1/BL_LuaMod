using Il2CppCysharp.Threading.Tasks;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Circuits;
using Il2CppSLZ.Marrow.Data;
using Il2CppSLZ.Marrow.LateReferences;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppSLZ.SFX;
using MelonLoader;
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    /// <summary>
    /// Lua-exposed API for modifying MeshRenderer materials.
    /// Supports getting, setting, and replacing materials from Lua scripts.
    /// Possibly redundant with array manipulation functions in API_Utils
    /// </summary>
    [MoonSharpUserData]
    public class API_Renderer
    {
        /// <summary>
        /// Singleton instance of the API_Renderer class.
        /// </summary>
        public static readonly API_Renderer Instance = new API_Renderer();

        /// <summary>
        /// Returns the number of materials on the given MeshRenderer.
        /// </summary>
        public static int BL_GetMaterialCount(MeshRenderer renderer)
        {
            return LuaSafeCall.Run(() =>
            {
                return (renderer != null && renderer.materials != null) ? renderer.materials.Length : 0;
            }, "BL_GetMaterialCount()");
        }

        /// <summary>
        /// Gets the material at the specified index (zero-based).
        /// </summary>
        public static DynValue BL_GetMaterialAt(MeshRenderer renderer, int index)
        {
            return LuaSafeCall.Run(() =>
            {
                if (renderer == null) throw new ScriptRuntimeException("MeshRenderer is null");
                var mats = renderer.materials;
                if (index >= 0 && index < mats.Length)
                    return UserData.Create(mats[index]);
                return DynValue.Nil;
            }, $"BL_GetMaterialAt(index: {index})");
        }

        /// <summary>
        /// Sets the material at the specified index (zero-based).
        /// </summary>
        public static void BL_SetMaterialAt(MeshRenderer renderer, int index, Material mat)
        {
            LuaSafeCall.Run(() =>
            {
                if (renderer == null) throw new ScriptRuntimeException("MeshRenderer is null");
                if (mat == null) throw new ScriptRuntimeException("Material is null");

                var mats = renderer.materials;
                if (index >= 0 && index < mats.Length)
                {
                    mats[index] = mat;
                    renderer.materials = mats;
                }
                else
                {
                    throw new ScriptRuntimeException("Invalid index {index}");
                }
            }, $"BL_SetMaterialAt(index: {index})");
        }

        /// <summary>
        /// Gets all materials on the MeshRenderer as a Lua table.
        /// </summary>
        public static Table BL_GetAllMaterials(Script script, MeshRenderer renderer)
        {
            return LuaSafeCall.Run(() =>
            {
                var t = new Table(script);
                if (renderer == null) return t;

                var mats = renderer.materials;
                for (int i = 0; i < mats.Length; i++)
                {
                    t[i + 1] = UserData.Create(mats[i]);
                }

                return t;
            }, "BL_GetAllMaterials()");
        }

        /// <summary>
        /// Sets all materials on the MeshRenderer using a Lua table.
        /// </summary>
        public static void BL_SetAllMaterials(MeshRenderer renderer, Table matTable)
        {
            LuaSafeCall.Run(() =>
            {
                if (renderer == null) throw new ScriptRuntimeException("MeshRenderer is null");
                if (matTable == null) throw new ScriptRuntimeException("Material table is null");

                int count = (int)matTable.Length;
                Material[] newMats = new Material[count];

                for (int i = 1; i <= count; i++)
                {
                    var val = matTable.Get(i);
                    if (val.Type != DataType.UserData || !(val.UserData.Object is Material mat))
                        throw new ScriptRuntimeException($"Invalid material at index {i}");
                    newMats[i - 1] = mat;
                }

                renderer.materials = newMats;
            }, "BL_SetAllMaterials()");
        }
    }
}
