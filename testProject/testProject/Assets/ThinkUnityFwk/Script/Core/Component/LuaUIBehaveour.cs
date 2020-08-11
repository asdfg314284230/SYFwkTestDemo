using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace SYFwk.Core
{
    public class LuaUIBehaveour : MonoBehaviour
    {
        public string luaUIName = null;
        public LuaTable luaCtx = null;

        private void Awake()
        {
            
        }
        // Use this for initialization
        void Start()
        {
            SYLuaEnv.FlzEvent("ui", "start", luaCtx);
        }

        private void OnDestroy()
        {
            //Debug.Log("LuaUIBehaveour destroy");
            SYLuaEnv.FlzEvent("ui", "destroy", luaCtx);
        }
    }
}