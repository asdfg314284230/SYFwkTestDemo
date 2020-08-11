using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EditLoadCheck{
    static Dictionary<string, bool> spriteDic; 

    static public Dictionary<string, bool> GetSpriteDic()
    {
        if (null == spriteDic)
        {
            spriteDic = new Dictionary<string, bool>();
            spriteDic.Add("load", true);
            spriteDic.Add("sprite_load_tool",true);
            spriteDic.Add("sprite_load_slag", true);
            spriteDic.Add("sprite_load_rank", true);
            spriteDic.Add("sprite_load_quests", true);
            spriteDic.Add("sprite_load_item", true);
            spriteDic.Add("sprite_load_upgrade", true);


            spriteDic.Add("atlas_global_tp01", true);
            spriteDic.Add("atlas_home_tp01", true);
            spriteDic.Add("atlas_maintenance_tp01", true);
            spriteDic.Add("atlas_sell_tp01", true);
            spriteDic.Add("atlas_shop_tp01", true);
            spriteDic.Add("atlas_storage_tp01", true);
            spriteDic.Add("atlas_rank_tp01", true);
            
        }

        return spriteDic;
    }

}
