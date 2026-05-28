Limitrange is used for set up resource consumptions limits in pods.

For this example we will create a limitrange.yaml file to limit memory and CPU usage.
### limitrange.yaml
```
apiVersion: v1
kind: LimitRange
metadata:
  name: example-limitrange
spec:
  limits:
    - type: Container
      max:
        cpu: "1"
        memory: "1Gi"
      min:
        cpu: "100m"
        memory: "100Mi"
      default:
        cpu: "500m"
        memory: "500Mi"
```

You have a pod you want to target the resource limit usage, so lets create one.

### pod.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
    - name: nginx
      image: nginx
```


Lets create an exceeding pod for this purpose. Since we specified the maximum container usage for the pods this will throw an error. We will create a new resource called `pod-exceeding-limits.yaml`. The resources are set to larger values than the limitrange allows, and when applying these changes it will throw an error. The error message says the cpu limit is set to 1 Gb but we the pod requests 2 Gb which breaks the rule of limitrange.


### pod-exceeding-limits.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: example-pod-exceeding-limits
spec:
  containers:
    - name: nginx
      image: nginx
      resources:
        limits:
          cpu: "2"
          memory: "2Gi"
```

To enable 2 Gb of resource usage, update the limitrange accordingly.