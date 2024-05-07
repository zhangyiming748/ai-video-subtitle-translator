FROM golang:1.22.2-bookworm
ARG proxy="192.168.1.20:8889"
VOLUME /data
LABEL authors="zen"
WORKDIR /root
# 设置golang环境
RUN go env -w GO111MODULE=on
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go env -w GOBIN=/root/go/bin

# 设置apt环境
RUN mv /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
#RUN sed -i 's/deb.debian.org/mirrors4.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources
COPY debian.sources /etc/apt/sources.list.d
RUN apt update
RUN apt full-upgrade -y
RUN apt install -y dos2unix

# 下载必要软件
COPY install-retry.sh /usr/local/bin
RUN chmod +x /usr/local/bin/install-retry.sh
RUN dos2unix /usr/local/bin/install-retry.sh
RUN #install-retry.sh ffmpeg mediainfo vim nano less ca-certificates wget bsdmainutils sqlite3 gawk locales libfribidi-bin python3 python3-pip software-properties-common
RUN install-retry.sh ffmpeg mediainfo ca-certificates sqlite3 locales  python3 python3-pip translate-shell
RUN apt clean

# 下载Whisper

RUN pip config set global.index-url https://mirrors.ustc.edu.cn/pypi/web/simple
#RUN pip install -i https://mirrors.ustc.edu.cn/pypi/web/simple openai-whisper --break-system-packages
# 如果已经准备好了大部分缓存 可以替换为以下代码 加快构建过程
RUN mkdir -p /root/.cache
COPY pip.tar /root/.cache
WORKDIR /root/.cache
RUN tar xvf pip.tar
RUN pip install openai-whisper --break-system-packages
RUN pip cache purge

#下载安装translate-shell
#RUN git clone https://github.com/soimort/translate-shell.git --config https.proxy="http://$proxy"
#WORKDIR /root/app/translate-shell
#RUN make && make install

# 下载模型
#RUN mkdir /rooot/model
#WORKDIR /root/model
#RUN wget -e use_proxy=yes -e http_proxy=$proxy -e https_proxy=$proxy --timestamping https://openaipublic.azureedge.net/main/whisper/models/345ae4da62f9b3d59415adc60127b97c714f32e89e936602e85993674d08dcb1/medium.pt
# 如果已经下载好了模型 可以替换为以下代码 加快构建过程
#RUN mkdir /root/model
#WORKDIR /root/model
#COPY medium.pt .
#COPY large.pt .

# 下载程序
RUN mkdir /root/app
WORKDIR /root/app
RUN git clone https://github.com/zhangyiming748/WhisperInDocker.git --config "https.proxy=$proxy"
RUN git clone https://github.com/zhangyiming748/TransInDocker.git --config "https.proxy=$proxy"
RUN git clone https://github.com/zhangyiming748/mp4srt2mkvass.git --config "https.proxy=$proxy"

# 部署whisper程序
WORKDIR /root/app/WhisperInDocker
RUN CGO_ENABLED=1 go build -o /usr/local/bin/whisper main.go

# 部署trans程序
WORKDIR /root/app/TransInDocker
RUN CGO_ENABLED=1 go build -o /usr/local/bin/trans main.go

# 部署conver程序
WORKDIR /root/app/mp4srt2mkvass
RUN CGO_ENABLED=1 go build -o /usr/local/bin/conv main.go

COPY entrypoint.sh /usr/local/bin
RUN dos2unix /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
# docker run --rm --name test -dit -v /c/Users/zen/Github/ai-video-subtitle-translator:/data golang:1.22.2-bookworm bash
# docker exec -it test bash
# docker build --progress=plain -t avst:latest --no-cache .
# docker run --name avst --rm -dit -e language=en -e model=large -v '/home/zen:/data' avst:latest bash