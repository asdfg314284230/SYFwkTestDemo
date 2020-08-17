using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SYFwk.Core
{
    public class MainBehaviour : MonoBehaviour {

#if UNITY_EDITOR
        [SerializeField]
        internal LuaLoader.LoadMode RunMode = LuaLoader.LoadMode.LM_DEV;
#endif  

        private void Awake()
        {
            Application.lowMemory += OnLowMemory;
        }

        // Use this for initialization
        void Start() {
#if UNITY_EDITOR
            SYLuaEnv.sMode = RunMode;        // 方便编辑器模式下开发。其他情况都为run
#endif
            
            SYLuaEnv.Init();
            SYLuaEnv.Start();

            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            Debug.Log("Application.targetFrameRate = " + Application.targetFrameRate);
            Application.targetFrameRate = 60;
            Debug.Log("Application.targetFrameRate = " + Application.targetFrameRate);
        }

        public Action OnLowMemory_func;
        private void OnLowMemory()
        {
            if (OnLowMemory_func != null)
            {
                OnLowMemory_func();
            }
            // release all cached textures
            //Resources.UnloadUnusedAssets();
        }


        private void LateUpdate()
        {

            SYLuaEnv.LateUpdate(Time.deltaTime);
            SYLuaEnv.sEnv.Tick();
        }
    }
}