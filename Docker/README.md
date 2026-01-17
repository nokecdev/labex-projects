# Tensorflow
install dependencies
```
pip install tensorflow==2.14.0
pip install numpy==1.26.4
```
```
docker pull tensorflow/serving
```
## Create and export model

### Import TensorFlow
```
import tensorflow as tf
```

### Define a simple Sequential model
```
model = tf.keras.Sequential([
    tf.keras.layers.Dense(units=1, input_shape=[1], use_bias=True)
])
```

### Set the weights to achieve the "multiply by 0.5 and add 2" functionality
```
weights = [tf.constant([[0.5]]), tf.constant([2.0])]
model.set_weights(weights)
```

### Compile the model (required even if not training)
```
model.compile(optimizer='sgd', loss='mean_squared_error')
```

### Export the model to a SavedModel
```
export_path = './saved_model_half_plus_two/1'
tf.saved_model.save(model, export_path)
```

Serve the model using docker
### Serve the model using TensorFlow Serving in a Docker container
```
docker run -t --rm -p 9500:8500 -p 9501:8501 \
  -v "/home/labex/project/saved_model_half_plus_two:/models/half_plus_two" \
  -e MODEL_NAME=half_plus_two \
  tensorflow/serving
```

### Send request to docker
```
curl -X POST \
  http://localhost:9501/v1/models/half_plus_two:predict \
  -d '{"signature_name":"serving_default","instances":[[1.0], [2.0], [5.0]]}'
{
    "predictions": [[2.5], [3.0], [4.5]
    ]
}  
```

### Run 
docker run -it --name ubuntu-interactive ubuntu /bin/bash

### Get address of a container 
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-name>

### Get status of a running container
docker inspect -f '{{.State.Status}}' <container-name>

### Stream container log output
docker logs -f <container-name>

### Get an interactive shell inside the container
docker exec -it <container-name> /bin/bash
For example we can print out the nginx config file inside the nginx container:
cat /etc/nginx/nginx.conf

### Copy files into container
echo "Hello" > hello.txt
Copy:
docker cp hello.txt <container-name>:/usr/share/nginx/hello.txt
Review:
docker exec <container-name> cat /usr/share/nginx/hello.txt

_Copy from container to host:_
docker cp <container-name>:/etc/nginx/nginx.conf ~/project/nginx.conf
Verify:
ls -l ~/project/nginx.conf

### Setting environment variables in containers
docker run --name env-test -e MY_VAR="Hello, Environment" -d ubuntu sleep infinity
sleep infinity: runs the container indefinitely

### Run container with limited resources
docker run --name limited-nginx -d --memory=512m --cpus=0.5 nginx
### Verify
docker stats limited-nginx


# Docker run command & parameters


| Parameter	| What it does                                                            |
| --------- | ----------------------------------------------------------------------  |
| --name  | 	Assigns a custom name to your container for easier management.          |
| -d      |	  Runs the container in detached mode (background).                       |
| -p      |   Port Mapping: Connects a host port to a container port (e.g., 8080:80). |
| -v      |   Volume Mounting: Shares a directory between your host and the container.|
| -e      |   Sets Environment Variables (e.g., setting passwords or config modes).   |
| --cpus / -m |	Resource Limits: Restricts how much CPU or RAM the container can use. |
| --network   |	Connects the container to a specific Docker network.                  |
| --restart   |	Sets the Restart Policy (e.g., unless-stopped) for reliability.       |
| -w          |	Sets the Working Directory inside the container.                      |


# Network types
bridge: This is the default network driver. When you start a container without specifying a network, it automatically connects to the bridge network. Containers on the same bridge network can communicate with each other using their IP addresses.

host: This driver removes network isolation between the container and the Docker host. The container shares the host's networking namespace, which means it uses the host's IP address and port space directly. This can be useful for optimizing performance in certain scenarios.

none: This driver disables all networking for a container. Containers using this network type will have no access to external networks or other containers. It's useful when you want to completely isolate a container.

## Inspect the default network bridge
Run the next command to inspect the bridge network
```docker network inspect bridge```

Example:
```
[
  {
    "Name": "bridge",
    "Id": "79dce413aafdd7934fa3c1d0cc97decb823891ce406442b7d51be6126ef06a5e",
    "Created": "2024-08-22T09:58:39.747333789+08:00",
    "Scope": "local",
    "Driver": "bridge",
    "EnableIPv6": false,
    "IPAM": {
      "Driver": "default",
      "Options": null,
      "Config": [
        {
          "Subnet": "172.17.0.0/16",
          "Gateway": "172.17.0.1"
        }
      ]
    },
    "Internal": false,
    "Attachable": false,
    "Ingress": false,
    "ConfigFrom": {
      "Network": ""
    },
    "ConfigOnly": false,
    "Containers": {},
    "Options": {
      "com.docker.network.bridge.default_bridge": "true",
      "com.docker.network.bridge.enable_icc": "true",
      "com.docker.network.bridge.enable_ip_masquerade": "true",
      "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
      "com.docker.network.bridge.name": "docker0",
      "com.docker.network.driver.mtu": "1500"
    },
    "Labels": {}
  }
]
```

Subnet: The subnet used by containers in this network is 172.17.0.0/16. This means containers will be assigned IP addresses within this range.
Gateway: The gateway for this network is 172.17.0.1. This is the IP address that containers use to communicate with networks outside their own.
Containers: This field is empty because we haven't started any containers yet.
Options: These are various configuration options for the bridge network. For example, enable_icc set to "true" means that inter-container communication is allowed on this network.

## Create a Custom Bridge network
To create a network for specific or related containers it is useful a command:
docker network create --driver bridge my-network
The --driver bridge option is optional. But here is included.

Check networks:
```docker network ls```

## Connect two container to the network
docker run -d --name container1 --network my-network nginx
docker run -d --name container2 --network my-network nginx

## Test inter container communication
```
docker exec container1 curl -s container2
```
In this example we are sending a curl request from container1 to container2. 
A successful nginx html response indicates that the communication between containers is set.

## Exposing container ports
By default, containers in a custom network can communicate with each other, but they're not accessible from outside the Docker host. To make a container accessible from the host or external networks, we need to expose its ports.

```
docker run -d --name exposed-container -p 8080:80 --network my-network nginx
```

with curl from outside:
``` curl localhost:8080 ```
This will result the same answer as in the previous step.

## Using Host networking

``` docker run -d --name host-networked --network host nginx ```
This command creates a new container named host-networked using the host network. Note that you can't use -p with host networking, as the container is already using the host's network interfaces.
Lets verify:
docker inspect --format '{{.HostConfig.NetworkMode}}' host-networked