using Il2Cpp;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Combat;
using Il2CppSLZ.Marrow.PuppetMasta;
using MoonSharp.Interpreter;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    public class API_SLZ_Combat
    {

        public static readonly API_SLZ_Combat Instance = new API_SLZ_Combat();


        public static bool ApplyForce(Rigidbody rb, Vector3 pos, Vector3 normal, float force)
        {
            return LuaSafeCall.Run(() =>
            {
                if (rb == null || rb.isKinematic)
                {
                    return false;
                }

                Vector3 forceapply = normal * force;
                rb.AddForceAtPosition(forceapply, pos);
                return true;
            }, $"ApplyForce(rb: {rb?.name}, pos: {pos}, normal: {normal}, force: {force})");
        }




        public static bool BL_AttackEnemy(GameObject obj, float damage, Collider col, Vector3 pos, Vector3 normal)
        {
            return LuaSafeCall.Run(() =>
            {
                if (obj == null) throw new ScriptRuntimeException("Target GameObject is null");

                Attack attack = new Attack
                {
                    attackType = Il2CppSLZ.Marrow.Data.AttackType.Piercing,
                    collider = col,
                    origin = pos,
                    damage = damage,
                    normal = normal,
                    direction = normal
                };

                BehaviourBaseNav DR = obj.GetComponentInChildren<BehaviourBaseNav>();
                BehaviourCrablet DC = obj.GetComponentInChildren<BehaviourCrablet>();
                ObjectDestructible DP = obj.GetComponentInChildren<ObjectDestructible>();
                PhysicsRig PR = obj.GetComponentInChildren<PhysicsRig>();

                if (DR != null)
                {
                    DR.health.TakeDamage(1, attack);
                    return true;
                }
                else if (DC != null)
                {
                    DC.health.TakeDamage(1, attack);
                    DC.MountAttack(damage);
                    return true;
                }
                else if (DP != null)
                {
                    DP.ReceiveAttack(attack);
                    return true;
                }
                else if (PR != null)
                {
                    API_Player.BL_PlayerHealth().TAKEDAMAGE(damage);
                    return true;
                }
                else
                {
                    MelonLoader.MelonLogger.Warning("[BL_AttackEnemy] No IAttackReceiver found on " + obj.name);
                    return false;
                }
            }, $"BL_AttackEnemy('{obj?.name}', {damage})");
        }



    }


}
