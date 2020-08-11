using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;
using XLua;

[LuaCallCSharp]
public class UIFastGrid : LayoutGroup, ILayoutSelfController
{
    public enum Constraint { FixedRowCount = 0, FixedColumnCount = 1 }

    public Vector2 CellSize = new Vector2(100, 100);

    public Vector2 Spacing = Vector2.zero;

    public Vector2 Offset = Vector2.zero;

    public Constraint ConstraintType = Constraint.FixedColumnCount;

    public int ConstraintCount = 1;

    public long FocusID = 0;

    public bool AlwaysRefresh = false;

    // 手动设置的ViewPort高度或宽度值，此值<=0时使用viewport的自身值
    public float ViewPortValue = 0;

    // item的高度或者宽度是可变的，ConstraintCount只能为1，需要设置最小值
    public bool Changeable = false;
    public float MinCellSize = 10;

    public FastGridItem[] GridItems = null;

    public ScrollRect mScrollRect;

    protected bool mReposition = false;
    public bool RepositionNow
    {
        set { if (value) { mReposition = true; enabled = true; } }
        get { return mReposition; }
    }
    // ClearData后执行所有刷新
    public bool RefreshAll = false;

    private List<FastGridItemData> datas = new List<FastGridItemData>();
    private int dataCount = 0;

    public bool Small2Large = false;

    private bool initFlag = false;

    public int GetDataCount()
    {
        if (datas == null) return 0;
        return datas.Count;
    }

    public LuaTable GetLuaDataByIndex(int index)
    {
        if (datas == null) return null;
        if (index < datas.Count && index >= 0) return datas[index].LuaDataTable;
        return null;
    }

    public LuaTable GetLuaDataByDataID(int id)
    {
        if (datas == null) return null;
        for (int i = 0; i < datas.Count; i++)
        {
            if (datas[i] != null && datas[i].ID == id)
            {
                return datas[i].LuaDataTable;
            }
        }
        return null;
    }

    private float originContentPosX;
    private float originContentPosY;
    private int maxCount;
    private bool initDone = false;
    public GameObject OriginalPrefab;

    private LuaFunction LuaInitItem;
    private LuaFunction LuaRefresh;

    public LuaFunction LuaRepositionEnd;

    public LuaFunction LuaOnValueChanged;

    // 数据显示、隐藏回调
    // TODO: 目前只实现了 FixedColumnCount、Changeable == false
    public LuaFunction LuaShowData;
    public LuaFunction LuaHideData;
    public float refreshTopOffSetY = 0;
    public float refreshBottomOffSetY = 0;

    private void Init(bool repos = true)
    {
        if (initDone) return;

        initDone = true;

        if(mScrollRect == null)
        {
            mScrollRect = transform.GetComponentInParent<ScrollRect>();
        }

        if(mScrollRect == null)
        {
            Debug.LogError("Can't find the ScrollRect");
            return;
        }

        mScrollRect.onValueChanged.AddListener(OnValueChanged);
        mScrollRect.LayoutComplete();

        originContentPosX = rectTransform.transform.localPosition.x;
        originContentPosY = rectTransform.transform.localPosition.y;

        float oneSize = 0;
        if (Changeable)
        {
            oneSize = MinCellSize;
            switch (ConstraintType)
            {
                case Constraint.FixedRowCount:
                    oneSize += Spacing.x;
                    break;
                case Constraint.FixedColumnCount:
                    oneSize += Spacing.y;
                    break;
            }

            ConstraintCount = 1;
        }
        else
        {
            switch (ConstraintType)
            {
                case Constraint.FixedRowCount:
                    oneSize = CellSize.x + Spacing.x;
                    break;
                case Constraint.FixedColumnCount:
                    oneSize = CellSize.y + Spacing.y;
                    break;
            }
        }

        if (ViewPortValue <= 0)
        {
            switch (ConstraintType)
            {
                case Constraint.FixedRowCount:
                    ViewPortValue = mScrollRect.viewport.rect.size.x;
                    break;
                case Constraint.FixedColumnCount:
                    ViewPortValue = mScrollRect.viewport.rect.size.y;
                    break;
            }
        }

        maxCount = Mathf.CeilToInt(ViewPortValue / oneSize) + 1;
        GridItems = new FastGridItem[maxCount * ConstraintCount];

        if (repos)
        {
            Reposition();
        }

        enabled = false;
    }

    private void InitContentSize()
    {
        m_Tracker.Clear();

        float x = 0, y = 0, offset = 0;

        if (Changeable)
        {
            switch (ConstraintType)
            {
                case Constraint.FixedRowCount:
                    y = Spacing.x;
                    offset = Offset.x;

                    m_Tracker.Add(this, rectTransform, DrivenTransformProperties.SizeDeltaX);
                    break;
                case Constraint.FixedColumnCount:
                    y = Spacing.y;
                    offset = Offset.y;

                    m_Tracker.Add(this, rectTransform, DrivenTransformProperties.SizeDeltaY);
                    break;
            }

            for (int i = 0; i < datas.Count; ++i)
            {
                x += GetDataCellSizeValue(i);
            }

            rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)ConstraintType, x + (dataCount) * y + offset);
        }
        else
        {
            switch (ConstraintType)
            {
                case Constraint.FixedRowCount:
                    x = CellSize.x;
                    y = Spacing.x;
                    offset = Offset.x;

                    m_Tracker.Add(this, rectTransform, DrivenTransformProperties.SizeDeltaX);
                    break;
                case Constraint.FixedColumnCount:
                    x = CellSize.y;
                    y = Spacing.y;
                    offset = Offset.y;

                    m_Tracker.Add(this, rectTransform, DrivenTransformProperties.SizeDeltaY);
                    break;

            }
            rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)ConstraintType, (dataCount / ConstraintCount + (dataCount % ConstraintCount > 0 ? 1 : 0)) * (x + y) + offset);
        }
    }

    protected override void OnDestroy()
    {
        if (LuaInitItem != null)
        {
            LuaInitItem.Dispose();
            LuaInitItem = null;
        }
        if (LuaRefresh != null)
        {
            LuaRefresh.Dispose();
            LuaRefresh = null;
        }
        if (LuaRepositionEnd != null)
        {
            LuaRepositionEnd.Dispose();
            LuaRepositionEnd = null;
        }

        if (LuaOnValueChanged != null)
        {
            LuaOnValueChanged.Dispose();
            LuaOnValueChanged = null;
        }

        if (LuaHideData != null)
        {
            LuaHideData.Dispose();
            LuaHideData = null;
        }

        if (LuaShowData != null)
        {
            LuaShowData.Dispose();
            LuaShowData = null;
        }

        for (int i = 0; i < datas.Count; ++i)
        {
            if (datas[i] != null && datas[i].LuaDataTable != null)
            {
                datas[i].LuaDataTable.Dispose();
                datas[i].LuaDataTable = null;
            }
        }
        datas.Clear();

        ClearGridItem();

        if (mScrollRect)
            mScrollRect.onValueChanged.RemoveListener(OnValueChanged);
    }

    private void OnValueChanged(Vector2 delta)
    {
        if (!initDone) return;
        Reposition(false);

        if (LuaOnValueChanged != null)
        {
            LuaOnValueChanged.Call();
        }
    }

    private void Update()
    {
        if (!Application.isPlaying) return;

        if (!initDone) return;

        if (mReposition)
        {
            Reposition();
        }

        enabled = false;
    }

    private float GetDataCellSizeValue(int index)
    {
        if (datas == null || index >= datas.Count) return MinCellSize;
        return Mathf.Max(datas[index].SizeValue, MinCellSize);
    }

    [ContextMenu("Execute")]
    public void Reposition()
    {
        Reposition(true, false);
    }

    public void PhoneReposition()
    {
        Reposition(true, true);
    }

    private void Reposition(bool sort = true, bool sendEndEvent = false)
    {
        if (!initDone) Init(false);

        if (mScrollRect == null)
        {
            Debug.LogError("Can't find the ScrollRect");
            return;
        }

        // 默认 调用 reposition 的都排序
        if (mReposition)
        {
            sort = true;
            mReposition = false;
        }

        if (dataCount != datas.Count)
        {
            dataCount = datas.Count;
            InitContentSize();

            for (int i = 0; i < GridItems.Length; ++i)
            {
                if (GridItems[i] != null && GridItems[i].gameObject.activeInHierarchy)
                {
                    GridItems[i].gameObject.SetActive(false);
                }
            }
        }

        if (datas.Count == 0)
        {
            return;
        }

        if (sort)
        {
            Sort(datas);
        }

        if (FocusID != 0)
        {
            if (Changeable)
            {
                float offsetValue = 0;
                switch (ConstraintType)
                {
                    case Constraint.FixedRowCount:
                        for (int i = 0; i < datas.Count; ++i)
                        {
                            if (datas[i].ID == FocusID) break;
                            offsetValue += GetDataCellSizeValue(i) + Spacing.x;
                        }
                        offsetValue /= (rectTransform.rect.width - mScrollRect.viewport.rect.width);
                        SetHorizontalNormalizedPosition(Mathf.Clamp01(1 - offsetValue));
                        break;
                    case Constraint.FixedColumnCount:
                        for (int i = 0; i < datas.Count; ++i)
                        {
                            if (datas[i].ID == FocusID) break;
                            offsetValue += GetDataCellSizeValue(i) + Spacing.y;
                        }
                        offsetValue /= (rectTransform.rect.height - mScrollRect.viewport.rect.height);
                        SetVerticalNormalizedPosition(Mathf.Clamp01(1 - offsetValue));
                        break;
                }
            }
            else
            {
                int row = (GetDataIndex(FocusID) + ConstraintCount) / ConstraintCount;
                int total = (datas.Count + ConstraintCount - 1) / ConstraintCount;

                switch (ConstraintType)
                {
                    case Constraint.FixedRowCount:
                        float offsetX = (row - 1) * (CellSize.x + Spacing.x) / (total * (CellSize.x + Spacing.x) - mScrollRect.viewport.rect.width);
                        SetHorizontalNormalizedPosition(Mathf.Clamp01(1 - offsetX));
                        break;
                    case Constraint.FixedColumnCount:
                        float offsetY = (row - 1) * (CellSize.y + Spacing.y) / (total * (CellSize.y + Spacing.y) - mScrollRect.viewport.rect.height);
                        SetVerticalNormalizedPosition(Mathf.Clamp01(1 - offsetY));
                        break;
                }
            }

            FocusID = 0;
        }

        switch (ConstraintType)
        {
            case Constraint.FixedRowCount:
                {
                    float offset = originContentPosX - rectTransform.transform.localPosition.x;
                    int indexRow = -1;

                    int uiIndex = 0;
                    int rowIndex = 0;

                    if (Changeable)
                    {
                        float offsetPos = Offset.x;
                        for (int i = 0; i < datas.Count; ++i)
                        {
                            offsetPos += GetDataCellSizeValue(i);
                            if (offsetPos > offset)
                            {
                                indexRow = i;
                                break;
                            }
                            offsetPos += Spacing.x;
                        }

                        if (indexRow < 0) return;

                        offsetPos -= GetDataCellSizeValue(indexRow);
                        for (int i = 0; i < maxCount; ++i)
                        {
                            rowIndex = indexRow + i;

                            if (rowIndex >= dataCount)
                            {
                                break;
                            }

                            // ConstraintCount must equal 1
                            uiIndex = rowIndex % (maxCount * ConstraintCount);

                            if (uiIndex >= 0 && uiIndex < GridItems.Length)
                            {
                                if (GridItems[uiIndex] == null)
                                {
                                    GridItems[uiIndex] = CreateGridItem(uiIndex);
                                    SetGridItemSize(GridItems[uiIndex]);
                                }

                                if (!GridItems[uiIndex].gameObject.activeInHierarchy)
                                {
                                    GridItems[uiIndex].gameObject.SetActive(true);
                                }

                                GridItems[uiIndex].transform.localPosition = new Vector3(offsetPos, -Offset.y, 0);
                                RefreshItem(GridItems[uiIndex], datas[rowIndex]);
                            }

                            offsetPos += GetDataCellSizeValue(rowIndex) + Spacing.x;
                        }
                    }
                    else
                    {
                        indexRow = Mathf.FloorToInt((offset - Offset.x) / (CellSize.x + Spacing.x));
                        int dataIndex = 0;

                        for (int i = 0; i < maxCount; i++)
                        {
                            rowIndex = indexRow + i;
                            for (int j = 0; j < ConstraintCount; j++)
                            {
                                dataIndex = rowIndex * ConstraintCount + j;
                                if (dataIndex >= dataCount)
                                {
                                    break;
                                }
                                uiIndex = dataIndex % (maxCount * ConstraintCount);

                                if (uiIndex >= 0 && uiIndex < GridItems.Length)
                                {
                                    if (GridItems[uiIndex] == null)
                                    {
                                        GridItems[uiIndex] = CreateGridItem(uiIndex);
                                        SetGridItemSize(GridItems[uiIndex]);
                                    }

                                    if (!GridItems[uiIndex].gameObject.activeInHierarchy)
                                    {
                                        GridItems[uiIndex].gameObject.SetActive(true);
                                    }

                                    GridItems[uiIndex].transform.localPosition = new Vector3(Offset.x + rowIndex * (CellSize.x + Spacing.x), -Offset.y - j * (CellSize.y + Spacing.y), 0);
                                    RefreshItem(GridItems[uiIndex], datas[dataIndex]);
                                }
                            }
                        }
                    }
                }
                break;
            case Constraint.FixedColumnCount:
                {
                    float offset = rectTransform.transform.localPosition.y - originContentPosY;

                    int indexRow = -1;

                    int uiIndex = 0;
                    int rowIndex = 0;

                    if (Changeable)
                    {
                        float offsetPos = Offset.y;
                        for (int i = 0; i < datas.Count; ++i)
                        {
                            offsetPos += GetDataCellSizeValue(i);
                            if (offsetPos > offset)
                            {
                                indexRow = i;
                                break;
                            }
                            offsetPos += Spacing.y;
                        }

                        if (indexRow < 0) return;

                        offsetPos -= GetDataCellSizeValue(indexRow);
                        for (int i = 0; i < maxCount; ++i)
                        {
                            rowIndex = indexRow + i;

                            if (rowIndex >= dataCount)
                            {
                                break;
                            }

                            // ConstraintCount must equal 1
                            uiIndex = rowIndex % (maxCount * ConstraintCount);

                            if (uiIndex >= 0 && uiIndex < GridItems.Length)
                            {
                                if (GridItems[uiIndex] == null)
                                {
                                    GridItems[uiIndex] = CreateGridItem(uiIndex);
                                    SetGridItemSize(GridItems[uiIndex]);
                                }

                                if (!GridItems[uiIndex].gameObject.activeInHierarchy)
                                {
                                    GridItems[uiIndex].gameObject.SetActive(true);
                                }

                                GridItems[uiIndex].transform.localPosition = new Vector3(Offset.x, -offsetPos, 0);
                                RefreshItem(GridItems[uiIndex], datas[rowIndex]);
                            }

                            offsetPos += GetDataCellSizeValue(rowIndex) + Spacing.y;
                        }
                    }
                    else
                    {
                        indexRow = Mathf.FloorToInt((offset - Offset.y) / (CellSize.y + Spacing.y));
                        int dataIndex = 0;

                        for (int i = 0; i < maxCount; ++i)
                        {
                            rowIndex = indexRow + i;

                            for (int j = 0; j < ConstraintCount; ++j)
                            {
                                dataIndex = rowIndex * ConstraintCount + j;

                                if (dataIndex >= dataCount)
                                {
                                    break;
                                }

                                uiIndex = dataIndex % (maxCount * ConstraintCount);

                                if (uiIndex >= 0 && uiIndex < GridItems.Length)
                                {
                                    if (GridItems[uiIndex] == null)
                                    {
                                        GridItems[uiIndex] = CreateGridItem(uiIndex);
                                        SetGridItemSize(GridItems[uiIndex]);
                                    }

                                    if (!GridItems[uiIndex].gameObject.activeInHierarchy)
                                    {
                                        GridItems[uiIndex].gameObject.SetActive(true);
                                    }

                                    GridItems[uiIndex].transform.localPosition = new Vector3(Offset.x + j * (CellSize.x + Spacing.x), -Offset.y - rowIndex * (CellSize.y + Spacing.y), 0);
                                    RefreshItem(GridItems[uiIndex], datas[dataIndex]);
                                }
                            }
                        }

                        for (int i = 0; i < GridItems.Length; ++i)
                        {
                            if (GridItems[i] == null || GridItems[i].Data == null) continue;

                            // 位置太低 没有显示
                            if (GridItems[i].transform.localPosition.y + this.transform.localPosition.y + ViewPortValue - Offset.y - refreshBottomOffSetY <= 0 || GridItems[i].transform.localPosition.y + this.transform.localPosition.y - refreshTopOffSetY - Offset.y >= 0)
                            {
                                HideData(GridItems[i].Data);
                            }
                            else
                            {
                                ShowData(GridItems[i].Data);
                            }
                        }
                    }
                }
                break;
        }

        if (RefreshAll) RefreshAll = false;

        if (sendEndEvent && LuaRepositionEnd != null)
        {
            LuaRepositionEnd.Call();
        }
    }

    public bool CheckDataIsShow(LuaTable data)
    {
        for (int i = 0; i < GridItems.Length; ++i)
        {
            if (GridItems[i] == null || GridItems[i].Data == null) continue;

            // 位置太低 没有显示
            if (GridItems[i].transform.localPosition.y + this.transform.localPosition.y + ViewPortValue - Offset.y - refreshBottomOffSetY > 0 && GridItems[i].transform.localPosition.y + this.transform.localPosition.y - refreshTopOffSetY - Offset.y < 0)
            {
                if (data == GridItems[i].Data.LuaDataTable)
                {
                    return true;
                }
            }
        }
        return false;
    }

    private FastGridItem CreateGridItem(int uiIndex)
    {
        if (OriginalPrefab == null)
        {
            Debug.LogError("no prefab!");
             return null;
        }

        if (initFlag == false)
        {
            initFlag = true;
        }

        GameObject objItem = GameObject.Instantiate(OriginalPrefab, Vector3.zero, Quaternion.identity, this.transform);
        objItem.SetActive(true);
        objItem.name = OriginalPrefab.name;

        RectTransform rect = objItem.GetComponent<RectTransform>();
        if (rect == null)
        {
            Debug.LogErrorFormat("{0} GetCompoinent<RectTransform> is null",
                objItem.gameObject.name);
        }
        else
        {
            //rect.anchorMin = Vector2.up;
            //rect.anchorMax = Vector2.up;
            rect.pivot = Vector2.up;
        }

        rect.SetAsFirstSibling();

        FastGridItem item = objItem.AddComponent<FastGridItem>();
        item.Index = uiIndex;

        InitItem(item);

        return item;
    }

    private void SetGridItemSize(FastGridItem item)
    {
        if (item == null) return;

        RectTransform rect = item.GetComponent<RectTransform>();

        if (rect == null)
        {
            Debug.LogErrorFormat("{0} GetCompoinent<RectTransform> is null",
                item.gameObject.name);
            return;
        }

        // 设置items的大小
        if (!Changeable)
        {
            rect.sizeDelta = CellSize;
        }
    }

    public void RegisterLuaFunction(LuaFunction init, LuaFunction refresh, LuaFunction reposEnd = null)
    {
        LuaInitItem = init;
        LuaRefresh = refresh;
        LuaRepositionEnd = reposEnd;
    }

    public void InitDragEvent(LuaFunction startDrag, LuaFunction endDrag)
    {
        if (mScrollRect == null) return;

        UIScrollRect sr = mScrollRect as UIScrollRect;
        if (sr == null) return;

        sr.LuaOnBeginDrag = startDrag;
        sr.LuaOnEndDrag = endDrag;
    }

    private void HideData(FastGridItemData itemData)
    {
        if (itemData == null || itemData.IsVisible == false) return;
        itemData.IsVisible = false;

        if (LuaHideData != null)
        {
            LuaHideData.Call(itemData.LuaDataTable);
        }
    }

    private void ShowData(FastGridItemData itemData)
    {
        if (itemData == null || itemData.IsVisible == true) return;
        itemData.IsVisible = true;

        if (LuaShowData != null)
        {
            LuaShowData.Call(itemData.LuaDataTable);
        }
    }

    private void RefreshItem(FastGridItem item, FastGridItemData data)
    {
        if (LuaRefresh != null && item != null && data != null)
        {
            if (!RefreshAll && !AlwaysRefresh && item.ID == data.ID)
            {
                return;
            }

            if (item.ID != data.ID)
            {
                // 数据变化时，肯定隐藏被刷新掉的数据
                HideData(item.Data);
            }

            item.Data = data;
            RefreshItem(item.LuaUITable, data.LuaDataTable);
        }
    }

    private void RefreshItem(LuaTable uiTable, LuaTable uiData)
    {
        if (LuaRefresh != null && uiTable != null)
        {
            LuaRefresh.Call(uiTable, uiData);
        }
    }

    private void InitItem(FastGridItem item)
    {
        if (LuaInitItem != null)
        {
            LuaInitItem.Call(item);
        }
    }

    private void Sort(List<FastGridItemData> list)
    {
        if (list == null || list.Count == 0) return;

        list.Sort((a, b) =>
        {
            if (a == null || b == null) return 0;

            if (Small2Large)
            {
                return a.Weight.CompareTo(b.Weight);
            }
            return b.Weight.CompareTo(a.Weight);
        });
    }

    public void RefreshItem(long id)
    {
        if (GridItems == null) return;

        for (int i = 0; i < GridItems.Length; ++i)
        {
            if (GridItems[i] != null && GridItems[i].ID == id)
            {
                RefreshItem(GridItems[i].LuaUITable, GridItems[i].Data.LuaDataTable);
            }
        }
    }

    public void RefreshAllItem()
    {
        if (GridItems == null) return;

        for (int i = 0; i < GridItems.Length; ++i)
        {
            if (GridItems[i] != null && GridItems[i].gameObject.activeSelf)
            {
                RefreshItem(GridItems[i].LuaUITable, GridItems[i].Data.LuaDataTable);
            }
        }
    }

    public void SetNormalizedPosition(float x, float y)
    {
        mScrollRect.normalizedPosition = new Vector2(x, y);
    }

    public void SetHorizontalNormalizedPosition(float value)
    {
        mScrollRect.horizontalNormalizedPosition = value;
    }

    public void SetVerticalNormalizedPosition(float value)
    {
        mScrollRect.verticalNormalizedPosition = value;
    }

    private int GetDataIndex(long id)
    {
        for (int i = 0; i < datas.Count; ++i)
        {
            if (datas[i] != null && datas[i].ID == id)
            {
                return i;
            }
        }

        return 0;
    }

    public FastGridItemData GetData(long id)
    {
        for (int i = 0; i < datas.Count; ++i)
        {
            if (datas[i] != null && datas[i].ID == id)
            {
                return datas[i];
            }
        }

        return null;
    }

    public FastGridItemData GetDataByIndex(int index)
    {
        if (datas == null) return null;
        if (datas.Count <= index || index < 0) return null;
        return datas[index];
    }

    /// <summary>
    /// id一定不能==0
    /// </summary>
    public void AddData1(long id, LuaTable table, int weight0, int weight1, float size = 0)
    {
        FastGridItemData data = new FastGridItemData(id, table);
        data.SetWeight(weight0);
        data.SetWeight1(weight1);
        if (size > 0) data.SetSizeValue(size);
        datas.Add(data);
        RepositionNow = true;
    }

    /// <summary>
    /// id一定不能==0
    /// </summary>
    public void AddData(long id, LuaTable table)
    {
        FastGridItemData data = new FastGridItemData(id, table);
        datas.Add(data);
        RepositionNow = true;
    }

    public bool RemoveData(long id)
    {
        for (int i = 0; i < datas.Count; ++i)
        {
            if (datas[i] != null && datas[i].ID == id)
            {
                datas.RemoveAt(i);
                RepositionNow = true;
                return true;
            }
        }
        return false;
    }

    public void ClearData()
    {
        if (mScrollRect != null)
            mScrollRect.StopMovement();

        datas.Clear();
        if (GridItems != null)
        {
            for (int i = 0; i < GridItems.Length; ++i)
            {
                if (GridItems[i] == null) continue;
                GridItems[i].Data = null;
            }
        }
        RefreshAll = true;
        RepositionNow = true;
    }

    public void ClearGridItem()
    {
        if (GridItems == null) return;
        for (int index = 0; index < GridItems.Length; ++index)
        {
            if (GridItems[index] != null)
            {
                Destroy(GridItems[index].gameObject);
                if (GridItems[index].LuaUITable != null)
                {
                    GridItems[index].LuaUITable.Dispose();
                    GridItems[index].LuaUITable = null;
                }
                GridItems[index] = null;
            }
        }
    }

    public void ConstraintSort()
    {
        Sort(datas);
    }

    // 设置数据权重
    public void SetDataWeightByIndex(int index, int weight0)
    {
        FastGridItemData data = GetDataByIndex(index);
        if (data != null)
        {
            data.SetWeight(weight0);
        }
    }

    public void SetDataWeight1ByIndex(int index, int weight1)
    {
        FastGridItemData data = GetDataByIndex(index);
        if (data != null)
        {
            data.SetWeight1(weight1);
        }
    }

    public void SetDataWeightByID(long id, int weight0)
    {
        FastGridItemData data = GetData(id);
        if (data != null)
        {
            data.SetWeight(weight0);
        }
    }

    public void SetDataWeight1ByID(long id, int weight1)
    {
        FastGridItemData data = GetData(id);
        if (data != null)
        {
            data.SetWeight1(weight1);
        }
    }

    public void SetDataSizeValueByIndex(int index, float value)
    {
        FastGridItemData data = GetDataByIndex(index);
        if (data != null)
        {
            data.SetSizeValue(value);
        }
    }

    public void SetDataSizeValueByID(long id, float value)
    {
        FastGridItemData data = GetData(id);
        if (data != null)
        {
            data.SetSizeValue(value);
        }
    }

    protected override void Start()
    {
        if (Application.isPlaying)
        {
            Init();
        }
    }

    public override void SetLayoutHorizontal()
    {
    }

    public override void SetLayoutVertical()
    {
    }
    public override void CalculateLayoutInputHorizontal()
    {
    }
    public override void CalculateLayoutInputVertical()
    {
    }
}
[LuaCallCSharp]
public class FastGridItemData
{
    public FastGridItemData(long id, LuaTable table)
    {
        this.ID = id;
        this.LuaDataTable = table;
    }

    private void RefreshWeight()
    {
        this.Weight = ((long)(uint)this.Weight0 << 32) | (uint)this.Weight1;
    }

    public void SetWeight(int weight0)
    {
        this.Weight0 = weight0;
        RefreshWeight();
    }

    public void SetWeight1(int weight1)
    {
        this.Weight1 = weight1;
        RefreshWeight();
    }

    public void SetSizeValue(float value)
    {
        this.SizeValue = value;
    }

    public LuaTable LuaDataTable;

    // 权重值 排序时使用
    private int Weight0;
    private int Weight1;
    public long Weight { get; private set; }
    public long ID { get; private set; }
    public float SizeValue { get; private set; }
    // 这个数据是否在界面中显示 在viewport内
    public bool IsVisible = false;
}

[LuaCallCSharp]
public class FastGridItem : MonoBehaviour
{
    public int Index;
    public FastGridItemData Data;
    public LuaTable LuaUITable;
    public long ID
    {
        get
        {
            if (Data != null)
            {
                return Data.ID;
            }
            return 0;
        }
    }
}
