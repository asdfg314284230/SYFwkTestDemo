using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Flz.UI
{
    public class ButtonEx : UnityEngine.EventSystems.EventTrigger
    {
        public Action<PointerEventData> on_pointer_down;
        public Action<PointerEventData> on_pointer_up;
        public Action<PointerEventData> on_pointer_click;
        public Action<PointerEventData> on_begin_drag;
        public Action<PointerEventData> on_drag;
        public Action<PointerEventData> on_end_drag;
        public Action<float> updata;


        bool is_press = false;

        void Update()
        {
            if (is_press)
            {
                if (updata != null)
                {
                    updata(Time.deltaTime);
                }
            }
        }

        public override void OnPointerClick(PointerEventData eventData)
        {
            is_press = false;
            if (on_pointer_click != null)
            {
                on_pointer_click(eventData);
            }
        }

        public override void OnPointerDown(PointerEventData eventData)
        {
            is_press = true;
            if (on_pointer_down != null)
            {
                on_pointer_down(eventData);
            }
        }

        public override void OnPointerUp(PointerEventData eventData)
        {
            is_press = false;
            if (on_pointer_up != null)
            {
                on_pointer_up(eventData);
            }
        }

        public override void OnBeginDrag(PointerEventData eventData)
        {

            if (on_begin_drag != null)
            {
                on_begin_drag(eventData);
            }
            ExecuteEvents.ExecuteHierarchy<IBeginDragHandler>(transform.parent.gameObject, eventData, ExecuteEvents.beginDragHandler);
        }

        public override void OnDrag(PointerEventData eventData)
        {
            if (on_drag != null)
            {
                on_drag(eventData);
            }
            ExecuteEvents.ExecuteHierarchy<IDragHandler>(transform.parent.gameObject, eventData, ExecuteEvents.dragHandler);
        }

        public override void OnEndDrag(PointerEventData eventData)
        {
            if (on_end_drag != null)
            {
                on_end_drag(eventData);
            }
            ExecuteEvents.ExecuteHierarchy<IEndDragHandler>(transform.parent.gameObject, eventData, ExecuteEvents.endDragHandler);
        }

    }
}