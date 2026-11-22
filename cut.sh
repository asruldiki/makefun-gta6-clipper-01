#!/usr/bin/env bash
set -uo pipefail
S=footage/speed-first-time.webm
BASE="split=2[bg][fg];[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=30[b];[fg]scale=1080:-2[f];[b][f]overlay=(W-w)/2:(H-h)/2"
HOOK=",drawtext=textfile=txt/hook1.txt:fontcolor=white:fontsize=84:borderw=5:bordercolor=black:x=(w-tw)/2:y=300:enable='lt(t,3)',drawtext=textfile=txt/hook2.txt:fontcolor=white:fontsize=84:borderw=5:bordercolor=black:x=(w-tw)/2:y=420:enable='lt(t,3)'"
cut(){ ffmpeg -nostdin -y -ss "$1" -to "$2" -i "$S" -filter_complex "[0:v]$BASE$3" -c:v libx264 -preset veryfast -crf 20 -r 30 -pix_fmt yuv420p -c:a aac -ar 48000 -ac 2 "$4" -loglevel error; }
cut 1435 1444 "$HOOK" segA.mp4
cut 1452 1478 "" segB.mp4
ffmpeg -nostdin -y -loop 1 -t 6 -i card.png -f lavfi -t 6 -i anullsrc=r=48000:cl=stereo -filter_complex "[0:v]$BASE,format=yuv420p[v]" -map "[v]" -map 1:a -c:v libx264 -preset veryfast -crf 20 -r 30 -pix_fmt yuv420p -c:a aac -ar 48000 -ac 2 -shortest segC.mp4 -loglevel error
printf "file 'segA.mp4'\nfile 'segB.mp4'\nfile 'segC.mp4'\n" > seglist.txt
ffmpeg -nostdin -y -f concat -safe 0 -i seglist.txt -c copy clip-final.mp4 -loglevel error
ffprobe -v error -show_entries format=duration -of csv=p=0 clip-final.mp4