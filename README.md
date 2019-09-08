# Nativescript in docker
The dockerfile will build an image you can use to make NativeScript (https://www.nativescript.org/) android applications.


# What was used
CentOS 7 (64-bit) with Docker (CE version 18.03).
The build has been tested on a CentOS virtual machine running in VMWare Workstation on Windows 7. The android phone was directly connected to the USB port and VMWare was configured to present the USB to the CentOS host.

In the document the host refers to the CentOS.
I dont see any problems running other Linux variants as a host machine.


# Building the image
Create a folder somewhere on the host and copy the dockerfile and tools folder there. Issue a 
```
docker build -t nativescript .
```
to build the image. You should now see the image **nativescript** when you list your images with
```
docker images
```

# Pulling the image from docker hub
The image is accessible from docker hub (if building the image is not an option).  
It's naming is different due to namespace, so after an pull, rename it with tag.
```
docker pull kajpe/docker_nativescript
docker tag kajpe/docker_nativescript nativescript
```


# Make a docker alias
Create an alias to help with long docker lines.
```
alias nsdocker='docker run -it --rm --privileged -v $(pwd)/:/app nativescript'
```


# Usage = Building your first project
Navigate to a folder where you will place your project. Here we will create a folder and cd into it.
```
mkdir -p testing
cd testing
```

Using nativescript own commands lets create a **HelloWorld** project.
```
nsdocker tns create HelloWorld --js
```
We we're using the nsdocker alias, which actually created the container, ran the tns command, and removed the container. The current directory was mapped inside the container which tns used as a working point.

If you now list you folder content you will se a HelloWorld folder.
Next change to the project folder.
```
cd HelloWorld
```

Going along with NativeScript lets define an android platform. IOS has not been tested with this dockerfile.
```
nsdocker tns platform add android
```

Connect your phone or tablet via USB. adb over tcp is not supported yet. Turn on USB debugging. Linux running on VMware also supported.

The first thing we have to do is to authenticate our device. A helper script in the container will help in detecting your device and store the keys in the project folder under **adbkeys**. 
```
nsdocker detectdev
```
When the command is run be prepared to hit ok on the device screen to allow the connection. The docker output should show a **device** found. If you get a line marked as **unauthorized** then run the command above again.
You only need to do this onces for each project or if you loose connection to the device.

You can check if the keys works by issuing:
```
nsdocker listdev
```

**Note! The keys to your phone is stored in the projects folder *adbkeys*. If you are pushing code to git then you should add this folder to be ignored!**


Next lets run (build & deploy) the project to the phone
```
nsdocker tns run android
```
At first run this will download Gradle and store all the data in the projects folder as .gradle (hidden, issue ls -la to see it). You might decide to exclude this folder from git.

Also preview mode is supported.
```
nsdocker tns preview
```
