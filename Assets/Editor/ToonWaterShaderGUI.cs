using System;
using UnityEngine;
using UnityEditor;

public class ToonWaterShaderGUI : ShaderGUI
{
    private enum BlendMode
    {
        Opaque,
        Transparent,
        Fade
    }

    private static class Styles
    {
        public static readonly GUIContent DepthShallowColorText = EditorGUIUtility.TrTextContent("Depth Shallow Color", "Color of the shallow of depth");
        public static readonly GUIContent DepthDeepColorText = EditorGUIUtility.TrTextContent("Depth Deep Color", "Color of the deep of depth");
        public static readonly GUIContent DepthMaxDistanceText = EditorGUIUtility.TrTextContent("Depth Max Distance", "The maximum distance after which the color will begin to change");
        public static readonly GUIContent SurfaceNoiseText = EditorGUIUtility.TrTextContent("Surface Noise", "Surface noise map");
        public static readonly GUIContent SurfaceNoiseScrollText = EditorGUIUtility.TrTextContent("Surface Noise Scroll", "Displacement velocity of surface noise map");
        public static readonly GUIContent SurfaceDistortionText = EditorGUIUtility.TrTextContent("Surface Distortion", "Surface distortion map");
        public static readonly GUIContent FoamColorText = EditorGUIUtility.TrTextContent("Foam Color", "Color of the foam on water");
        public static readonly GUIContent FoamMinDistance = EditorGUIUtility.TrTextContent("Foam Min Distance", "Minimum threshold of foam");
        public static readonly GUIContent FoamMaxDistance = EditorGUIUtility.TrTextContent("Foam Max Distance", "Maximum threshold of foam");

        public static readonly string PrimaryMapsText = "Main Maps";
        public static readonly string RenderingModeText = "Rendering Mode";
        public static readonly string DepthSettingsText = "Depth Settings";
        public static readonly string FoamSettingsText = "Foam Settings";
        public static readonly string AdvancedSettingsText = "Advanced Settings";
        public static readonly string[] BlendNames = Enum.GetNames(typeof(BlendMode));
    }

    private MaterialEditor _materialEditor;

    private MaterialProperty _blendMode;
    private MaterialProperty _depthShallowColor;
    private MaterialProperty _depthDeepColor;
    private MaterialProperty _depthMaxDistanceColor;
    private MaterialProperty _surfaceNoise;
    private MaterialProperty _surfaceNoiseCutoff;
    private MaterialProperty _surfaceNoiseScroll;
    private MaterialProperty _surfaceDistortion;
    private MaterialProperty _surfaceDistortionAmount;
    private MaterialProperty _foamColor;
    private MaterialProperty _foamMinDistance;
    private MaterialProperty _foamMaxDistance;

    private void FindProperties(MaterialProperty[] properties)
    {
        _blendMode = FindProperty("_Mode", properties);
        _depthShallowColor = FindProperty("_DepthShallowColor", properties);
        _depthDeepColor = FindProperty("_DepthDeepColor", properties);
        _depthMaxDistanceColor = FindProperty("_DepthMaxDistance", properties);
        _surfaceNoise = FindProperty("_SurfaceNoise", properties);
        _surfaceNoiseCutoff = FindProperty("_SurfaceNoiseCutoff", properties);
        _surfaceNoiseScroll = FindProperty("_SurfaceNoiseScroll", properties);
        _surfaceDistortion = FindProperty("_SurfaceDistortion", properties);
        _surfaceDistortionAmount = FindProperty("_SurfaceDistortionAmount", properties);
        _foamColor = FindProperty("_FoamColor", properties);
        _foamMinDistance = FindProperty("_FoamMinDistance", properties);
        _foamMaxDistance = FindProperty("_FoamMaxDistance", properties);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        FindProperties(properties);
        _materialEditor = materialEditor;

        DoBlendMode();
        EditorGUILayout.Space();
        DoDepth();
        EditorGUILayout.Space();
        DoSurfaceNoise();
        DoFoam();
        EditorGUILayout.Space();
        DoAdvanced();
    }

    private void DoDepth()
    {
        GUILayout.Label(Styles.DepthSettingsText, EditorStyles.boldLabel);

        _materialEditor.ShaderProperty(_depthShallowColor, Styles.DepthShallowColorText);
        _materialEditor.ShaderProperty(_depthDeepColor, Styles.DepthDeepColorText);
        _materialEditor.ShaderProperty(_depthMaxDistanceColor, Styles.DepthMaxDistanceText);
    }
    private void DoBlendMode()
    {
        GUILayout.Label(Styles.RenderingModeText, EditorStyles.boldLabel);
        
        EditorGUI.BeginChangeCheck();
        _blendMode.floatValue = EditorGUILayout.Popup(Styles.RenderingModeText, (int) _blendMode.floatValue, Styles.BlendNames);
        bool blendModeChanged = EditorGUI.EndChangeCheck();
        
        if(blendModeChanged)
            foreach(var obj in _blendMode.targets)
                SetupMaterialWithBlendMode((Material) obj, (BlendMode) _blendMode.floatValue);
    }
    private void DoSurfaceNoise()
    {
        GUILayout.Label(Styles.PrimaryMapsText, EditorStyles.boldLabel);

        _materialEditor.TexturePropertySingleLine(Styles.SurfaceNoiseText, _surfaceNoise, _surfaceNoise.textureValue ? _surfaceNoiseCutoff : null);
        _materialEditor.TexturePropertySingleLine(Styles.SurfaceDistortionText, _surfaceDistortion, _surfaceDistortion.textureValue ? _surfaceDistortionAmount : null);
        _materialEditor.ShaderProperty(_surfaceNoiseScroll, Styles.SurfaceNoiseScrollText);
    }
    private void DoFoam()
    {
        GUILayout.Label(Styles.FoamSettingsText, EditorStyles.boldLabel);
        
        _materialEditor.ShaderProperty(_foamColor, Styles.FoamColorText);
        _materialEditor.ShaderProperty(_foamMinDistance, Styles.FoamMinDistance);
        _materialEditor.ShaderProperty(_foamMaxDistance, Styles.FoamMaxDistance);
    }
    private void DoAdvanced()
    {
        GUILayout.Label(Styles.AdvancedSettingsText, EditorStyles.boldLabel);
        _materialEditor.RenderQueueField();
    }

    private void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        int renderQueue = -1;
        switch (blendMode)
        {
            case BlendMode.Opaque:
            {
                material.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.One);
                material.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.Zero);
                material.SetFloat("_ZWrite", 1f);
                renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                break;
            }
            case BlendMode.Transparent:
            {
                material.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.One);
                material.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetFloat("_ZWrite", 0f);
                renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            }
            case BlendMode.Fade:
            {
                material.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetFloat("_ZWrite", 0f);
                renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            }
        }

        material.renderQueue = renderQueue;
    }
}
