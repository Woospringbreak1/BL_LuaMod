using MoonSharp.Interpreter;

namespace LuaMod.LuaAPI
{
    internal class API_Event
    {

        public static readonly API_Event Instance = new API_Event();

        public static bool SubscribeEvent(string Event, LuaModScript Sciptholder, DynValue func)
        {
            return false;
        }

    }
}
