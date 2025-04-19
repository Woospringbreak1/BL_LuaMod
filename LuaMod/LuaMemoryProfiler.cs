using MoonSharp.Interpreter;
using System.Collections.Generic;
using System.Text;
using System.Linq;

namespace LuaMod
{


    public static class LuaMemoryProfiler
    {
        public static string ScriptMemoryReport(Script script, Dictionary<string, DynValue> loadedModules)
        {
            var visitedTables = new HashSet<Table>();
            var moduleBreakdown = new Dictionary<string, long>();

            long total = 0;

            foreach (var pair in loadedModules)
            {
                long modSize = EstimateValue(pair.Value, visitedTables);
                moduleBreakdown[pair.Key] = modSize;
                total += modSize;
            }

            // Include top-level global variables not in loadedModules
            long uncategorized = 0;
            foreach (var pair in script.Globals.Pairs)
            {
                string key = pair.Key.ToPrintString();
                if (!loadedModules.ContainsKey(key))
                {
                    uncategorized += EstimateValue(pair.Value, visitedTables);
                }
            }

            total += uncategorized;

            // Build the report
            var sb = new StringBuilder();
            sb.AppendLine("---- Lua Memory Usage by Module ----");
            foreach (var mod in moduleBreakdown.OrderByDescending(kv => kv.Value))
            {
                sb.AppendLine($"{mod.Key}: {mod.Value} bytes (~{mod.Value / 1024.0:F2} KB)");
            }

            sb.AppendLine($"[Other Globals]: {uncategorized} bytes (~{uncategorized / 1024.0:F2} KB)");
            sb.AppendLine("-------------------------------------");
            sb.AppendLine($"Total estimated memory: {total} bytes (~{total / 1024.0:F2} KB)");
            sb.AppendLine($"Visited {visitedTables.Count} unique tables.");
            return sb.ToString();
        }

        private static long EstimateValue(DynValue val, HashSet<Table> visited)
        {
            switch (val.Type)
            {
                case DataType.String:
                    return Encoding.UTF8.GetByteCount(val.String);

                case DataType.Number:
                    return 8;

                case DataType.Boolean:
                    return 1;

                case DataType.Table:
                    return EstimateTable(val.Table, visited);

                case DataType.Function:
                case DataType.ClrFunction:
                    return 64;

                case DataType.UserData:
                    return 64;

                default:
                    return 0;
            }
        }

        public static float EstimateMemoryMB(Script script, Dictionary<string, DynValue> loadedModules)
        {
            var visitedTables = new HashSet<Table>();
            long total = 0;

            foreach (var pair in loadedModules)
            {
                total += EstimateValue(pair.Value, visitedTables);
            }

            foreach (var pair in script.Globals.Pairs)
            {
                string key = pair.Key.ToPrintString();
                if (!loadedModules.ContainsKey(key))
                {
                    total += EstimateValue(pair.Value, visitedTables);
                }
            }

            return total / (1024f * 1024f); // Convert bytes to MB as float
        }

        private static long EstimateTable(Table table, HashSet<Table> visited)
        {
            if (visited.Contains(table))
                return 0;

            visited.Add(table);
            long size = 32;

            foreach (var pair in table.Pairs)
            {
                size += EstimateValue(pair.Key, visited);
                size += EstimateValue(pair.Value, visited);
            }

            return size;
        }
    }

}
