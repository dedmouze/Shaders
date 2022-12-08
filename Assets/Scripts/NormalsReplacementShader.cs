using UnityEngine;

public class NormalsReplacementShader : MonoBehaviour
{
    [SerializeField] private Shader _normalsShader;

    private readonly int CameraNormalsTexture = Shader.PropertyToID("_CameraNormalsTexture");
    private RenderTexture _renderTexture;

    private void Start()
    {
        Camera sceneCamera = GetComponent<Camera>();

        _renderTexture = new RenderTexture(sceneCamera.pixelWidth, sceneCamera.pixelHeight, 24);
        Shader.SetGlobalTexture(CameraNormalsTexture, _renderTexture);

        Camera normalsCamera = new GameObject("Normals Camera").AddComponent<Camera>();
        normalsCamera.CopyFrom(sceneCamera);
        normalsCamera.transform.SetParent(transform);
        normalsCamera.targetTexture = _renderTexture;
        normalsCamera.SetReplacementShader(_normalsShader, "RenderType");
        normalsCamera.depth = sceneCamera.depth - 1;
    }
}
