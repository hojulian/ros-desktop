# UBUNTU WITH OPENGL CUDA -----------------------------------------------------------------------
FROM nvidia/cudagl:10.2-devel-ubuntu18.04
LABEL maintainer="Julian Ho"

# update ubuntu and install all dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        lxterminal \
        openssh-server \
        nfs-common \
        lsb-release \
        mesa-utils \
        python \
        python-dev \
        python-pip \
        python-mako \
        git \
        xvfb \
        jwm \
        x11vnc \
        llvm-7-dev \
        make \
        nano \
        wget \
        sudo \
        curl && \
        rm -rf /var/lib/apt/lists/*

# install ros
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
RUN curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ros-melodic-image-transport \
        ros-melodic-cv-bridge \
        ros-melodic-rqt \
        ros-melodic-rqt* \
        ros-melodic-rviz \
        ros-melodic-desktop-full && \
        rm -rf /var/lib/apt/lists/*

# get code-server
RUN curl -fOL https://github.com/cdr/code-server/releases/download/v3.4.1/code-server_3.4.1_amd64.deb
RUN dpkg -i code-server_3.4.1_amd64.deb
RUN rm -rf code-server_3.4.1_amd64.deb

# get and setup novnc
WORKDIR /novnc
RUN git clone https://github.com/novnc/noVNC.git

# fix for offline mode -> prefatch websockify
RUN cd ./noVNC/utils && git clone https://github.com/novnc/websockify

# set the environment variables (display -> 99 and LIBGL_ALWAYS_SOFTWARE)
ENV DISPLAY=":99" \
    LP_DEBUG="" \
    LP_NO_RAST="false" \
    LP_NUM_THREADS="" \
    LP_PERF="" \
    MESA_VERSION="19.0.2" \
    XVFB_WHD="1920x1080x24" \
    MESA_GLSL="errors" \
    PASSWORD="dev@ros" \
    TERM=lxterminal

# setup vnc password
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd $PASSWORD ~/.vnc/passwd

# setup jwm
COPY .jwmrc /entry/

# setup the entrypoint script
COPY entrypoint.sh /entry/
RUN chmod +x /entry/entrypoint.sh
ENTRYPOINT ["/entry/entrypoint.sh"]

# set the default shell
SHELL ["/bin/bash", "-c"]

# source ros for every new terminal session
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

# set our workdir
WORKDIR /workspace

# expose the novnc and code-server ports
EXPOSE 6080
EXPOSE 8080
