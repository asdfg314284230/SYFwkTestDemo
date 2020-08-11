using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Flz.UI
{
    public class PageView : MonoBehaviour//, IBeginDragHandler, IEndDragHandler
    {
        ScrollRect rect;
        RectTransform rectRectTransform;
        RectTransform contentRectTransform;

        List<float> pageOffestList = new List<float>();
        int pageIndex = 0;
        int pageCount = 0;
        public bool unrestricted = true;

        public Action<int> func;
        public Action<float> rolling_func;
        public Action<float> drag_begin_func;
        public Action<float> drag_func;
        public Action<int> roll_finish_func;
        public Action<int> not_astrict_func;

        //缩放灵敏度
        public float scale_sensitivity = 10000f;

        //scale最小值
        public float scale_min = 0.9f;

        //翻页阈值
        public int overPixel = 30;

        //滑动速度
        public float smooting = 10;

        //滑动的起始坐标
        float targethorizontal = 0;

        float pageOffset = 0;

        //是否拖拽结束
        bool isDrag = false;

        //是否停止移动
        private bool stopMove = false;

        private float startTime;

        void Awake()
        {

            var trigger = transform.gameObject.GetComponent<EventTrigger>();
            if (trigger == null)
                trigger = transform.gameObject.AddComponent<EventTrigger>();

            // 实例化delegates
            trigger.triggers = new List<EventTrigger.Entry>();

            // 定义需要绑定的事件类型。并设置回调函数
            EventTrigger.Entry beginDragEntry = new EventTrigger.Entry();
            // 设置 事件类型
            beginDragEntry.eventID = EventTriggerType.BeginDrag;
            // 设置回调函数
            beginDragEntry.callback = new EventTrigger.TriggerEvent();
            UnityAction<BaseEventData> callback = new UnityAction<BaseEventData>(OnBeginDrag);
            beginDragEntry.callback.AddListener(callback);
            // 添加事件触发记录到GameObject的事件触发组件
            trigger.triggers.Add(beginDragEntry);

            // 定义需要绑定的事件类型。并设置回调函数
            EventTrigger.Entry dragEntry = new EventTrigger.Entry();
            // 设置 事件类型
            dragEntry.eventID = EventTriggerType.Drag;
            // 设置回调函数
            dragEntry.callback = new EventTrigger.TriggerEvent();
            UnityAction<BaseEventData> callback2 = new UnityAction<BaseEventData>(OnDrag);
            dragEntry.callback.AddListener(callback2);
            // 添加事件触发记录到GameObject的事件触发组件
            trigger.triggers.Add(dragEntry);

            // 定义需要绑定的事件类型。并设置回调函数
            EventTrigger.Entry endDragEntry = new EventTrigger.Entry();
            // 设置 事件类型
            endDragEntry.eventID = EventTriggerType.EndDrag;
            // 设置回调函数
            endDragEntry.callback = new EventTrigger.TriggerEvent();
            UnityAction<BaseEventData> callback1 = new UnityAction<BaseEventData>(OnEndDrag);
            endDragEntry.callback.AddListener(callback1);
            // 添加事件触发记录到GameObject的事件触发组件
            trigger.triggers.Add(endDragEntry);

            rect = transform.GetComponent<ScrollRect>();
            if (unrestricted)
            {
                rect.movementType = ScrollRect.MovementType.Unrestricted;
            }

            Reset(pageIndex);
            rect.decelerationRate = 0;

        }

        // Update is called once per frame
        void Update()
        {
            if (!isDrag && !stopMove)
            {
                //rect.horizontalNormalizedPosition = Mathf.Lerp(rect.horizontalNormalizedPosition, targethorizontal, Time.deltaTime * smooting);

                if (rolling_func != null)
                {
                    rolling_func(contentRectTransform.anchoredPosition.x);
                }

                startTime += Time.deltaTime;
                float t = startTime * smooting;
                //rect.horizontalNormalizedPosition = Mathf.Lerp(rect.horizontalNormalizedPosition, targethorizontal, t);
                float target_f = Mathf.Lerp(rect.horizontalNormalizedPosition, targethorizontal, t);
                //float x = -pageOffestList[pageOffestList.Count - 1] * target_f;
                float x = pageOffestList.Count == 0 ? 0 : -pageOffestList[pageOffestList.Count - 1] * target_f;
                contentRectTransform.localPosition = new Vector3(x, contentRectTransform.localPosition.y, contentRectTransform.localPosition.z);
                CheckPanelScale();
                if (t >= 1)
                {
                    stopMove = true;

                    if (roll_finish_func != null)
                    {
                        roll_finish_func(pageIndex);
                    }
                }


            }
        }

        public void OnBeginDrag(BaseEventData arg0)
        {
            //  Debug.Log("OnBeginDrag");
            isDrag = true;
            if (drag_begin_func != null)
            {
                drag_begin_func(contentRectTransform.anchoredPosition.x);
            }
        }

        public void OnDrag(BaseEventData arg0)
        {
            // Debug.Log("OnDrag");
            isDrag = true;
            CheckPanelScale();
            if (drag_func != null)
            {
                drag_func(contentRectTransform.anchoredPosition.x);
            }
        }

        public void OnEndDrag(BaseEventData arg0)
        {
            //  Debug.Log("OnEndDrag");
            isDrag = false;
            stopMove = false;
            startTime = 0;

            if (pageOffestList.Count == 0)
            {
                return;
            }
            float posX = rect.horizontalNormalizedPosition;
            float offset = (targethorizontal - posX) * (contentRectTransform.sizeDelta.x - rectRectTransform.rect.width); //rectRectTransform.sizeDelta.x);
            if (Math.Abs(offset) > overPixel)
            {
                int index = pageIndex;

                if (offset < 0 && index < pageCount - 1)
                {
                    index++;
                }
                else if (offset > 0 && index > 0)
                {
                    index--;
                }

                pageOffset = pageOffestList[index];
                targethorizontal = pageOffset / (contentRectTransform.sizeDelta.x - rectRectTransform.rect.width); //rectRectTransform.sizeDelta.x);

                if (pageIndex != index && func != null)
                {
                    func(index);
                }

                pageIndex = index;
            }
           
            if (not_astrict_func != null)
            {
                not_astrict_func(pageIndex);
            }
            
        }

        public void AddPageIndex()
        {
            SetPageIndex(pageIndex + 1);
        }

        public void SubPageIndex()
        {
            SetPageIndex(pageIndex - 1);
        }

        public void SetPageIndex(int index)
        {
            if (index >= 0 && index < pageCount)
            {
                isDrag = false;
                stopMove = false;
                startTime = 0;
                pageOffset = pageOffestList[index];
                targethorizontal = pageOffset / (contentRectTransform.sizeDelta.x - rectRectTransform.rect.width);
                if (pageIndex != index && func != null)
                {
                    func(index);
                }
                if (not_astrict_func != null)
                {
                    not_astrict_func(index);
                }
                pageIndex = index;
            }
        }

        public int GetPageIndex()
        {
            return pageIndex;
        }

        public int GetPageCount()
        {
            return pageCount;
        }

        public void AddPanel(RectTransform add_rect)
        {
            add_rect.SetParent(contentRectTransform);


            pageOffestList.Clear();
            float offx = 0;
            foreach (RectTransform rect in contentRectTransform)
            {
                pageOffestList.Add(offx + (rect.sizeDelta.x - rectRectTransform.rect.width) / 2);
                offx = offx + rect.sizeDelta.x;
            }


            contentRectTransform.sizeDelta = new Vector2(offx, contentRectTransform.sizeDelta.y);
            if (contentRectTransform.sizeDelta.x - rectRectTransform.rect.width <= 0)
            {
                for (int i = 0; i < pageOffestList.Count; i++)
                {
                    pageOffestList[i] = pageOffestList[i] + (rectRectTransform.rect.width - contentRectTransform.sizeDelta.x) / 2;
                }
                contentRectTransform.sizeDelta = new Vector2(rectRectTransform.rect.width + 2, contentRectTransform.sizeDelta.y);

            }
            pageCount++;

            pageOffset = pageOffestList[pageIndex];
            targethorizontal = pageOffset / (contentRectTransform.sizeDelta.x - rectRectTransform.rect.width); //rectRectTransform.sizeDelta.x);
            CheckPanelScale();
        }

        public void Reset(int index = 0)
        {
            pageOffestList.Clear();
            pageIndex = index;
            GameObject content = rect.content.gameObject;
            pageCount = content.transform.childCount;

            rectRectTransform = rect.GetComponent<RectTransform>();

            contentRectTransform = content.GetComponent<RectTransform>();
            contentRectTransform.anchorMax = new Vector2(0, 0.5f);
            contentRectTransform.anchorMin = new Vector2(0, 0.5f);
            contentRectTransform.sizeDelta = new Vector2(0, contentRectTransform.sizeDelta.y);




            float offx = 0;
            float last_width = 0;
            foreach (RectTransform rect in contentRectTransform)
            {
                pageOffestList.Add(offx + (rect.sizeDelta.x - rectRectTransform.rect.width) / 2);
                offx = offx + rect.sizeDelta.x;
                last_width = rect.sizeDelta.x;
            }

            contentRectTransform.sizeDelta = new Vector2(offx, contentRectTransform.sizeDelta.y);
            if (contentRectTransform.sizeDelta.x - rectRectTransform.rect.width <= 0)
            {
                for (int i = 0; i < pageOffestList.Count; i++)
                {
                    pageOffestList[i] = pageOffestList[i] + (rectRectTransform.rect.width - contentRectTransform.sizeDelta.x) / 2;
                }
                contentRectTransform.sizeDelta = new Vector2(rectRectTransform.rect.width + 2, contentRectTransform.sizeDelta.y);

            }
        }

        void CheckPanelScale()
        {
            foreach (RectTransform rect in contentRectTransform)
            {
                float off = Math.Abs(rectRectTransform.rect.width / 2 - (rect.anchoredPosition.x + contentRectTransform.anchoredPosition.x));
                float scale = 1 - off / scale_sensitivity;
                scale = scale > scale_min ? scale : scale_min;
                rect.localScale = new Vector3(scale, scale, scale);
            }
        }

    }
}