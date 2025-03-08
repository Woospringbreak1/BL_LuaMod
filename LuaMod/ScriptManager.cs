using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod
{
    public static class ScriptManager
    {
        public static List<LuaModScript> ScriptList = new List<LuaModScript>(500);
        static FileSystemWatcher fileSystemWatcher;
        public static void RegisterScript(LuaModScript script)
        {
            ScriptList.Add(script);
        }


        public static void DeregisterScript(LuaModScript script)
        {
            ScriptList.Remove(script);
        }

        public static void ReloadScripts()
        {
            foreach (LuaModScript script in ScriptList)
            {
                //
                // in future call serialize() then reload() then deserialize()
                //
                script.ReloadScript();
            }

        }

        public static void InitiateFileSystemMonitor()
        {
            FileSystemWatcher fileSystemWatcher = new FileSystemWatcher();
            fileSystemWatcher.Path = "Mods\\LuaMod\\LuaScripts\\";
            fileSystemWatcher.Filter = "*.lua";
            fileSystemWatcher.IncludeSubdirectories = true;
            fileSystemWatcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite;


        }

    }
}
