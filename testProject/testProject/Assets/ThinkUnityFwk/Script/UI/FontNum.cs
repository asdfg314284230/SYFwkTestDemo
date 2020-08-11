using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Flz.UI
{
    public class FontNum : MonoBehaviour
    {
        public string num;
        public float interval = 0; //间隔
        public TextAnchor alignment = TextAnchor.MiddleCenter;//对齐方式

        public Sprite[] sprites;
        public Sprite add_sprite;
        public Sprite sub_sprite;
        public Sprite point_sprite;
        public Sprite slash_sprite;
        public Sprite parenthesis_l;
        public Sprite parenthesis_r;


        List<GameObject> sp_list = new List<GameObject>();//数字
        HorizontalLayoutGroup layout;
        GameObject go_cache;
        bool init = false; //是否初始化


        void Awake()
        {
            InitAll();
        }

        void Start()
        {

        }

        //初始化所有东西
        void InitAll()
        {
            if (!Application.isPlaying) //编辑状态都会重新初始化
            {
                init = false;
            }

            if (init)
            {
                return;
            }
            init = true;
            clear();
            //加一个对齐布局
            if (!GetComponent<HorizontalLayoutGroup>())
            {
                gameObject.AddComponent<HorizontalLayoutGroup>();
            }

            layout = gameObject.GetComponent<HorizontalLayoutGroup>();
            layout.spacing = interval;
            layout.childControlHeight = false;
            layout.childControlWidth = false;
            layout.childForceExpandHeight = false;
            layout.childForceExpandWidth = false;

            if (!transform.Find("font_cache"))
            {
                go_cache = new GameObject("font_cache"); //缓存
                go_cache.transform.SetParent(transform);
                go_cache.transform.localPosition = Vector3.zero;
            }

            //对齐方式
            layout.childAlignment = alignment;

            if (Application.isPlaying) //运行状态初始化时显示下当前的数字
            {
                SetString(num);
            }

        }


        //根据显示的内容调整FontNum的RectTransform的大小
        public void AutoSize()
        {
            float width = 0;
            float height = 0;
            foreach (var sp in sp_list)
            {
                if (sp.gameObject.activeSelf)
                {
                    if (width == 0)
                    {
                        width += sp.GetComponent<RectTransform>().sizeDelta.x;
                    }
                    else
                    {
                        width += sp.GetComponent<RectTransform>().sizeDelta.x + interval;
                    }
                    if (height < sp.GetComponent<RectTransform>().sizeDelta.y)
                    {
                        height += sp.GetComponent<RectTransform>().sizeDelta.y;
                    }
                }
            }
            gameObject.GetComponent<RectTransform>().sizeDelta = new Vector2(width, height);
        }

        public String GetString()
        {
            return num;
        }

        public void SetString(string num)
        {
            InitAll();

            this.num = num;
            foreach (var sp in sp_list) //回收下
            {
                sp.SetActive(false);
                sp.transform.SetParent(go_cache.transform); //加到缓存节点中
            }

            int count = 0;
            if (!string.IsNullOrEmpty(num))
            {
                foreach (char c in num)
                {
                    Sprite sp = null;
                    int index;
                    bool res = int.TryParse(c.ToString(), out index);
                    if (res && !string.IsNullOrEmpty(c.ToString()) && sprites.Length > index)
                    {
                        sp = sprites[index];
                    }
                    else
                    {
                        switch (c)
                        {
                            case '+':
                                sp = add_sprite;
                                break;
                            case '-':
                                sp = sub_sprite;
                                break;
                            case '.':
                                sp = point_sprite;
                                break;
                            case '/':
                                sp = slash_sprite;
                                break;
                            case '(':
                                sp = parenthesis_l;
                                break;
                            case ')':
                                sp = parenthesis_r;
                                break;
                        }
                    }

                    if (null != sp)
                    {
                        GameObject image_ob = GetFontSp(count);     //换图   
                        Image image = image_ob.GetComponent<Image>();
                        image.sprite = sp;
                        image.SetNativeSize();
                        count++;
                    }

                }
            }

            //重新布局
            LayoutRebuilder.ForceRebuildLayoutImmediate(GetComponent<RectTransform>());
        }

        GameObject GetFontSp(int index)
        {

            if (sp_list.Count <= index)
            {
                GameObject image_ob = new GameObject(string.Format("font_num_{0}", index));
                image_ob.AddComponent<RectTransform>();
                image_ob.AddComponent<Image>();
                image_ob.transform.SetParent(go_cache.transform); //加到缓存节点中          
                sp_list.Add(image_ob);
            }

            sp_list[index].transform.SetParent(transform);//加到节点中
            sp_list[index].transform.localScale = new Vector3(1, 1, 1);
            sp_list[index].transform.localPosition = Vector3.zero;
            sp_list[index].SetActive(true);

            return sp_list[index];
        }

        //清除子节点跟初始化变量
        public void clear()
        {
            //把子节点全清了
            List<Transform> lis = new List<Transform>();
            for (int index = 0; index < transform.childCount; index++)
            {
                lis.Add(transform.GetChild(index));
            }

            foreach (var child in lis)
            {
                GameObject.DestroyImmediate(child.gameObject);
            }

            if (sp_list == null) //重新初始化下LIST
            {
                sp_list = new List<GameObject>();
            }
            sp_list.Clear();

        }
    }
}