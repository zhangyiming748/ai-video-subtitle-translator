# ai-video-subtitle-translator
批量使用人工智能获取并生成mp4视频文件的srt字幕，翻译并生成双语字幕，转换为带有ass外挂字幕的mkv文件

# usage
模型文件放在视频文件夹下的model文件夹里 (/data/model)
默认使用medium模型
可以通过环境变量指定 -e model=large

```shell
docker run -dit --name test golang:1.22.2-bookworm bash
docker exec -it test bash
docker build -t srt:latest .
docker run -dit --name=whisper_en  -v '/mnt/f/ubuntu/jp/en:/data' -e language=English avst:latest srt
docker run -dit --name=whisper_en -v '/Users/zen/Movies:/data' -e language=English -e pattern=m4a avst:latest bash
docker run -dit --name=whisper_sp --rm -v '/c/Users/zen/Videos/sp:/data' -e pattern=webm -e language=Spanish zhangyiming748/avst:v0.0.1 srt
docker run -dit --name=whisper_ja --rm -v '/f/data:/data' -e language=Japanese avst:latest srt
docker run -dit --name=whisper_ja --rm -v '/f/ubuntu/jp/ja:/data' -e language=Japanese avst:latest srt
docker run -dit --name=whisper_de --rm -v '/f/Telegram/data/cut/en:/data' -e language=German avst:latest srt
docker run -dit --name=whisper_ru --rm -v '/f/alist/bilibili/ru:/data' -e language=Russian avst:latest srt
docker run -dit --name=whisper_en --cpus=1 --memory=2048M --rm  -v /d/git/WhisperInDocker:/data -e language=English avst:latest srt
```
