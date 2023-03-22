using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Door : MonoBehaviour
{
    public Material material;
    [Range(0,2)]
    public float yRot;
    private const string yRotName = "_YRot";
    // Update is called once per frame
    void Update()
    {
        if (material != null)
        {
            material.SetFloat(yRotName, yRot);
        }
    }
}
