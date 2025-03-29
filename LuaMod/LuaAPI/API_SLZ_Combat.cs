using Il2Cpp;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Combat;
using Il2CppSLZ.Marrow.PuppetMasta;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_SLZ_Combat
    {

        public static readonly API_SLZ_Combat Instance = new API_SLZ_Combat();

        public static Attack BL_CreateAttackStruct(int damage, Collider collider, Vector3 pos, Vector3 normal)
        {
            Attack attack = new Attack();
            attack.attackType = Il2CppSLZ.Marrow.Data.AttackType.Piercing;
            attack.collider = collider;
            attack.origin = pos;
            attack.damage = damage;
            attack.normal = normal;

            return attack;

        }

        public static bool ApplyForce(Rigidbody rb, Vector3 pos, Vector3 normal, float force)
        {
            if (rb == null || rb.isKinematic)
            {
                return false;
            }
            else
            {
                Vector3 forceapply = normal * force;
                rb.AddForceAtPosition(forceapply, pos);
                return true;
            }
        }



        public static bool BL_AttackEnemy(GameObject obj, float damage, Collider col, Vector3 pos, Vector3 normal)
        {

            Attack attack = new Attack();
            attack.attackType = Il2CppSLZ.Marrow.Data.AttackType.Piercing;
            attack.collider = col;
            attack.origin = pos;
            attack.damage = damage;
            attack.normal = normal;
            attack.direction = normal;


            BehaviourBaseNav DR = obj.GetComponentInChildren<BehaviourBaseNav>();
            BehaviourCrablet DC = obj.GetComponentInChildren<BehaviourCrablet>();
            ObjectDestructible DP = obj.GetComponentInChildren<ObjectDestructible>();
            PhysicsRig PR = obj.GetComponentInChildren<PhysicsRig>();
            //DP.OnDestruction
            if (DR != null)
            {
                DR.health.TakeDamage(1, attack);
            }
            else if (DC != null)
            {
                DC.health.TakeDamage(1, attack);
                DC.MountAttack(damage);
            }
            else if(DP != null)
            {
                DP.ReceiveAttack(attack);
            }
            else if (PR != null)
            {
                API_Player.BL_PlayerHealth().TAKEDAMAGE(damage);
            }
            else
            {
                MelonLoader.MelonLogger.Error("no IAttackReciever found");
            }


            return false;
        }


    }


}
