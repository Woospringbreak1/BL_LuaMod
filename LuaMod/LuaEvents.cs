using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod
{
    internal class LuaEvents
    {
        // Define a C# event for button presses
        public static event Action ButtonPressed;

        // Function to trigger the event (simulate button press)
        public static void TriggerButtonPress()
        {
            ButtonPressed?.Invoke();
        }

        // Function to let Lua subscribe to the event
        public static void SubscribeToButtonPress(DynValue luaFunction, Script script)
        {
            if (luaFunction.Type == DataType.Function)
            {
                // Attach event to call the Lua function when triggered
                ButtonPressed += () => script.Call(luaFunction);
            }
        }
    }
}
