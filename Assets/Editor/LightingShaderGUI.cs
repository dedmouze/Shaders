using UnityEngine;
using UnityEditor;

public class LightingShaderGUI : ShaderGUI
{
    private static class Styles
    {
        public static readonly GUIContent AlbedoText = EditorGUIUtility.TrTextContent("Albedo", "Albedo (RGB)");
        public static readonly GUIContent SmoothnessText = EditorGUIUtility.TrTextContent("Smoothness", "Smoothness value");
        public static readonly GUIContent NormalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Normal Map");
        public static readonly GUIContent HeightMapText = EditorGUIUtility.TrTextContent("Height Map", "Height Map (G)");
        public static readonly GUIContent DiffuseIBL = EditorGUIUtility.TrTextContent("Diffuse IBL", "Diffuse for image base lighting");
        public static readonly GUIContent SpecularIBL = EditorGUIUtility.TrTextContent("Specular IBL", "Specular for image base lighting");

        public static readonly string PrimaryMapsText = "Main Maps";
        public static readonly string SecondaryMapsText = "Secondary Maps";
    }
    
    private MaterialEditor _materialEditor;
    
    private MaterialProperty _mainTex;
    private MaterialProperty _color;
    private MaterialProperty _normalMap;
    private MaterialProperty _normalIntensity;
    private MaterialProperty _heightMap;
    private MaterialProperty _heightStrength;
    private MaterialProperty _smoothness;
    private MaterialProperty _diffuseIBL;
    private MaterialProperty _diffIBLIntensity;
    private MaterialProperty _specularIBL;
    private MaterialProperty _specIBLIntensity;
    
    private void FindProperties(MaterialProperty[] properties)
    {
        _mainTex= FindProperty("_MainTex", properties);
        _color = FindProperty("_Color", properties);
        _normalMap = FindProperty("_NormalMap", properties);
        _normalIntensity = FindProperty("_NormalIntensity", properties);
        _heightMap = FindProperty("_HeightMap", properties);
        _heightStrength = FindProperty("_HeightStrength", properties);
        _smoothness = FindProperty("_Smoothness", properties);
        _diffuseIBL = FindProperty("_DiffuseIBL", properties);
        _diffIBLIntensity = FindProperty("_DiffIBLIntensity", properties);
        _specularIBL = FindProperty("_SpecularIBL", properties);
        _specIBLIntensity = FindProperty("_SpecIBLIntensity", properties);
    }
    
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        FindProperties(properties);
        _materialEditor = materialEditor;

        DoMainMapsArea();
        EditorGUILayout.Space();
        DoSecondaryMapsArea();
    }

    private void DoMainMapsArea()
    {
        GUILayout.Label(Styles.PrimaryMapsText, EditorStyles.boldLabel);

        _materialEditor.TexturePropertySingleLine(Styles.AlbedoText, _mainTex, _color);
        
        EditorGUI.indentLevel += 2;
        _materialEditor.ShaderProperty(_smoothness, Styles.SmoothnessText);
        EditorGUI.indentLevel -= 2;

        _materialEditor.TexturePropertySingleLine(Styles.NormalMapText, _normalMap, _normalMap.textureValue ? _normalIntensity : null);
        _materialEditor.TexturePropertySingleLine(Styles.HeightMapText, _heightMap, _heightMap.textureValue ? _heightStrength : null);
        
        _materialEditor.TextureScaleOffsetProperty(_mainTex);
    }
    private void DoSecondaryMapsArea()
    {
        GUILayout.Label(Styles.SecondaryMapsText, EditorStyles.boldLabel);

        _materialEditor.TexturePropertySingleLine(Styles.DiffuseIBL, _diffuseIBL, _diffuseIBL.textureValue ? _diffIBLIntensity : null);
        _materialEditor.TexturePropertySingleLine(Styles.SpecularIBL, _specularIBL, _specularIBL.textureValue ? _specIBLIntensity : null);
    }
}
