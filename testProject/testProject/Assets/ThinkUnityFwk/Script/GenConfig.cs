using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using XLua;

namespace Flz
{

    public static class GenConfig
    {
        //lua中要使用到C#库的配置，比如C#标准库，或者Unity API，第三方库等。
        [LuaCallCSharp]
        public static List<Type> LuaCallCSharp = new List<Type>() {
            typeof(System.Object),
            typeof(Uri),
            typeof(UnityEngine.Object),
            typeof(Vector2),
            typeof(Vector3),
            typeof(Vector4),
            typeof(Quaternion),
            typeof(Color),
            typeof(Ray),
            typeof(Bounds),
            typeof(Ray2D),
            typeof(Time),
            typeof(GameObject),
            typeof(Component),
            typeof(Behaviour),
            typeof(Transform),
            typeof(Resources),
            typeof(TextAsset),
            typeof(Keyframe),
            typeof(AnimationCurve),
            typeof(AnimationClip),
            typeof(MonoBehaviour),
            typeof(ParticleSystem),
            typeof(SkinnedMeshRenderer),
            typeof(Renderer),
            typeof(WWW),
            typeof(System.Collections.Generic.List<int>),
            typeof(Action<string>),
            typeof(UnityEngine.Debug),
            typeof(BestHTTP.HTTPRequestStates),
            typeof(BestHTTP.HTTPRequest),
            typeof(BestHTTP.HTTPMethods),
            typeof(UnityEngine.Events.UnityEvent),
            typeof(UnityEngine.Events.UnityEventBase),
            typeof(RectTransform),
            typeof(AudioSource),
            typeof(AudioListener),
            typeof(AudioClip),
            typeof(Image),
            typeof(Canvas),
            typeof(Camera),
            typeof(AssetBundle),
            typeof(Toggle),
            typeof(ToggleGroup),
            typeof(DateTime),
            typeof(PlayerPrefs),
            typeof(AssetBundleCreateRequest),
            typeof(AssetBundleRequest),
            typeof(AsyncOperation),
            typeof(AssetBundleManifest),
            typeof(LineRenderer),
            typeof(ParticleSystemRenderer),
            typeof(LayerMask),
            typeof(Rigidbody2D),
            typeof(BoxCollider2D),
            typeof(CircleCollider2D),
            typeof(PolygonCollider2D),
            typeof(EdgeCollider2D),
            typeof(PhysicsMaterial2D),
            typeof(UnityEngine.Tilemaps.Tilemap),
            typeof(UnityEngine.GridLayout),
            typeof(UnityEngine.SpriteRenderer),
            typeof(UnityEngine.Video.VideoPlayer),
            typeof(TrailRenderer),
        };

        //C#静态调用Lua的配置（包括事件的原型），仅可以配delegate，interface
        [CSharpCallLua]
        public static List<Type> CSharpCallLua = new List<Type>() {
                typeof(Action),
                typeof(Func<double, double, double>),
                typeof(Action<string>),
                typeof(Action<string, string>),
                typeof(Action<string, UnityEngine.Object[]>),
                typeof(Action<UnityEngine.Object>),
                typeof(Action<double>),
                typeof(Action<float>),
                typeof(Action<int>),
                typeof(Action<int, int, string>),
                typeof(Action<GameObject>),
                typeof(Action<AsyncOperation>),
                typeof(Action<bool, string>),
                typeof(Action<PointerEventData>),
                typeof(UnityEngine.Events.UnityAction),
                typeof(UnityEngine.Events.UnityAction<bool>),
                typeof(UnityEngine.Events.UnityAction<float>),
                typeof(UnityEngine.Events.UnityAction<int>),
                typeof(UnityEngine.Events.UnityAction<string>),
                typeof(UnityEngine.Events.UnityAction<Vector2>),
                typeof(UnityEngine.Events.UnityAction<UnityEngine.EventSystems.BaseEventData>),

                typeof(BestHTTP.OnRequestFinishedDelegate),
                typeof(Spine.AnimationState.TrackEntryDelegate),
                typeof(Spine.AnimationState.TrackEntryEventDelegate),

                typeof(Rigidbody2D),
                typeof(BoxCollider2D),
                typeof(CircleCollider2D),
                typeof(PolygonCollider2D),
                typeof(EdgeCollider2D),
                typeof(PhysicsMaterial2D),

                //typeof(Func<Spine.AnimationState, int, int>),
                typeof(UnityEngine.Video.VideoPlayer.EventHandler),
            };

        //黑名单
        [BlackList]
        public static List<List<string>> BlackList = new List<List<string>>()  {
                new List<string>(){"UnityEngine.WWW", "movie"},
                new List<string>(){"UnityEngine.WWW", "GetMovieTexture" },
                new List<string>(){"UnityEngine.WWW", "GetAudioClip", "bool" },
                new List<string>(){"UnityEngine.WWW", "GetAudioClip", "bool", "bool" },
                new List<string>(){"UnityEngine.WWW", "GetAudioClip", "bool", "bool", "UnityEngine.AudioType" },

                new List<string>(){"UnityEngine.Texture2D", "alphaIsTransparency"},
                new List<string>(){"UnityEngine.Security", "GetChainOfTrustValue"},
                new List<string>(){"UnityEngine.CanvasRenderer", "onRequestRebuild"},
                new List<string>(){"UnityEngine.Light", "areaSize"},
                new List<string>(){"UnityEngine.AnimatorOverrideController", "PerformOverrideClipListCleanup"},
#if !UNITY_WEBPLAYER
                new List<string>(){"UnityEngine.Application", "ExternalEval"},
#endif
                new List<string>(){"UnityEngine.GameObject", "networkView"}, //4.6.2 not support
                new List<string>(){"UnityEngine.Component", "networkView"},  //4.6.2 not support
                new List<string>(){"System.IO.FileInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
                new List<string>(){"System.IO.FileInfo", "SetAccessControl", "System.Security.AccessControl.FileSecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
                new List<string>(){"System.IO.DirectoryInfo", "SetAccessControl", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "CreateSubdirectory", "System.String", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "Create", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){ "MonoBehaviour", "runInEditMode" },
                new List<string>(){ "UnityEngine.MonoBehaviour", "runInEditMode" },
                // tilemap编辑器方法
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "GetEditorPreviewTile", "UnityEngine.Vector3Int"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "SetEditorPreviewTile", "UnityEngine.Vector3Int", "UnityEngine.Tilemaps.TileBase" },
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "HasEditorPreviewTile", "UnityEngine.Vector3Int"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "GetEditorPreviewSprite", "UnityEngine.Vector3Int"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "GetEditorPreviewTransformMatrix", "UnityEngine.Vector3Int"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "SetEditorPreviewTransformMatrix", "UnityEngine.Vector3Int", "UnityEngine.Matrix4x4"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "GetEditorPreviewColor", "UnityEngine.Vector3Int"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "SetEditorPreviewColor", "UnityEngine.Vector3Int", "UnityEngine.Color"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "GetEditorPreviewTileFlags", "UnityEngine.Vector3Int"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "EditorPreviewFloodFill", "UnityEngine.Vector3Int", "UnityEngine.Tilemaps.TileBase"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "EditorPreviewBoxFill", "UnityEngine.Vector3Int", "UnityEngine.Object", "System.Int32", "System.Int32", "System.Int32", "System.Int32"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "ClearAllEditorPreviewTiles"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "editorPreviewOrigin"},
                new List<string>(){ "UnityEngine.Tilemaps.Tilemap", "editorPreviewSize"},
            };
    }
}
