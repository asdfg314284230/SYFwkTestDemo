using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using XLua;

public class UIScrollRect : ScrollRect
{
    public LuaFunction LuaOnBeginDrag;
    public LuaFunction LuaOnEndDrag;

    public override void OnBeginDrag(PointerEventData eventData)
    {
        base.OnBeginDrag(eventData);

        if (LuaOnBeginDrag != null)
        {
            LuaOnBeginDrag.Call();
        }
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        base.OnEndDrag(eventData);

        if (LuaOnEndDrag != null)
        {
            LuaOnEndDrag.Call();
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();

        if (LuaOnBeginDrag != null)
        {
            LuaOnBeginDrag.Dispose();
            LuaOnBeginDrag = null;
        }
        if (LuaOnEndDrag != null)
        {
            LuaOnEndDrag.Dispose();
            LuaOnEndDrag = null;
        }
    }

}
