using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Flz.SDK
{
    public class UnityToPlatform : MonoBehaviour
    {

#if UNITY_IOS
    [DllImport("__Internal")]
    private static extern void ios_init_sdk(string json_str);

    // [DllImport("__Internal")]
    // private static extern void ios_analytics_event(string eventId, string json_str);

    // [DllImport("__Internal")]
    // private static extern void ios_analytics_pay(string json_str);

    // [DllImport("__Internal")]
    // private static extern bool ios_is_platform_login();

    // [DllImport("__Internal")]
    // private static extern bool ios_isSupportLogout();

    // [DllImport("__Internal")]
    // private static extern bool ios_isSupportAccountCenter();

    [DllImport("__Internal")]
    private static extern void ios_login();

    // [DllImport("__Internal")]
    // private static extern void ios_logout();

    // [DllImport("__Internal")]
    // private static extern void ios_showAccountCenter();

    // [DllImport("__Internal")]
    // private static extern void ios_submitExtraData(string json_str);
    
    // [DllImport("__Internal")]
    // private static extern void ios_exit();
    
    // [DllImport("__Internal")]
    // private static extern void ios_purchase(string json_str);

    // [DllImport("__Internal")]
    // private static extern int ios_getCurrChannel();

    // ********************************************************
	// 视频播放相关
	// ********************************************************
	// // 播放视频
	// [DllImport("__Internal")]
	// private static extern void ios_video_play(string jsonStr);
	
	// // 显示分支剧情
	// [DllImport("__Internal")]
	// private static extern void ios_video_branch(string jsonStr);

	// // 销毁视频播放器
	// [DllImport("__Internal")]
	// private static extern void ios_video_destroy();

 //    // 是否支持视频播放SDK
 //    [DllImport("__Internal")]
 //    private static extern bool ios_video_support();

 //    // 清空所有下载的视频
 //    [DllImport("__Internal")]
 //    private static extern void ios_video_clear();

#endif

        // 监听消息
        void Update()
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                Debug.Log("Input.GetKey(KeyCode.Escape)");
                Call_void_func("exit");
            }
        }

        //初始化SDK入口
        public void init_sdk(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                // 初始化安卓SDK
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        jo.Call("init_sdk", json_str);
                    }
                }
            }
            //初始化IOS SDK
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            ios_init_sdk(json_str);
#endif
            }
        }
        
        // 函数回调
        public void analytics_event(string eventId, string json_str)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        jo.Call("analytics_event", eventId, json_str);
                    }
                }
            }
            else
            {
#if UNITY_IOS
            //ios_analytics_event(eventId, json_str);
#endif
            }
        }

        public void analytics_pay(string json_str)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("analytics_pay");
                        }
                        else
                        {
                            jo.Call("analytics_pay", json_str);
                        }
                    }
                }
            }
            else
            {
#if UNITY_IOS
            //ios_analytics_pay(json_str);
#endif
            }
        }

        public string getSystemModel(string json_str)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        return jo.Call<string>("getSystemModel");
                    }
                }
            }
            return "";
        }

        public bool is_platform_login(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            return jo.Call<bool>("is_platform_login");
                        }
                        else
                        {
                            return jo.Call<bool>("is_platform_login", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //return ios_is_platform_login();
#endif
            }
            return false;
        }

        public bool isSupportLogout(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            return jo.Call<bool>("isSupportLogout");
                        }
                        else
                        {
                            return jo.Call<bool>("isSupportLogout", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //return ios_isSupportLogout();
#endif
            }
            return false;
        }

        public bool isSupportAccountCenter(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            return jo.Call<bool>("isSupportAccountCenter");
                        }
                        else
                        {
                            return jo.Call<bool>("isSupportAccountCenter", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //return ios_isSupportAccountCenter();
#endif
            }
            return false;
        }

        public void login(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("login");
                        }
                        else
                        {
                            jo.Call("login", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            ios_login();
#endif
            }
        }

        public void logout(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("logout");
                        }
                        else
                        {
                            jo.Call("logout", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //ios_logout();
#endif
            }
        }

        public void showAccountCenter(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("showAccountCenter");
                        }
                        else
                        {
                            jo.Call("showAccountCenter", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //ios_showAccountCenter();
#endif
            }
        }

        public void submitExtraData(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("submitExtraData");
                        }
                        else
                        {
                            jo.Call("submitExtraData", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //ios_submitExtraData(json_str);
#endif
            }
        }

        public void exit(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("exit");
                        }
                        else
                        {
                            jo.Call("exit", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //ios_exit();
#endif
            }
        }

        public void pay(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call("pay");
                        }
                        else
                        {
                            jo.Call("pay", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //ios_purchase(json_str);
#endif
            }
        }

        public string getCurrChannel(string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            return jo.Call<string>("getCurrChannel");
                        }
                        else
                        {
                            return jo.Call<string>("getCurrChannel", json_str);
                        }
                    }
                }
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            // ios平台固定返回ios
            return "ios"; // ios_getCurrChannel();
#endif
            }
            return "";
        }

        // 播放视频
		public void video_play(string jsonStr) {
			if (Application.platform == RuntimePlatform.Android) {
                Call_void_func("android_video_play", jsonStr);
            } else if (Application.platform == RuntimePlatform.IPhonePlayer) {
				#if UNITY_IOS
				//ios_video_play (jsonStr);
				#endif
			}
		}

		// 选择分支剧情
		public void video_branch(string jsonStr){
			if (Application.platform == RuntimePlatform.Android) {
                Call_void_func("android_video_branch", jsonStr);
            } else if (Application.platform == RuntimePlatform.IPhonePlayer) {
				#if UNITY_IOS
				//ios_video_branch (jsonStr);
				#endif
			}
		}

		// 销毁视频播放器
		public void video_destroy(){
			if (Application.platform == RuntimePlatform.Android) {
                Call_void_func("android_video_destroy");
			} else if (Application.platform == RuntimePlatform.IPhonePlayer) {
				#if UNITY_IOS
				//ios_video_destroy ();
				#endif
			}
		}

        // 是否支持视频播放
        public bool video_support()
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                return Call_bool_func("android_video_support");
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //return ios_video_support();
#endif
            }
            // windows平台不支持
            return false;
        }

        // 清空所有下载的视频
        public void video_clear()
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                Call_bool_func("android_video_clear");
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
#if UNITY_IOS
            //ios_video_clear();
#endif
            }
        }

        public bool Call_bool_func(string func_name, string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            return jo.Call<bool>(func_name);
                        }
                        else
                        {
                            return jo.Call<bool>(func_name, json_str);
                        }
                    }

                }
            }
            return false;
        }

        public void Call_void_func(string func_name, string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            jo.Call(func_name);
                        }
                        else
                        {
                            jo.Call(func_name, json_str);
                        }
                    }
                }
            }
        }

        public int Call_int_func(string func_name, string json_str = null)
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        if (null == json_str)
                        {
                            return jo.Call<int>(func_name);
                        }
                        else
                        {
                            return jo.Call<int>(func_name, json_str);
                        }
                    }
                }
            }
            return 0;
        }


    }
}