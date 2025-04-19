using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod
{
    public static class LuaSafeCall
    {
        public static T Run<T>(Func<T> func, string context = "Unknown")
        {
            try
            {
                return func();
            }
            catch (ScriptRuntimeException ex)
            {
                MelonLoader.MelonLogger.Error($"[MoonSharp Error - {context}]\n{ex.DecoratedMessage}");
                throw; // rethrow so MoonSharp still sees it
            }
            catch (Exception ex)
            {
                var wrapped = new ScriptRuntimeException($"[C# Exception in {context}] {ex.GetType().Name}: {ex.Message}");
                MelonLoader.MelonLogger.Error(wrapped.DecoratedMessage);
                throw wrapped;
            }
        }

        public static void Run(Action action, string context = "Unknown")
        {
            try
            {
                action();
            }
            catch (ScriptRuntimeException ex)
            {
                MelonLoader.MelonLogger.Error($"[MoonSharp Error - {context}]\n{ex.DecoratedMessage}");
                throw;
            }
            catch (Exception ex)
            {
                var wrapped = new ScriptRuntimeException($"[C# Exception in {context}] {ex.GetType().Name}: {ex.Message}");
                MelonLoader.MelonLogger.Error(wrapped.DecoratedMessage);
                throw wrapped;
            }
        }
    }

}
