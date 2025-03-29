using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Physics
    {

        public static readonly API_Physics Instance = new API_Physics();

        public static DynValue BL_SphereCast(Vector3 origin, Vector3 direction, float radius, float maxdistance)
        {
            RaycastHit hit;
            // LayerMask layerMask = LayerMask.GetMask()
            // Does the ray intersect any objects excluding the player layer
            if (Physics.SphereCast(origin,radius, direction, out hit, maxdistance))
            {
              
                return UserData.Create(hit);

            }
            else
            {
                return null;
            }

        }

        public static DynValue BL_SphereCast(Vector3 start, Vector3 end, float radius)
        {
            RaycastHit hit;
            Vector3 direction = (end - start).normalized; // Normalize direction
            float length = (end - start).magnitude; // Calculate distance

            if (Physics.SphereCast(start, radius, direction, out hit, length))
            {
                return UserData.Create(hit);
            }

            return DynValue.Nil;
        }

        public static DynValue BL_RayCast(Vector3 start, Vector3 end)
        {
            RaycastHit hit;
            Vector3 direction = (end - start).normalized; // Normalize direction
            float length = (end - start).magnitude; // Calculate distance

            if (Physics.Raycast(start, direction, out hit, length))
            {
                return UserData.Create(hit);
            }

            return DynValue.Nil;
        }

        public static DynValue BL_RayCast(Vector3 origin, Vector3 direction, float maxdistance = Mathf.Infinity)
        {


            RaycastHit hit;
            // LayerMask layerMask = LayerMask.GetMask()
            // Does the ray intersect any objects excluding the player layer
            if (Physics.Raycast(origin, direction, out hit, maxdistance))
            {
                return UserData.Create(hit);

            }
            else
            {
                return null;
            }

        }


        public bool BL_SetHingeJointMotor(GameObject obj,float desiredSpeed, float maxForce,bool freespin)
        {
            HingeJoint joint = obj.GetComponent<HingeJoint>();

            if (joint != null)
            {

                JointMotor Jmotor = joint.motor;
                Jmotor.freeSpin = freespin;
                Jmotor.force = maxForce;
                Jmotor.targetVelocity= desiredSpeed;

                joint.motor = Jmotor;

                return true;
            }
            else
            { 
                return false;
            }
        }

    }
}
