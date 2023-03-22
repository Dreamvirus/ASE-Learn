using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SetTargetPos : MonoBehaviour
{
    public GameObject target;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 targetPos = transform.position;
        target.GetComponent<MeshRenderer>().sharedMaterial.SetVector("_TargetPos",targetPos);
    }
}
