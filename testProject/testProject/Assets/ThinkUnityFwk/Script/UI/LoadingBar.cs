using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using XLua;

namespace Flz.UI
{
    public enum UiType
    {
        IMAGE,
        SLIDER
    }
    [Serializable]
    public class ActionFinishEvent : UnityEvent { }

    [Serializable]
    public class ValueChangeEvent : UnityEvent<float> { }
    /*
        加载进度的效果

     */
    [LuaCallCSharp]
    public class LoadingBar : MonoBehaviour
    {

        // Use this for initialization

        //效果的时间
        public float time = 1;
        //当等于整数的时候,是否自动归零
        [Header("当value=1时是否自动瞬间归零:")]
        public bool autoOneToZero = false;
        //多数作用于特效Gameobject
        [Header("多数作用于特效RectTransform:")]
        public RectTransform updateRt;
        [Header("是否为水平方向:")]
        public bool isHorizontal = true;
        //曲线
        [Space(10)]
        public LeanTweenType easeType = LeanTweenType.linear;
        //value改变回调
        public ValueChangeEvent valueChangeEvent = new ValueChangeEvent();
        //完成回调
        public ActionFinishEvent finishEvent = new ActionFinishEvent();

        Image image;
        Slider slider;
        UiType m_uitype = UiType.IMAGE;
        float m_value = 0;//ui当前的value
        float m_value_target = 0;//目标value
        float m_speed = 0;//速度
        bool m_dirty = false;
        bool m_init = false;

        void Start()
        {
            init();
            //测试效果代码
            // SetValue(1.8f);     
            // SetValue(-2.2f);

        }

        void init()
        {
            if (m_init)
            {
                return;
            }
            m_init = true;

            //优先取slider控件
            slider = GetComponent<Slider>();
            //没slider控件，就取下Image
            if (slider == null)
            {
                image = GetComponent<Image>();
                m_uitype = UiType.IMAGE;
            }
            else
            {
                m_uitype = UiType.SLIDER;
            }

            //都没就报错
            if (slider == null && image == null)
            {
                Debug.LogError("imgage and slider is null");
                return;
            }
            switch (m_uitype)
            {
                case UiType.IMAGE:
                    m_value = image.fillAmount;
                    break;
                case UiType.SLIDER:
                    m_value = slider.value;
                    break;
                default:
                    break;
            }
        }

        //新进度的value,
        //value>1时，进度会先满[ (int)value ]次 再到[ value - (int)value ] 例 1.4 =》0.4
        //value<0时，进度会先归0[-(int)value+1]次     例 -1.2 =》 0.8

        //BanAction 是否需要禁用加载效果
        public void SetValue(float value, bool BanAction = false)
        {
            init();
            //取消下原先的动作（防止原来有动作）
            LeanTween.cancel(gameObject);
            if (BanAction)
            {
                if (value > 1)
                {
                    value = value - (int)value; //截去整数部分 
                }
                setProgress(value);//更新UI
                return;
            }
            m_dirty = true;
            //计算下速度
            m_speed = (value - m_value) / time;
            m_value_target = value;
            var action = LeanTween.value(gameObject, m_value, value, time);
            //曲线类型
            action.setEase(easeType);
            //更新逻辑
            action.setOnUpdate(UpdateUI);

        }

        public float getValue()
        {
            return m_value;
        }


        void setProgress(float pro)
        {
            if (autoOneToZero)
            {
                pro = pro % 1;
            }

            m_value = pro;//记录下
            switch (m_uitype)
            {
                case UiType.IMAGE:
                    image.fillAmount = pro;
                    break;
                case UiType.SLIDER:
                    slider.value = pro;
                    break;
                default:
                    break;
            }
            valueChangeEvent.Invoke(pro);
            if (updateRt)
            {
                if(isHorizontal)
                {
                    updateRt.anchoredPosition = new Vector2(image.rectTransform.rect.size.x * pro, updateRt.anchoredPosition.y);
                }
                else
                {
                    updateRt.anchoredPosition = new Vector2(updateRt.anchoredPosition.x, -image.rectTransform.rect.size.y * pro);
                }
            }
        }

        void UpdateUI(float value)
        {
            if (!m_dirty)
            {
                return;
            }
            var value_t = value;
            //结束判断
            if ((m_speed > 0 && value_t >= m_value_target) ||
                m_speed < 0 && value_t <= m_value_target)
            {
                m_dirty = false;
                value_t = m_value_target;
            }

            if (value_t > 1)//满了就截取掉整数部分 speed > 0
            {
                value_t -= (int)value_t;
            }
            else if (value_t < 0)//归0 target就自增下  speed < 0
            {
                float change = -(int)value_t + 1; //-0.2=>1圈 -1.2=>2圈 
                value_t += change;
            }
            setProgress(value_t);//更新UI    
            if (!m_dirty) //结束了就调下完成回调
            {
                finishEvent.Invoke();
            }
        }
    }
}