using Il2CppSLZ.Marrow.AI;
using Il2CppSLZ.Marrow.Combat;
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

        public static bool ApplyForce(Vector3 pos, float radius, float force)
        {
            return true;
        }


        public static bool BL_AttackEnemy(GameObject obj, int damage, Collider col, Vector3 pos, Vector3 normal)
        {
            AIBrain DR = obj.GetComponent<AIBrain>();

            if (DR != null)
            {
                BoneLib.Extensions.DealDamage(DR, damage);
                MelonLoader.MelonLogger.Error("attacking NPC");
                /*
            Attack attack = new Attack();
            attack.attackType = Il2CppSLZ.Marrow.Data.AttackType.Piercing;
            attack.collider = col;
            attack.origin = pos;
            attack.damage = damage;
            attack.normal = normal;
            attack.direction = normal;

            DR.rec
            */
            }
            else
            {
                MelonLoader.MelonLogger.Error("no AI brain found");
            }


            return false;
        }


    }


}
