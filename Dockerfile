FROM ubuntu:16.04

# Update apt-get
RUN apt-get update \
  && apt-get upgrade -y \
  && rm -r /var/lib/apt/lists/*

# Utilities
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl wget unzip libterm-readline-gnu-perl \
  && rm -r /var/lib/apt/lists/*

# JAVA 8
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
  && rm -r /var/lib/apt/lists/*

# NodeJS v8.x LTS
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    nodejs \
  && rm -r /var/lib/apt/lists/*

# Android build requirements
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lib32stdc++6 lib32z1 \
  && rm -r /var/lib/apt/lists/*

# Install the latest SDK command line tools
RUN cd /opt \
  && wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
  && unzip android-sdk.zip -d android-sdk-linux \
  && rm -f android-sdk.zip \
  && chown -R root:root android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}

# Create repo file
RUN mkdir -p ~/.android/ \
  && touch ~/.android/repositories.cfg

# Accept Android licenses
RUN yes | sdkmanager --licenses

# Install Android platform tools
RUN sdkmanager --verbose "platform-tools" "tools"

# Install SDKs (and accept licenses)
RUN yes | sdkmanager --verbose \
  "platforms;android-28" \
  "build-tools;28.0.3" \
  "extras;android;m2repository" \
  "extras;google;m2repository"

# NativeScript
# Note: you will get an error "npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents".
# This is ok as it's for MAC only.
# We need to clean npm cache as it's out of sync.
RUN npm cache clean --force \
  && npm install nativescript -g --unsafe-perm \
  && tns error-reporting disable \
  && tns usage-reporting disable

# Changed Gradle to write to /app/.gradle
# If you want Gradle to reside inside image, uncomment following lines
# This is the easiest way to get Gradle installed: make a temp build
#RUN mkdir /app  \
#  && tns create testapp --js \
#  && cd testapp \
#  && tns platform add android \
#  && tns build android \
#  && cd /app \
#  && rm -rf /app/testapp

# Copy additional tools in place
COPY tools/* /opt/tools/
RUN chmod +x /opt/tools/*

ENV PATH /opt/tools:${PATH}

# Create /app folder
RUN mkdir -p /app

VOLUME ["/app"]

WORKDIR /app
