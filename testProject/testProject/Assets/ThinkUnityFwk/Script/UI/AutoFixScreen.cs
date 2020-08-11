using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Flz.UI
{
    public class AutoFixScreen : MonoBehaviour
    {
        public static float ResolutionWidth = 750.0f;
        public static float ResolutionHeight = 1334.0f;
        public static float ResolutionOffset = 0.0f;
        public static float ResolutionScale = 1.0f;

        void Awake()
        {
           
            // 分辨率适配
            //float padding = (44 + 34) / 2 * 3;
            float padding = 44 / 2 * 3;
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
            if (Screen.width == 1125 || Screen.width == 828 || Screen.width == 1242)
            {
                ResolutionWidth = 750.0f;
                ResolutionHeight = 1624.0f - padding;
                ResolutionOffset = -padding / 2;
                ResolutionScale = 1.2f;
            }
#elif UNITY_IOS
            if (UnityEngine.iOS.DeviceGeneration.iPhoneX == UnityEngine.iOS.Device.generation || UnityEngine.iOS.DeviceGeneration.iPhoneUnknown == UnityEngine.iOS.Device.generation)
            {
                ResolutionWidth = 750.0f;
                ResolutionHeight = 1624.0f - padding;
                ResolutionOffset = -padding / 2;
                ResolutionScale = 1.2f;
            } 
#endif


            string sy_par = "";
            if (Application.platform == RuntimePlatform.Android)
            {
                using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                {
                    using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
                    {
                        sy_par = jo.Call<string>("getSystemModel");
                    }
                }
                Debug.Log("sy_par = " + sy_par);

                float ratio = (float)Screen.height / Screen.width;
                if (ratio < 1)
                {
                    ratio = (float)Screen.width / Screen.height;
                }

                padding = 0;
                ResolutionWidth = 750.0f;
                ResolutionHeight = ResolutionWidth * ratio - padding;
                ResolutionOffset = -padding / 2;
                ResolutionScale = ResolutionHeight / 1334;

            }

            Debug.LogWarningFormat("AutoFixScreen [w:{0},h:{1}]", Screen.width , Screen.height);
            Debug.LogWarningFormat("AutoFixScreen [w:{0},h:{1}][s:{2},o{3}]", ResolutionWidth, ResolutionHeight, ResolutionScale, ResolutionOffset);
        }

        ScreenOrientation mLastOrientation = ScreenOrientation.Unknown;
        // Use this for initialization
        void Start()
        {
            Screen.sleepTimeout = SleepTimeout.NeverSleep;
        }

        void Update()
        {
            if (mLastOrientation != Screen.orientation)
            {
                mLastOrientation = Screen.orientation;
                CanvasScaler cs = GetComponent<CanvasScaler>();
                if (cs != null)
                {
                    switch (Screen.orientation)
                    {
                        case ScreenOrientation.Portrait:
                        case ScreenOrientation.PortraitUpsideDown:
                            cs.referenceResolution = new Vector2(ResolutionWidth, ResolutionHeight);
                            break;
                        default:
                            cs.referenceResolution = new Vector2(ResolutionHeight, ResolutionWidth);
                            break;
                    }
                    Debug.LogFormat("Update_Screen", cs.referenceResolution);
                }
            }
        }
    }
}
