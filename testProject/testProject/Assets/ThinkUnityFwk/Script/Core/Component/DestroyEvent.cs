using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace SYFwk.Core
{
    public class DestroyEvent : MonoBehaviour
    {
        
        private void OnDestroy()
        {
            SYLuaEnv.ResEvent("res", "destroy", gameObject.GetInstanceID().ToString());
        }
    }
}
