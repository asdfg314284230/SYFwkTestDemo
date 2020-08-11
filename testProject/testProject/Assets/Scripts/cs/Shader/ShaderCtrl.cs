using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderCtrl : MonoBehaviour {

    MaterialPropertyBlock mpb;
    void Start()
    {
        mpb = new MaterialPropertyBlock();
    }
    public void SetColor(Color color, string key = "_Color")
    {
        mpb.SetColor(key, color); // "_FillColor" 是假设的着色器变量名字。
        GetComponent<MeshRenderer>().SetPropertyBlock(mpb);
    }

    public void SetRendererColor(Color color, string key = "_Color")
    {
        mpb.SetColor(key, color); // "_FillColor" 是假设的着色器变量名字。
        GetComponent<Renderer>().SetPropertyBlock(mpb);
    }
}
