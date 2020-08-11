using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Flz.UI
{
    public class AniBehaviour : MonoBehaviour
    {
        public Action<string> eventFunc;
        Animator m_Animator;

        private void Awake()
        {
            m_Animator = gameObject.GetComponent<Animator>();
        }
        // Use this for initialization
        void Start()
        {
            
        }

        // Update is called once per frame
        void Update()
        {

        }

        public void SetTrigger(string name)
        {
            m_Animator.SetTrigger(name);
        }

        public void SetInteger(string name, int i)
        {
            m_Animator.SetInteger(name, i);
        }

        public void Play(string name)
        {
            m_Animator.enabled = true;
            m_Animator.Play(name);
        }

        public void Play(string name, int layera, float normalizedTime)
        {
            m_Animator.enabled = true;
            m_Animator.Play(name, layera, normalizedTime);
        }

        public void Stop()
        {
            m_Animator.enabled = false;
        }
        

        public void ani_event(string eventName)
        {
            if (eventFunc != null)
            {
                eventFunc(eventName);
            }
        }
    }
}

