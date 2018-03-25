FROM ubuntu:16.04

# Update apt-get
RUN apt-get update
	
# Utilities
RUN apt-get install -y --no-install-recommends curl wget unzip 

# JAVA 8
RUN apt-get install -y --no-install-recommends openjdk-8-jdk 
	
# NodeJS v8.x LTS
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -y --no-install-recommends nodejs 
	
# Android build requirements
RUN apt-get install -y --no-install-recommends lib32stdc++6 lib32z1
	
#Install the latest SDK command line tools
RUN cd /opt \
  && wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \
  && unzip android-sdk.zip -d android-sdk-linux \
  && rm -f android-sdk.zip \
  && chown -R root:root android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}
	
# Accept Android licenses
RUN yes | sdkmanager --licenses

# Install Android platform tools
RUN sdkmanager --verbose "platform-tools" "tools"

# Install SDKs (and accept licenses)
RUN yes | sdkmanager --verbose \
  "platforms;android-27" \
  "build-tools;27.0.3" \
  "extras;android;m2repository" \
  "extras;google;m2repository"
	
# NativeScript
# Note: you will get an error "npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents".
# This is ok as it's for MAC only.
# We need to clean npm cache as it's out of sync.
RUN npm cache clean --force \
  && npm install nativescript -g --unsafe-perm \
  && tns error-reporting disable \
	&& tns usage-reporting disable \
	&& apt-get install -y --no-install-recommends gradle
	
# Clean up & create app folder
RUN apt-get clean \
  && rm -r /var/lib/apt/lists/* \
  && mkdir -p /app
	
VOLUME ["/app"]

WORKDIR /app