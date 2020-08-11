using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RawImageEx : MonoBehaviour
{

    public enum Mode
    {
        Eliminate,
        Fill
    }

    public Mode mode = Mode.Fill;

    public RawImage uiTex;
    public RawImage uiTex_mask;
    public RawImage uiTex_brush;

    Texture2D o_tex;
    Texture2D my_tex;
    Texture2D mask_tex;
    Texture2D brush_tex;

    float maxColorA = 0;
    float colorA = 0;

    int mWidth;
    int mHeight;

    public int brushSize = 50;
    public float strength = 1;

    double fate = 0;
    public double finish_fate = 0.998;

    bool is_finish = false;
    public Action finish_func;

    Dictionary<string, string> record;
    

    void Awake()
    {
        record = new Dictionary<string, string>();
        o_tex = (Texture2D)uiTex.mainTexture;
        mask_tex = (Texture2D)uiTex_mask.mainTexture;
        my_tex = new Texture2D(o_tex.width, o_tex.height, TextureFormat.ARGB32, false);
        my_tex.SetPixels(o_tex.GetPixels());

        if (null != uiTex_brush)
        {
            brush_tex = (Texture2D)uiTex_brush.mainTexture;
        }
        

        mWidth = my_tex.width;
        mHeight = my_tex.height;
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
                if(mode == Mode.Fill)
                {
                    col.a = 0;
                }
                my_tex.SetPixel(x, y, col);
            }
        }
        my_tex.Apply();
        uiTex.texture = my_tex;


        //Texture2D xx =  new Texture2D(uiTex_brush.texture.width, uiTex_brush.texture.height, TextureFormat.ARGB32, false);

        //for (int x = 0; x < uiTex_brush.texture.width; x++)
        //{
        //    for (int y = 0; y < uiTex_brush.texture.height; y++)
        //    {
        //        Texture2D brush_tex = (Texture2D)uiTex_brush.mainTexture;
        //        Color col_xx = brush_tex.GetPixel(x, y);
        //        if (col_xx.a != 0f)
        //        {
        //            col_xx.a = 1f;
        //        }
        //        xx.SetPixel(x, y, col_xx);
        //    }
        //}
        //xx.Apply();
        //uiTex_brush.texture = xx;

    }

    public void CheckPoint(Vector3 worldPos, string touch_id = null) 
    {
        if (is_finish) { return; }
        Vector3 localPos = uiTex.gameObject.transform.InverseTransformPoint(worldPos);

        int radius_x = (int)Mathf.Ceil(mWidth / 2);
        int radius_y = (int)Mathf.Ceil(mHeight / 2);

        if (localPos.x > -radius_x && localPos.x < radius_x && localPos.y > -radius_y && localPos.y < radius_y)
        {
            for (int i = (int)Mathf.Floor(localPos.x - brushSize); i < Mathf.Floor(localPos.x + brushSize); i++)
            {
                for (int j = (int)Mathf.Floor(localPos.y - brushSize); j < Mathf.Floor(localPos.y + brushSize); j++)
                {
                    if (record.ContainsKey(i + "_" + j))
                    {
                        if (record[i + "_" + j] == touch_id) { continue; }
                    }
                    

                    float d_max = Mathf.Pow(brushSize, 2);
                    float d = Mathf.Pow(i - localPos.x, 2) + Mathf.Pow(j - localPos.y, 2);
                    if (d > d_max) { continue; }
                    if (Mathf.Abs(i) > radius_x) { continue; }
                    if (Mathf.Abs(j) > radius_y) { continue; }

                    Color mask_col = mask_tex.GetPixel(i + radius_x, j + radius_y);
                    Color col = my_tex.GetPixel(i + radius_x, j + radius_y);

                    switch (mode)
                    {
                        case Mode.Eliminate:
                            if (col.a != 0f && mask_col.a == 0)
                            {
                                float a = col.a - strength;
                                a = a <= 0 ? 0.0f : a;
                                col.a = a;
                                if (a <= 0)
                                {
                                    colorA++;
                                }
                                
                            }
                            break;
                        case Mode.Fill:
                            if (col.a == 0f && mask_col.a == 0)
                            {
                                float a = col.a + strength;
                                a = a >= 1 ? 1.0f : a;
                                col.a = a;
                                colorA++;
                            }
                            break;
                    }

                    my_tex.SetPixel(i + radius_x, j + radius_y, col);
                    if (null != touch_id)
                    {
                        record[i + "_" + j] = touch_id;
                    }
                }
            }

            my_tex.Apply();
            fate = colorA / maxColorA;
            if (fate >= finish_fate)
            {
                is_finish = true;
                if (null != finish_func)
                {
                    finish_func();
                }
            }
        }
    }


    public void CheckBrush(Vector3 worldPos, string touch_id = null)
    {
        if (is_finish) { return; }
        Vector3 localPos = uiTex.gameObject.transform.InverseTransformPoint(worldPos);
        int radius_x = (int)Mathf.Ceil(mWidth / 2);
        int radius_y = (int)Mathf.Ceil(mHeight / 2);
        int brush_radius_x = (int)Mathf.Ceil(brush_tex.width* uiTex_brush.transform.localScale.x/ 2);
        int brush_radius_y = (int)Mathf.Ceil(brush_tex.height* uiTex_brush.transform.localScale.y / 2);
        if (localPos.x > -radius_x && localPos.x < radius_x && localPos.y > -radius_y && localPos.y < radius_y)
        {
            for (int i = (int)Mathf.Floor(localPos.x - brush_radius_x); i < Mathf.Floor(localPos.x + brush_radius_x); i++)
            {
                for (int j = (int)Mathf.Floor(localPos.y - brush_radius_y); j < Mathf.Floor(localPos.y + brush_radius_y); j++)
                {
                    if (record.ContainsKey(i + "_" + j))
                    {
                        if (record[i + "_" + j] == touch_id) { continue; }
                    }

                    //int x = (int)(i + brush_radius_x / uiTex_brush.transform.localScale.x);
                    //int y = (int)(j + brush_radius_y / uiTex_brush.transform.localScale.y);


                    int x = (int)(i - localPos.x + brush_radius_x / uiTex_brush.transform.localScale.x);
                    int y = (int)(j - localPos.y + brush_radius_y / uiTex_brush.transform.localScale.y);
                    Color brush_col = brush_tex.GetPixel(x, y);
                    if (brush_col.a == 1f) {
                        continue;
                    }
                    if (Mathf.Abs(i) > radius_x) { continue; }
                    if (Mathf.Abs(j) > radius_y) { continue; }



                    Color mask_col = mask_tex.GetPixel(i + radius_x, j + radius_y);
                    Color col = my_tex.GetPixel(i + radius_x, j + radius_y);

                    switch (mode)
                    {
                        case Mode.Eliminate:
                            if (col.a != 0f && mask_col.a == 0)
                            {
                                float a = col.a - strength;
                                a = a <= 0 ? 0.0f : a;
                                col.a = a;
                                if (a <= 0)
                                {
                                    colorA++;
                                }

                            }
                            break;
                        case Mode.Fill:
                            if (col.a == 0f && mask_col.a == 0)
                            {
                                float a = col.a + strength;
                                a = a >= 1 ? 1.0f : a;
                                col.a = a;
                                colorA++;
                            }
                            break;
                    }

                    my_tex.SetPixel(i + radius_x, j + radius_y, col);
                    if (null != touch_id)
                    {
                        record[i + "_" + j] = touch_id;
                    }

                }
            }
        }

        my_tex.Apply();
        fate = colorA / maxColorA;
        if (fate >= finish_fate)
        {
            is_finish = true;
            if (null != finish_func)
            {
                finish_func();
            }
        }
    }

    private Vector3 lastPos = new Vector3();
    public void CheckLine(Vector3 worldPos, string touch_id = null)
    {

        
        if (is_finish) { return; }
        Vector3 localPos = uiTex.gameObject.transform.InverseTransformPoint(worldPos);
        int radius_x = (int)Mathf.Ceil(mWidth / 2);
        int radius_y = (int)Mathf.Ceil(mHeight / 2);
        if (localPos.x > -radius_x && localPos.x < radius_x && localPos.y > -radius_y && localPos.y < radius_y)
        {

            if (Vector3.zero == lastPos)
            {
                lastPos = localPos;
                return;
            }
            else
            {
                int width = 30;
                if (localPos.y - lastPos.y != 0)
                {
                    double rad = Math.Atan((localPos.y - lastPos.y) / (localPos.x - lastPos.x));
                    Debug.Log("rad = " + rad + "    Math.Tan(rad) = " + Math.Tan(rad));
                    var start = localPos.x - lastPos.x < 0 ? localPos.x : lastPos.x;
                    var end = localPos.x - lastPos.x >= 0 ? localPos.x : lastPos.x;
                    for (int i = (int)start; i <= (int)end; i++)
                    {
                        for (int j = -width/2; j <= width/2; j++)
                        {
                            int x = i;
                            int y = j + (int)(x * Math.Tan(rad));

                            if (Mathf.Abs(x) > radius_x) { continue; }
                            if (Mathf.Abs(y) > radius_y) { continue; }

                            x = x + radius_x;
                            y = y + radius_y;

                            Color mask_col = mask_tex.GetPixel(x, y);
                            Color col = my_tex.GetPixel(x, y);

                            switch (mode)
                            {
                                case Mode.Eliminate:
                                    if (col.a != 0f && mask_col.a == 0)
                                    {
                                        float a = col.a - strength;
                                        a = a <= 0 ? 0.0f : a;
                                        col.a = a;
                                        if (a <= 0)
                                        {
                                            colorA++;
                                        }

                                    }
                                    break;
                                case Mode.Fill:
                                    if (col.a == 0f && mask_col.a == 0)
                                    {
                                        float a = col.a + strength;
                                        a = a >= 1 ? 1.0f : a;
                                        col.a = a;
                                        colorA++;
                                    }
                                    break;
                            }
                            my_tex.SetPixel(x, y, col);
                            if (null != touch_id)
                            {
                                record[i + "_" + j] = touch_id;
                            }
                        }
                    }

                    lastPos = localPos;

                    my_tex.Apply();
                    fate = colorA / maxColorA;
                    if (fate >= finish_fate)
                    {
                        is_finish = true;
                        if (null != finish_func)
                        {
                            finish_func();
                        }
                    }
                }
                
            }
        }
    }
}
