namespace LuaMod
{
    public static class ScriptManager
    {
        public static List<LuaModScript> ScriptList = new List<LuaModScript>(500);
       // static FileSystemWatcher fileSystemWatcher;
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
            ///reloading script not supported - reload scene for iterative development
            throw new NotImplementedException();
            foreach (LuaModScript script in ScriptList)
            {
                //
                // in future call serialize() then reload() then deserialize()
                //
              //  script.ReloadScript();
            }

        }

        public static void InitiateFileSystemMonitor()
        {
            throw new NotImplementedException();
          //  FileSystemWatcher fileSystemWatcher = new FileSystemWatcher();
          //  fileSystemWatcher.Path = "Mods\\LuaMod\\LuaScripts\\";
          //  fileSystemWatcher.Filter = "*.lua";
          //  fileSystemWatcher.IncludeSubdirectories = true;
          //  fileSystemWatcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite;


        }

    }
}
