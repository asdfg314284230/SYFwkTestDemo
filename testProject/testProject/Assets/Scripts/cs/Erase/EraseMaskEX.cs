using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class EraseMaskEX : MonoBehaviour
{

    bool is_finish = false;
    public Action finish_func;

    public enum Mode
    {
        Eliminate,
        Fill
    }

    public Mode mode = Mode.Fill;


    public RawImage uiTex;
    public RawImage uiTex_mask;
    Texture2D o_tex;
    Texture2D MyTex;
    Texture2D mask_tex;
    float maxColorA=0;
    float colorA=0;

    int mWidth;
    int mHeight;

    public int brushSize = 50;
    public int dim_range = 30;
    public float strength = 1;
    public int rate = 90;
    double fate = 0;
    public double finish_fate = 0.998;

    void Awake()
    {
        //更换纹理（保护原文件）
        o_tex = (Texture2D)uiTex.mainTexture;
        mask_tex = (Texture2D)uiTex_mask.mainTexture;

        MyTex = new Texture2D(o_tex.width, o_tex.height, TextureFormat.ARGB32, false);
        MyTex.SetPixels(o_tex.GetPixels());

        mWidth = MyTex.width;
        mHeight = MyTex.height;

        switch (mode)
        {
            case Mode.Fill:
                for (int x = 0; x < mWidth; x++)
                {
                    for (int y = 0; y < mHeight; y++)
                    {
                        Color col_mask = mask_tex.GetPixel(x, y);
                        Color col = o_tex.GetPixel(x, y);
                        if (col_mask.a == 0 && col.a != 0)
                        {
                            maxColorA++;
                        }
                        col.a = 0;
                        MyTex.SetPixel(x, y, col);
                    }
                }
                break;
            case Mode.Eliminate:
                for (int x = 0; x < mWidth; x++)
                {
                    for (int y = 0; y < mHeight; y++)
                    {
                        Color col_mask = mask_tex.GetPixel(x, y);
                        Color col = o_tex.GetPixel(x, y);
                        if (col_mask.a == 0 && col.a != 0)
                        {
                            maxColorA++;
                        };
                        MyTex.SetPixel(x, y, col);
                    }
                }
                break;
        }

        MyTex.Apply();
        uiTex.texture = MyTex;  
    }

    /// <summary>
    /// 贝塞尔平滑
    /// </summary>
    /// <param name="start">起点</param>
    /// <param name="mid">中点</param>
    /// <param name="end">终点</param>
    /// <param name="segments">段数</param>
    /// <returns></returns>
    public Vector2[] Beizier(Vector2 start, Vector2 mid, Vector2 end, int segments)
    {
        float d = 1f / segments;
        Vector2[] points = new Vector2[segments - 1];
        for (int i = 0; i < points.Length; i++)
        {
            float t = d * (i + 1);
            points[i] = (1 - t) * (1 - t) * mid + 2 * t * (1 - t) * start + t * t * end;
        }
        List<Vector2> rps = new List<Vector2>();
        rps.Add(mid);
        rps.AddRange(points);
        rps.Add(end);
        return rps.ToArray();
    }


    public void CheckPoint(Vector3 pScreenPos)
    {
        if (is_finish){return;}
        Vector3 worldPos = Camera.main.ScreenToWorldPoint(pScreenPos);
        Vector3 localPos = uiTex.gameObject.transform.InverseTransformPoint(worldPos);

        if (localPos.x > -mWidth / 2 && localPos.x < mWidth / 2 && localPos.y > -mHeight / 2 && localPos.y < mHeight / 2)
        {
            for (int i = (int)localPos.x - brushSize; i < (int)localPos.x + brushSize; i++)
            {
                for (int j = (int)localPos.y - brushSize; j < (int)localPos.y + brushSize; j++)
                {
                    float d_max = Mathf.Pow(brushSize, 2);
                    float d_min = Mathf.Pow(dim_range, 2);
                    float d = Mathf.Pow(i - localPos.x, 2) + Mathf.Pow(j - localPos.y, 2);
                    if (d > d_max)
                        continue;
                    if (i < 0) { if (i < -mWidth / 2) { continue; } }
                    if (i > 0) { if (i > mWidth / 2) { continue; } }
                    if (j < 0) { if (j < -mHeight / 2) { continue; } }
                    if (j > 0) { if (j > mHeight / 2) { continue; } }

                    if (d > d_min)
                    {
                        float r = UnityEngine.Random.Range(d_min, d_max);
                        if (d > r)
                        {
                            continue;
                        }
                    }
                        

                    Texture2D mask_tex = (Texture2D)uiTex_mask.mainTexture;
                    Color mask_col = mask_tex.GetPixel(i + (int)mWidth / 2, j + (int)mHeight / 2);
                    if(mask_col.a != 0){continue;}

                    Color col = MyTex.GetPixel(i + (int)mWidth / 2, j + (int)mHeight / 2);

                    switch (mode)
                    {
                        case Mode.Eliminate:
                            if (col.a != 0f)
                            {
                                float a = col.a - strength;
                                a = a <= 0 ? 0.0f : a;
                                col.a = a;
                                if (a <= 0)
                                {
                                    colorA++;
                                }
                                MyTex.SetPixel(i + (int)mWidth / 2, j + (int)mHeight / 2, col);
                            }
                            break;
                        case Mode.Fill:
                            if (col.a == 0f)
                            {
                                col.a = 1f;
                                colorA++;
                                MyTex.SetPixel(i + (int)mWidth / 2, j + (int)mHeight / 2, col);
                            }
                            break;
                    }
                }
            }

            MyTex.Apply();

            fate = colorA / maxColorA;

            if (fate >= finish_fate)
            {
                is_finish = true;
                switch (mode)
                {
                    case Mode.Eliminate:
                        for (int x = 0; x < mWidth; x++)
                        {
                            for (int y = 0; y < mHeight; y++)
                            {
                                Color col_mask = mask_tex.GetPixel(x, y);
                                Color col = o_tex.GetPixel(x, y);
                                col.a = 0;
                                MyTex.SetPixel(x, y, col);
                            }
                        }
                        break;
                    case Mode.Fill:
                        MyTex.SetPixels(o_tex.GetPixels());
                        break;
                }

                MyTex.Apply();
                if (null != finish_func)
                {
                    finish_func();
                }
            }
        }
    }

    //获取完成进度
    public double get_fate()
    {
        return fate;
    }
}
