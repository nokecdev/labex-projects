# Scale and load balance applications

Start Minikube cluster:
```
minikube start
```

Verify the cluster status
```
minikube status
kubectl get nodes
```

## Deploy a sample application
Create the deployment configuration.
The deployment will contain an nginx image with 1 replicas on port 80.

Apply the deployment:
```
kubectl apply -f nginx-deployment.yaml
```

Verify the deployment status:
```
kubectl get deployments
kubectl get pods
```

## Scale deployments to handle increased load

From the previous deployment file, update the replicas from 1 to 3.

After updated, apply the changes.

Alternative scaling method using `kubectl scale`
```
kubectl scale deployment nginx-deployment --replicas=4
```

# Verify load balancing by checking multiple pod responses
Kubernetes Services handle this process automatically.

Create a load balancing based on nginx-service.yaml

Don't forget to apply
```
kubectl apply -f nginx-service.yaml
```

Verify the service
```
kubectl get services
```

Example output
```
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP   30m
nginx-service   ClusterIP   10.96.xxx.xxx   <none>        80/TCP    30s
```

## Test the load balancer
To test the load balancing create a temporary pod
```
kubectl run curl-test --image=curlimages/curl --rm -it -- sh
```

In the temporary pod run multiple requests
```
for i in $(seq 1 10); do curl -s nginx-service | grep -q "Welcome to nginx!" && echo "Welcome to nginx - Request $i"; done
```

This loop will send 10 request to nginx-service and each request will be routed to one of the nginx pods.

By running curl commands this provides the services are available and they are up.


# Monitor Deployment and Pod Events for Changes
Get detailed information about current pod:
```
kubectl describe deployment nginx-deployment
```

Get detailed information about individual pod
This will output status, container info, events, ip addresses, node informations.
```
kubectl describe pods -l app=nginx
```

Get node-wide events (running pods, messages about the pod)
```
kubectl get events
```

Filter to deployment related events of specific resources
```
kubectl get events --field-selector involvedObject.kind=Deployment
```

