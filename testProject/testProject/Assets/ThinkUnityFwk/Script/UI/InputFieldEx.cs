using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System.Text;
using System;
using UnityEngine.Serialization;
using XLua;

namespace Flz.UI
{
    public class InputFieldEx : InputField
    {
        private LuaFunction LuaDone;

        public void AddDoneEvent(LuaFunction done)
        {
            LuaDone = done;
        }

        void Update()
        {
            if (m_Keyboard != null && m_Keyboard.done && !m_Keyboard.wasCanceled)
            {
                if(LuaDone != null)
                {
                    LuaDone.Call();
                }
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();

            if(LuaDone != null)
            {
                LuaDone.Dispose();
                LuaDone = null;
            }
        }

        [HideInInspector]
        public PressEvent BeginEdit; //开始编辑时的委托

        bool IsEdit = false;  //是否编辑中
        public InputFieldEx()
        {
            BeginEdit = new PressEvent();
        }

        protected override void Start()
        {
            base.Start();
            onEndEdit.AddListener(EndEdit);
        }

        //将剪贴板的内容复制到输入内容中
        public void CopyClipboardToText()
        {
            text = GUIUtility.systemCopyBuffer;
        }

        public override void OnPointerDown(PointerEventData eventData)
        {
            base.OnPointerDown(eventData);

            if (!IsEdit)
            {
                IsEdit = true;
                BeginEdit.Invoke();
            }
        }

        void EndEdit(string str)
        {
            IsEdit = false;
        }


        public class PressEvent : UnityEvent
        {
        }
    }
}