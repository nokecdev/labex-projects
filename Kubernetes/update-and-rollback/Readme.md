# Update and Rollback Kubernetes applications

Check deployment status
```
kubectl rollout status deployment troubleshoot-app
```

Example output
```
NAME                              READY   STATUS             RESTARTS   AGE
troubleshoot-app-6b8986c555-gcjj9   0/1     ImagePullBackOff   0          2m56s
troubleshoot-app-6b8986c555-p29dp   0/1     ImagePullBackOff   0          2m56s
troubleshoot-app-6b8986c555-vpv5q   0/1     ImagePullBackOff   0          2m56s
```

Examine pod details and logs
```
# Replace 'xxx-yyy' with your actual pod name
POD_NAME=$(kubectl get pods -l app=troubleshoot -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $POD_NAME
kubectl logs $POD_NAME
```

## Rollback to stable version

Verify current deployment image
```
kubectl describe deployment web-app | grep Image
```

Perform the rollback to previous version
```
kubectl rollout undo deployment web-app
```

Verify rollback success
```
kubectl rollout status deployment web-app
```

## Adjust custom rollout strategy

```
appversion: apps/v1
metadata:
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2
      maxSurge: 3
```

Key points about rolling update strategy:

1. maxUnavailable: Maximum number of pods that can be unavailable during update
2. maxSurge: Maximum number of pods that can be created above the desired number
3. Helps control update speed and application availability
Allows fine-tuning of deployment behavior

