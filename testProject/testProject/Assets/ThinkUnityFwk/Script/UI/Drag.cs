using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

/*
 * 拖拽组件
 */

public class Drag : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    [HideInInspector]
    public DragEvent onDragBegin;
    [HideInInspector]
    public DragEvent onDrag;
    [HideInInspector]
    public DragEvent onDragEnd;

    public class DragEvent : UnityEvent<BaseEventData>
    {
    }

    public Drag()
    {
        onDragBegin = new DragEvent();
        onDrag = new DragEvent();
        onDragEnd = new DragEvent();
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        onDragBegin.Invoke(eventData);
    }
    public void OnDrag(PointerEventData eventData)
    {
        onDrag.Invoke(eventData);
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        onDragEnd.Invoke(eventData);
    }

    
}
