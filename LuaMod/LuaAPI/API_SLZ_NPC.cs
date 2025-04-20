
using Il2CppSLZ.Marrow.AI;
using MelonLoader;
using MoonSharp.Interpreter;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    public class API_SLZ_NPC
    {
        public static readonly API_SLZ_NPC Instance = new API_SLZ_NPC();


        /// <summary>
        /// Finds the closest point on the world Navmesh
        /// </summary>
        public static UnityEngine.Vector3? BL_SamplePosition(UnityEngine.Vector3 position, float maxDistance, int areaMask = -1)
        {
            return LuaSafeCall.Run(() =>
            {
                if (UnityEngine.AI.NavMesh.SamplePosition(position, out UnityEngine.AI.NavMeshHit hit, maxDistance, areaMask))
                {
                    return (Vector3?)hit.position;
                }

               // MelonLogger.Warning($"[BL_SamplePosition] Failed to find NavMesh position near {position} (maxDistance: {maxDistance}, areaMask: {areaMask})");
                return null;
            }, $"BL_SamplePosition(pos: {position}, dist: {maxDistance}, mask: {areaMask})");
        }

        /// <summary>
        /// Calculate a path on the world Navmesh
        /// </summary>
        public static UnityEngine.AI.NavMeshPath BL_CalculatePath(UnityEngine.Vector3 start_pos, UnityEngine.Vector3 end_pos, int areaMask = -1)
        {
            return LuaSafeCall.Run(() =>
            {
                UnityEngine.AI.NavMeshPath path = new UnityEngine.AI.NavMeshPath();
                bool success = UnityEngine.AI.NavMesh.CalculatePath(start_pos, end_pos, areaMask, path);

                if (!success || path.status != UnityEngine.AI.NavMeshPathStatus.PathComplete)
                {
                   // MelonLogger.Warning($"[BL_CalculatePath] Pathfinding failed from {start_pos} to {end_pos} (areaMask: {areaMask})");
                    return null;
                }

                return path;
            }, $"BL_CalculatePath(start: {start_pos}, end: {end_pos}, areaMask: {areaMask})");
        }

        /// <summary>
        /// Make an NPC attack an NPC/Destructable Object/Player
        /// </summary>
        public bool BL_SetNPCAnger(GameObject NPC, GameObject Target)
        {
            return LuaSafeCall.Run(() =>
            {
                if (NPC == null)
                {
                    throw new ScriptRuntimeException("NPC GameObject is null");
                }

                if (Target == null)
                {
                    throw new ScriptRuntimeException("Target GameObject is null");
                }

                if (!NPC.TryGetComponent<AIBrain>(out AIBrain aiBrain))
                {
                    throw new ScriptRuntimeException($"BL_SetNPCAnger: NPC '{NPC.name}' has no AIBrain component.");
                }

                if (!Target.TryGetComponent<TriggerRefProxy>(out TriggerRefProxy targetproxy))
                {
                    targetproxy = Target.AddComponent<TriggerRefProxy>();
                }

                targetproxy.triggerType = TriggerRefProxy.TriggerType.Player;
                aiBrain.behaviour.AddThreat(targetproxy, 999);

                return true;
            }, $"BL_SetNPCAnger(NPC: '{NPC?.name}', Target: '{Target?.name}')");
        }


    }
}
