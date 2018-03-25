# Nativescript in docker
The dockerfile will build an image you can use to make NativeScript (https://www.nativescript.org/) android applications.


# What was used
CentOS 7 (64-bit) with Docker (CE version 18.03).
The build has been tested on a CentOS virtual machine running in VMWare Workstation on Windows 7. The android phone was directly connected to the USB port and VMWare was configured to present the USB to the CentOS host.

In the document the host refers to the CentOS.
I dont see any problems running other Linux variants as a host machine.


# Building the image
Create a folder somewhere on the host and copy the dockerfile there. Issue a 
```
docker build -t nativescript .
```
to build the image. You should now see the image **nativescript** when you list your images with
```
docker images
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
nsdocker tns create HelloWorld --template nativescript-template-tutorial
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

Next thing is a bit tricky. The problem here is that we need to communicate with the phone via USB. adb creates the RSA keys for the connection but as soon the container is removed the keys are lost. Every time we would do a **tns run** the phone would ask to confirm the connection. To overcome this we will store the keys to the host.
```
nsdocker bash -c "adb devices && mkdir -p /app/adbkeys && cp /root/.android/a* /app/adbkeys/"
```
Here we run multiple command in the docker in one go, therefor we need bash. When the command is run be prepared to hit ok on the phone screen to allow the connection. The docker output should show a **device** found. If you get a line marked as **unauthorized** then run the command above again.
You only need to do this onces for each project or if you loose connection to the phone.

**Note! The keys to your phone is stored in the project in folder adbkeys. If you are pushing code to git then you should add this folder to be ignored!**


Next lets run (build & deploy) the project to the phone
```
nsdocker bash -c "cp /app/adbkeys/* /root/.android/ && adb devices && tns run android"
```
Again we need multiple command as we need to copy the adbkeys to the container before running the **tns run android** command.


Might be some day I have time to get the adbkeys setup more easily but for now it works. The dockerfile has been tested to run HelloWorld examples and LiveSync also works. There is probably some missing Java libraries as I wanted this to be a clean setup.

