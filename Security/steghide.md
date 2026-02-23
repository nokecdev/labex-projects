# Steghide is a powerful stagenography tool used for hide data in images and audio

1. Hide data in image:
```steghide embed -cf carrier.jpg -ef secret.txt``` \
-cf = cover image \
-ef = file to hide \
It will require a password to hide the data with
To check the process use: \
``` steghide info carrier.jpg ```

2. Extract the  secret from the file:
``` steghide extract -sf carrier.jpg ```
