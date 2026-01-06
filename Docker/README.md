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