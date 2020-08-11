using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

/*
 * 点击组件
 */

public class Click : MonoBehaviour, IPointerUpHandler, IPointerDownHandler
{
    [HideInInspector]
    public ClickEvent onClickDown;
    [HideInInspector]
    public ClickEvent onClickUp;

    // 点击回调事件
    public class ClickEvent : UnityEvent<BaseEventData>
    {
    }

    public Click()
    {
        onClickDown = new ClickEvent();
        onClickUp = new ClickEvent();
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        onClickDown.Invoke(eventData);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        onClickUp.Invoke(eventData);
    }
}
