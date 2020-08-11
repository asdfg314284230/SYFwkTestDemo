using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColliderHandle : MonoBehaviour {
    public Action<Collider2D> on_trigger_enter;
    public Action<Collider2D> on_trigger_exit;
    public Action<Collision2D> on_collision_enter;
    public Action<Collision2D> on_collision_exit;

    void OnTriggerEnter2D(Collider2D other)
    {
        //Debug.Log("OnTriggerEnter2D:" + other.name);
        if (on_trigger_enter != null)
        {
            on_trigger_enter(other);
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        //Debug.Log("OnTriggerExit2D:" + other.name);
        if (on_trigger_exit != null)
        {
            on_trigger_exit(other);
        }
    }

    //void OnTriggerStay2D()
    //{
    //    Debug.Log("OnTriggerStay2D");
    //}


    void OnCollisionEnter2D(Collision2D other)
    {
        if (on_collision_enter != null)
        {
            on_collision_enter(other);
        }
    }


    void OnCollisionExit2D(Collision2D other)
    {
        if (on_collision_exit != null)
        {
            on_collision_exit(other);
        }
    }

}
