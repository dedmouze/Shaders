using UnityEngine;

public class CameraDepthTextureMode : MonoBehaviour
{
    [SerializeField] private DepthTextureMode _depthTextureMode;
    
    private void OnValidate() => SetCameraDepthTextureMode();
    
    private void Start() => SetCameraDepthTextureMode();
    
    private void SetCameraDepthTextureMode() => GetComponent<Camera>().depthTextureMode = _depthTextureMode;
}
