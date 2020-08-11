using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using System;

namespace Flz.UI
{
    [RequireComponent(typeof(Image))]
    public class SpriteAnimation : MonoBehaviour
    {
        private Image spriteRenderer;
        private int mCurFrame = 0;
        private float mDelta = 0;

        public float FPS = 5;
        public List<Sprite> SpriteFrames;
        public bool IsPlaying = false;
        public bool Foward = true;
        public bool AutoPlay = false;
        public bool Loop = false;
        public bool AutoRemove = false;
        public Action<string> complete;

        public int FrameCount
        {
            get
            {
                return SpriteFrames.Count;
            }
        }

        void Awake()
        {
            spriteRenderer = GetComponent<Image>();
        }

        void Start()
        {
            if (AutoPlay)
            {
                Play();
            }
            else
            {
                IsPlaying = false;
            }
        }

        private void SetSprite(int idx)
        {
            spriteRenderer.sprite = SpriteFrames[idx];
            //ImageSource.SetNativeSize();
        }

        public void Play()
        {
            IsPlaying = true;
            Foward = true;
        }

        public void PlayReverse()
        {
            IsPlaying = true;
            Foward = false;
        }

        void Update()
        {
            if (!IsPlaying || 0 == FrameCount)
            {
                return;
            }

            mDelta += Time.deltaTime;
            if (mDelta > 1 / FPS)
            {
                mDelta = 0;
                if (Foward)
                {
                    mCurFrame++;
                }
                else
                {
                    mCurFrame--;
                }

                if (mCurFrame >= FrameCount)
                {
                    if (Loop)
                    {
                        mCurFrame = 0;
                    }
                    else
                    {
                        IsPlaying = false;
                        if (complete != null)
                        {
                            complete("foward");
                        }
                        if (AutoRemove)
                        {
                            DestroyObject(gameObject);
                        }
                        return;
                    }
                }
                else if (mCurFrame < 0)
                {
                    if (Loop)
                    {
                        mCurFrame = FrameCount - 1;
                    }
                    else
                    {
                        IsPlaying = false;
                        if (complete != null)
                        {
                            complete("aback");
                        }
                        if (AutoRemove)
                        {
                            DestroyObject(gameObject);
                        }
                        return;
                    }
                }

                SetSprite(mCurFrame);
            }
        }

        public void Pause()
        {
            IsPlaying = false;
        }

        public void Resume()
        {
            if (!IsPlaying)
            {
                IsPlaying = true;
            }
        }

        public void Stop()
        {
            mCurFrame = 0;
            SetSprite(mCurFrame);
            IsPlaying = false;
        }

        public void Rewind()
        {
            mCurFrame = 0;
            SetSprite(mCurFrame);
            Play();
        }

        public void SetCurFrame(int curFrame)
        {
            mCurFrame = curFrame;
        }


    }
}