using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using MoonSharp.Interpreter;
using System.Globalization;
using MelonLoader;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppSLZ.Marrow;
namespace LuaMod.LuaAPI
{
    
 /// <summary>
/// Provides Lua-accessible file operations such as opening and checking for file existence.
/// </summary>
/// <remarks>
/// Use this API to safely interact with the file system from Lua scripts. File paths are validated to prevent unauthorized access outside the mod sandbox.
///
/// Files opened with <see cref="BL_OpenFile(string)"/> return a <see cref="BLFileAccess"/> object for reading or writing contents.
/// </remarks>
    public class API_FileAccess
    {
        public static readonly API_FileAccess Instance = new API_FileAccess();



        /// <summary>
        /// Opens a file at the specified path and returns a <see cref="BLFileAccess"/> object
        /// for interacting with it.
        /// </summary>
        /// <param name="name">The relative path to the file.</param>
        /// <returns>A BLFileAccess object if the path is safe; throws an exception otherwise.</returns>
        public static BLFileAccess BL_OpenFile(string name)
        {
            return LuaSafeCall.Run(() =>
            {
                string RelativePath = Security.GetRelativePath(name);
                if (Security.IsSafePath(RelativePath))
                {
                    return new BLFileAccess(name);
                }
                else
                {
                    throw new ScriptRuntimeException($"Attempted to access an unsafe path " + RelativePath );
                }    

                return null;
            }, $"BL_OpenFile('{name}')");
        }

        /// <summary>
        /// Determines whether a file exists at the specified relative path within the mod's sandbox.
        /// </summary>
        /// <param name="name">The relative file path to check.</param>
        /// <returns>Returns <c>true</c> if the file exists and the path is safe; otherwise, <c>false</c>. Throws an exception if the path is unsafe.</returns>
        public static bool BL_FileExists(string name)
        {
            CrateSpawner sp;

            return LuaSafeCall.Run(() =>
            {
                string RelativePath = Security.GetRelativePath(name);
                if (Security.IsSafePath(RelativePath))
                {
                    return File.Exists(RelativePath);
                }
                else
                {
                    throw new ScriptRuntimeException($"Attempted to access an unsafe path " + RelativePath);
                }
            }, $"BL_DoesFileExist('{name}')");
        }

    }
}
