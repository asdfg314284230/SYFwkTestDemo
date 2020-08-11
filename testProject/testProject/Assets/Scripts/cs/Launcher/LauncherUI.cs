using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;

public class LauncherUI : MonoBehaviour {

    // 组件
    public Text tipText;
    public Text progressText;
    public Image progressImg;

    public Text dialogTitleText;
    public Text dialogContentText;
    public GameObject dialogObj;

    // 回调
    private Action dialogOKAction = null;
    private Action dialogCancelAction = null;
    private float delaySecond = 0;

    private bool isShowDialog = false;

    int count = 0;

	// Use this for initialization
	void Start () {
        isShowDialog = false;
        dialogObj.SetActive(false);
        setProgress(0,1, 0,true);
	}
	
	// Update is called once per frame
	void Update () {
	}

    public void setTip(string tip)
    {
        tipText.text = tip;
    }

    public void setProgress(float total, int current,int percent, bool type)
    {
        if (type == true)
        {
            progressText.text = current + "/" + total;
            //if (total == 0)
            //{
            //    progressImg.fillAmount = 0;
            //}
            //else
            //{
            //    progressImg.fillAmount = (current * 1.0f) / total;
            //}
        }
        else
        {
            //progressText.text = current + "/" + total;
            progressImg.fillAmount = total;
        }


    }

    public void showDialog(string title, string content, Action ok = null, Action cancel = null, float clickDelay = 0)
    {
        if (isShowDialog)
        {
            return;
        }

        isShowDialog = true;
        dialogOKAction = ok;
        dialogCancelAction = cancel;
        dialogTitleText.text = title;
        dialogContentText.text = content;
        delaySecond = clickDelay;

        dialogObj.SetActive(true);
    }

    public void onOKClicked()
    {
        dialogObj.SetActive(false);
        StartCoroutine(doOK());
    }

    private IEnumerator doOK()
    {
        yield return new WaitForSeconds(delaySecond);
        isShowDialog = false;
        if (dialogOKAction != null)
        {
            Debug.Log("onOKClicked");
            dialogOKAction();
        }
    }

    public void onCancelClicked()
    {
        dialogObj.SetActive(false);
        StartCoroutine(doCancel());
    }

    private IEnumerator doCancel()
    {
        yield return new WaitForSeconds(delaySecond);
        isShowDialog = false;
        if (dialogCancelAction != null)
        {
            Debug.Log("onCancelClicked");
            dialogCancelAction();
        }
    }
}
