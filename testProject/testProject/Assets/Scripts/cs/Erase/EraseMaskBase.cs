using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EraseMaskBase : MonoBehaviour
{
    public RawImage uiTex;
    public RawImage uiTex_mask;

    public Texture2D o_tex;
    public Texture2D my_tex;
    public Texture2D mask_tex;
    void Awake()
    {
        o_tex = (Texture2D)uiTex.mainTexture;
        mask_tex = (Texture2D)uiTex_mask.mainTexture;
        my_tex = new Texture2D(o_tex.width, o_tex.height, TextureFormat.ARGB32, false);
        my_tex.SetPixels(o_tex.GetPixels());
        
    }
}
