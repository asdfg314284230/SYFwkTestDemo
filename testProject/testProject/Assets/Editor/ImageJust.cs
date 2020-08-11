using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class ImageJust : MonoBehaviour
{

    [MenuItem("ImageJust/ios")]

    static public void ImageJust_ios()
    {
        // 设置修改路径
        string path = Application.streamingAssetsPath + "/../res/image";


        if (Directory.Exists(path))
        {
            DirectoryInfo direction = new DirectoryInfo(path);
            FileInfo[] files = direction.GetFiles("*", SearchOption.AllDirectories);

            // 得到文件数量
            Debug.Log(files.Length);
            for (int i = 0; i < files.Length; i++)
            {
                // 判断是否是图片
                if (files[i].Name.EndsWith(".png"))
                {
                    //// 名字
                    //Debug.Log("Name:" + files[i].Name);
                    //// 路径
                    //Debug.Log("FullName:" + files[i].FullName);
                    //// 文件夹名字
                    //Debug.Log("DirectoryName:" + files[i].DirectoryName);

                    Debug.Log(files[i].FullName.Substring(files[i].FullName.IndexOf("Assets")));

                    // 重新分割字符串
                    string m_path = files[i].FullName.Substring(files[i].FullName.IndexOf("Assets"));

                    // 后期可以重新调整下判断是否修改过，修改过就不修了，要不然每次修改时间特TM长

                    TextureImporter textureImporter = AssetImporter.GetAtPath(m_path) as TextureImporter;
                    TextureImporterPlatformSettings textureImporterSettings = new TextureImporterPlatformSettings();
                    textureImporterSettings.allowsAlphaSplitting = true;
                    textureImporterSettings.compressionQuality = 100;
                    textureImporterSettings.crunchedCompression = true;
                    textureImporterSettings.format = TextureImporterFormat.ASTC_RGBA_4x4;
                    textureImporterSettings.maxTextureSize = 2048;
                    textureImporterSettings.overridden = true;
                    textureImporterSettings.name = "iPhone";
                    textureImporter.SetPlatformTextureSettings(textureImporterSettings);
                    textureImporter.SaveAndReimport();
                }

            }


        }


    }



}
