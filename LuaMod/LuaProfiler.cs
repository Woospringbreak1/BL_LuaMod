using LuaMod.LuaAPI;
using MelonLoader;
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Rendering;

namespace LuaMod
{
    internal  class LuaProfiler
    {
        [MoonSharpHidden]
        public static readonly LuaProfiler Instance = new LuaProfiler();


        [MoonSharpHidden]
        private static bool PROFILING = false;

        [MoonSharpHidden]
        private static List<LuaProfileItem> ProfilerRecords = new List<LuaProfileItem>();

        [MoonSharpHidden]
        public static void SubmitProfileReport(LuaModScript script, string function, float time)
        {
            ProfilerRecords.Add(new LuaProfileItem(script.GetScriptName(), function, time));
        }


        public static void StartProfiling()
        {
            PROFILING = true;
        }

        public static void StopProfiling()
        {
            PROFILING = false;
        }

        public static void ClearProfilingData()
        { 
            ProfilerRecords.Clear(); 
        }

        public static bool IsProfiling()
        {
            return PROFILING;
        }

        public static void OutputProfilerSummary()
        {

            if(ProfilerRecords.Count == 0)
            {
                MelonLogger.Warning("No Profiler records found - Need to call LuaProfiler.StartProfiling() to begin data collection");
                return;
            }

            // Step 1: Group records by ScriptName first
            Dictionary<string, List<LuaProfileItem>> sortedRecords = new Dictionary<string, List<LuaProfileItem>>();

            foreach (LuaProfileItem record in ProfilerRecords)
            {
                List<LuaProfileItem> itemList;

                // Check if we already have a list for the current script
                if (sortedRecords.ContainsKey(record.ScriptName))
                {
                    itemList = sortedRecords[record.ScriptName];
                }
                else
                {
                    itemList = new List<LuaProfileItem>();
                    sortedRecords.Add(record.ScriptName, itemList);
                }

                // Add the record to the script's list
                itemList.Add(record);
            }

            // Step 2: For each script, create a dictionary that groups by function
            foreach (var scriptEntry in sortedRecords)
            {
                string scriptName = scriptEntry.Key;
                List<LuaProfileItem> scriptItemList = scriptEntry.Value;

                // Grouping by FunctionName within each script
                Dictionary<string, List<LuaProfileItem>> functionRecords = new Dictionary<string, List<LuaProfileItem>>();

                foreach (LuaProfileItem record in scriptItemList)
                {
                    List<LuaProfileItem> functionList;

                    // Check if we already have a list for the current function within the script
                    if (functionRecords.ContainsKey(record.FunctionName))
                    {
                        functionList = functionRecords[record.FunctionName];
                    }
                    else
                    {
                        functionList = new List<LuaProfileItem>();
                        functionRecords.Add(record.FunctionName, functionList);
                    }

                    // Add the record to the function's list
                    functionList.Add(record);
                }

                // Step 3: Now we have a dictionary for each script with functions as keys
                // Output or process each function's records (printing, analyzing, etc.)
                MelonLogger.Warning($"Script: {scriptName}");

                foreach (var functionEntry in functionRecords)
                {
                    string functionName = functionEntry.Key;
                    List<LuaProfileItem> functionList = functionEntry.Value;

                    MelonLogger.Msg($"  Function: {functionName}");

                    // You can now analyze or print out each function's records, e.g., sum execution time:
                    float totalExecutionTime = functionList.Sum(item => item.ExecutionTime);
                    int functionCalls = functionList.Count;

                    MelonLogger.Msg($"    Total Execution Time: {totalExecutionTime}ms");
                    MelonLogger.Msg($"    Number of Calls: {functionCalls}");
                    MelonLogger.Msg($"    Average Execution Time: {totalExecutionTime / functionCalls}");
                }

                MelonLogger.Msg("\n"); // Adds a newline between script outputs
            }
        }


        /// <summary>
        /// Writes an Excel-friendly CSV summary of profiler data.
        /// One row per ScriptName + FunctionName with stats:
        /// Calls, TotalMs, AvgMs, MinMs, P50Ms, P95Ms, MaxMs.
        ///
        /// Optionally also writes a second CSV with all raw samples.
        /// </summary>
        /// <param name="filePath">
        /// Destination .csv path. If null/empty, writes to
        /// {Application.persistentDataPath}/LuaProfiler_{yyyyMMdd_HHmmss}.csv
        /// </param>
        /// <param name="includeRawSamples">
        /// If true, also writes a “*_samples.csv” file with every sample.
        /// </param>
        public static void OutputProfilerSummaryExcel(string filePath = null, bool includeRawSamples = false)
        {
            if (ProfilerRecords.Count == 0)
            {
                MelonLogger.Warning("No Profiler records found - call LuaProfiler.StartProfiling() to begin data collection");
                return;
            }

            var ts = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            if (string.IsNullOrEmpty(filePath))
            {
                var dir = Application.persistentDataPath;
                filePath = Path.Combine(dir, $"LuaProfiler_{ts}.csv");
            }

            // Build summary by ScriptName + FunctionName
            // Dictionary<(Script, Func), List<float>>
            var groups = new Dictionary<(string Script, string Func), List<float>>();

            for (int i = 0; i < ProfilerRecords.Count; i++)
            {
                var r = ProfilerRecords[i];
                var key = (r.ScriptName, r.FunctionName);
                if (!groups.TryGetValue(key, out var list))
                {
                    list = new List<float>(64);
                    groups[key] = list;
                }
                list.Add(r.ExecutionTime);
            }

            // Prepare CSV builder
            var sb = new StringBuilder(1024);
            // Header
            sb.AppendLine("ScriptName,FunctionName,Calls,TotalMs,AvgMs,MinMs,P50Ms,P95Ms,MaxMs");

            // Invariant culture for decimal points Excel parses reliably
            var inv = CultureInfo.InvariantCulture;

            foreach (var kv in groups)
            {
                var script = kv.Key.Script;
                var func = kv.Key.Func;
                var times = kv.Value;

                times.Sort(); // for percentiles & quick min/max

                int n = times.Count;
                double total = 0.0;
                for (int i = 0; i < n; i++) total += times[i];

                double avg = total / n;
                double min = times[0];
                double max = times[n - 1];
                double p50 = PercentileSorted(times, 0.50);
                double p95 = PercentileSorted(times, 0.95);

                // Escape commas/quotes safely for CSV
                string escScript = CsvEscape(script);
                string escFunc = CsvEscape(func);

                sb.Append(escScript).Append(',')
                  .Append(escFunc).Append(',')
                  .Append(n.ToString(inv)).Append(',')
                  .Append(total.ToString(inv)).Append(',')
                  .Append(avg.ToString(inv)).Append(',')
                  .Append(min.ToString(inv)).Append(',')
                  .Append(p50.ToString(inv)).Append(',')
                  .Append(p95.ToString(inv)).Append(',')
                  .Append(max.ToString(inv)).AppendLine();
            }

            // Ensure directory exists
            Directory.CreateDirectory(Path.GetDirectoryName(filePath));

            // Write summary CSV
            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);

            MelonLogger.Msg($"LuaProfiler summary written: {filePath}");

            // Optional raw samples CSV (for deeper analysis / pivot tables in Excel)
            if (includeRawSamples)
            {
                var rawPath = Path.Combine(
                    Path.GetDirectoryName(filePath),
                    Path.GetFileNameWithoutExtension(filePath) + "_samples.csv"
                );

                var raw = new StringBuilder(1024);
                raw.AppendLine("ScriptName,FunctionName,ExecutionTimeMs");

                for (int i = 0; i < ProfilerRecords.Count; i++)
                {
                    var r = ProfilerRecords[i];
                    raw.Append(CsvEscape(r.ScriptName)).Append(',')
                       .Append(CsvEscape(r.FunctionName)).Append(',')
                       .Append(r.ExecutionTime.ToString(inv)).AppendLine();
                }

                File.WriteAllText(rawPath, raw.ToString(), Encoding.UTF8);
                MelonLogger.Msg($"LuaProfiler raw samples written: {rawPath}");
            }
        }

        // --- Helpers ---

        // Percentile over a pre-sorted list (ascending). Linear interpolation between nearest ranks.
        private static double PercentileSorted(List<float> sorted, double p)
        {
            int n = sorted.Count;
            if (n == 1) return sorted[0];

            // Using Excel's PERCENTILE.INC method:
            double rank = (n - 1) * p;
            int low = (int)Math.Floor(rank);
            int high = (int)Math.Ceiling(rank);
            if (low == high) return sorted[low];

            double frac = rank - low;
            return sorted[low] + (sorted[high] - sorted[low]) * frac;
        }

        // Basic CSV escape: wrap in quotes if contains comma, quote, or newline; double internal quotes.
        private static string CsvEscape(string s)
        {
            if (s == null) return "";
            bool needQuotes = s.IndexOfAny(new[] { ',', '"', '\n', '\r' }) >= 0;
            if (!needQuotes) return s;
            return "\"" + s.Replace("\"", "\"\"") + "\"";
        }


        internal class LuaProfileItem
        {
            [MoonSharpHidden]
            public string ScriptName;
            [MoonSharpHidden]

            public string FunctionName;

            [MoonSharpHidden]
            public float ExecutionTime;

            [MoonSharpHidden]
            public LuaProfileItem(string scriptName, string functionName, float executionTime)
            {
                ScriptName = scriptName;
                FunctionName = functionName;
                ExecutionTime = executionTime;
            }
        }

    }

}
