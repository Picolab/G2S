FROM ubuntu:16.04

WORKDIR /home/pico_agent

# Install environment
RUN apt-get update -y && apt-get install -y \
    sudo \
    curl \
    python3.5 \
    python3-pip \
    python-setuptools \
    apt-transport-https \
    ca-certificates \
    software-properties-common
    
RUN pip3 install -U \
    pip \
    setuptools \
    asyncio

# Install indy-sdk
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68DB5E88 \
    && add-apt-repository "deb https://repo.sovrin.org/sdk/deb xenial master" \
    && apt-get update \
    && apt-get install -y \
    libindy=1.6.2~720

# Install Node.js
RUN curl --silent --location https://deb.nodesource.com/setup_9.x | sudo bash -
RUN apt-get update --yes
RUN apt-get install --yes nodejs
RUN apt-get install --yes build-essential

# Setup Pico-Agent
COPY package*.json ./
RUN npm install
#RUN npm start

EXPOSE 8080
CMD [ "npm", "start" ]