using LuaMod.LuaAPI;
using MelonLoader;
using System;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;

namespace LuaMod
{
    internal static class Security
    {
        private static readonly string scriptsRoot;
        private static readonly string resourcesRoot;

        static Security()
        {
            string modDir = Path.GetDirectoryName(GetBonelabAddress());
            scriptsRoot = Path.GetFullPath(Path.Combine(modDir,"LuaMod", "LuaScripts"));
            resourcesRoot = Path.GetFullPath(Path.Combine(modDir,"LuaMod", "Resources"));
        }

        /// <summary>
        /// Gets the location of the executing mod DLL (Bonelab Mods folder).
        /// </summary>
        public static string GetBonelabAddress()
        {
            return Assembly.GetExecutingAssembly().Location;
        }

        public static bool IsLuaScript(string filename)
        {
            if (string.IsNullOrWhiteSpace(filename))
                return false;

            try
            {
                // Normalize path and filename
                string sanitized = Path.GetFullPath(filename);
                string extension = Path.GetExtension(sanitized);

                // Basic check: only allow ".lua", case-insensitive
                if (!string.Equals(extension, ".lua", StringComparison.OrdinalIgnoreCase))
                    return false;

                // Reject suspicious filenames like "script.lua.exe" or "script.lua.txt"
                string nameOnly = Path.GetFileName(sanitized);
                if (Regex.IsMatch(nameOnly, @"\.lua\.", RegexOptions.IgnoreCase))
                    return false;

                // Optionally: disallow any null bytes or control characters
                if (nameOnly.IndexOf('\0') >= 0 || Regex.IsMatch(nameOnly, @"[\x00-\x1F]"))
                    return false;

                return true;
            }
            catch
            {
                // If path resolution fails or any exception is thrown, treat as unsafe
                return false;
            }
        }

        public static bool IsResourceFile(string filename)
        {
            if (string.IsNullOrWhiteSpace(filename))
                return false;

            try
            {
                string sanitized = Path.GetFullPath(filename);
                string extension = Path.GetExtension(sanitized);

                // Allow only .txt or .json (case-insensitive)
                if (!extension.Equals(".txt", StringComparison.OrdinalIgnoreCase) &&
                    !extension.Equals(".json", StringComparison.OrdinalIgnoreCase))
                    return false;

                string nameOnly = Path.GetFileName(sanitized);

                // Reject misleading filenames like config.json.exe or readme.txt.bat
                if (Regex.IsMatch(nameOnly, @"\.(txt|json)\.", RegexOptions.IgnoreCase))
                    return false;

                // Disallow null bytes or control characters
                if (nameOnly.IndexOf('\0') >= 0 || Regex.IsMatch(nameOnly, @"[\x00-\x1F]"))
                    return false;

                return true;
            }
            catch
            {
                return false;
            }
        }

        public static string GetRelativePath(string filename)
        {
            string sanitizedFilename = filename.TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            string outpath = Path.GetFullPath(Path.Combine(resourcesRoot, sanitizedFilename));
            return outpath;
        }

        public static string GetRelativeScriptPath(string filename)
        {
            
            string sanitizedFilename = filename.TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            string outpath = Path.GetFullPath(Path.Combine(scriptsRoot, sanitizedFilename));
            return API_Utils.RemoveDoubleSlashes(outpath);
        }

        /// <summary>
        /// Determines whether the given path is safe (inside Scripts/ or Resources/ and not symlinked).
        /// </summary>
        public static bool IsSafePath(string path)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(path))
                {
                    MelonLogger.Warning($"empty path: {path}");
                    return false;
                }


                string fullPath = Path.GetFullPath(path);

                // Block shortcut files - do shortcuts work like this? may not be worth bothering with
                if (fullPath.EndsWith(".lnk", StringComparison.OrdinalIgnoreCase))
                {
                    MelonLogger.Warning($"Blocked shortcut: {fullPath}");
                    return false;
                }

                // Ensure path is within one of the approved root directories
                if (!fullPath.StartsWith(scriptsRoot, StringComparison.OrdinalIgnoreCase) &&
                    !fullPath.StartsWith(resourcesRoot, StringComparison.OrdinalIgnoreCase))
                {
                    return false;
                }

                // Check for symlinks, junctions, mount points
                if (PathContainsSymlink(fullPath))
                {
                    MelonLogger.Warning($"Blocked symlink/junction/mount in path: {fullPath}");
                    return false;
                }

                return true;
            }
            catch (Exception ex)
            {
                MelonLogger.Warning($"[Security] Exception in IsSafePath: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Checks whether any part of the path is a reparse point (symlink, mount, or junction).
        /// </summary>
        private static bool PathContainsSymlink(string fullPath)
        {
            DirectoryInfo dir = new DirectoryInfo(fullPath);
            while (dir != null && dir.Exists)
            {
                if (IsReparsePoint(dir))
                    return true;

                dir = dir.Parent;
            }
            return false;
        }

        private static bool IsReparsePoint(DirectoryInfo dir)
        {
            return (dir.Attributes & FileAttributes.ReparsePoint) != 0;
        }
    }
}
