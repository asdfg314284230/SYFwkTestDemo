using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace SYFwk.Tool
{
    public class AutoPackge
    {


        static List<string> levels = new List<string>();

        [MenuItem("AutoPackge/BuildIOS")]
        static public void BuildIOS()
        {
            // sShowFinishMessageBox = true;
            // AutoCode.generate();

            // 调用修改图集文件函数(暂时关闭)
            ImageJust.ImageJust_ios();

            // 卸载XLua 中间层文件
            CSObjectWrapEditor.Generator.GenAll();
            // 遍历场景目录文件
            foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
            {
                if (!scene.enabled) continue;
                // 添加场景路径
                levels.Add(scene.path);
            }
            // 切换平台资源
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.iOS, BuildTarget.iOS);
            // 设置出包路径
            BuildPipeline.BuildPlayer(levels.ToArray(), "ios", BuildTarget.iOS, BuildOptions.CompressWithLz4HC);
            //string res = BuildPipeline.BuildPlayer(levels.ToArray(), "ios", BuildTarget.iOS, BuildOptions.CompressWithLz4HC);
            //// 如果大于零就是有异常
            //if (res.Length > 0)
            //{
            //    Debug.Log("打包出现异常");
            //    throw new System.Exception("BuildPlayer failure: " + res);
            //}
        }

        [MenuItem("AutoPackge/BuildAndroid")]
        static public void BuildAndroid()
        {
            // sShowFinishMessageBox = true;
            // AutoCode.generate();
            // 调用修改图集文件函数

            //ImageJust.ImageJust_ios();
            // 卸载XLua 中间层文件
            CSObjectWrapEditor.Generator.GenAll();
            // 遍历场景目录文件
            foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
            {
                if (!scene.enabled) continue;
                // 添加场景路径
                levels.Add(scene.path);
            }
            // 切换平台资源
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
            // 设置出包路径
            BuildPipeline.BuildPlayer(levels.ToArray(), "android", BuildTarget.Android, BuildOptions.AcceptExternalModificationsToPlayer);
            //string res = BuildPipeline.BuildPlayer(levels.ToArray(), "android", BuildTarget.Android, BuildOptions.AcceptExternalModificationsToPlayer);
            //// 如果大于零就是有异常
            //if (res.Length > 0)
            //{
            //    Debug.Log("打包出现异常");
            //    throw new System.Exception("BuildPlayer failure: " + res);
            //}
        }

    }
}

