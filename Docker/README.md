# Tensorflow
install dependencies

pip install tensorflow==2.14.0

pip install numpy==1.26.4


docker pull tensorflow/serving

Create and export model
# Import TensorFlow
import tensorflow as tf

# Define a simple Sequential model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(units=1, input_shape=[1], use_bias=True)
])

# Set the weights to achieve the "multiply by 0.5 and add 2" functionality
weights = [tf.constant([[0.5]]), tf.constant([2.0])]
model.set_weights(weights)

# Compile the model (required even if not training)
model.compile(optimizer='sgd', loss='mean_squared_error')

# Export the model to a SavedModel
export_path = './saved_model_half_plus_two/1'
tf.saved_model.save(model, export_path)

Serve the model using docker
# Serve the model using TensorFlow Serving in a Docker container
docker run -t --rm -p 9500:8500 -p 9501:8501 \
  -v "/home/labex/project/saved_model_half_plus_two:/models/half_plus_two" \
  -e MODEL_NAME=half_plus_two \
  tensorflow/serving


# Send request to docker
curl -X POST \
  http://localhost:9501/v1/models/half_plus_two:predict \
  -d '{"signature_name":"serving_default","instances":[[1.0], [2.0], [5.0]]}'
{
    "predictions": [[2.5], [3.0], [4.5]
    ]
}  


