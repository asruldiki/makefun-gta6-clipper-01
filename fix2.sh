#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"
pkill -f "ffmpeg -nostdin" 2>/dev/null
sleep 1
# FIX 1: drop stray nested dir
rm -rf entry/entry
# FIX 3: stronger title
printf "%s\n" "iShowSpeed's FIRST GTA 6 Gunfight is CHAOS 😱 #GTA6 #Shorts" > TITLE.txt
S=footage/speed-first-time.webm
BASE="split=2[bg][fg];[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=30[b];[fg]scale=1080:-2[f];[b][f]overlay=(W-w)/2:(H-h)/2"
F=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
HOOK=",drawtext=fontfile=$F:textfile=entry/txt/hook1.txt:fontcolor=white:fontsize=84:borderw=5:bordercolor=black:x=(w-tw)/2:y=300:enable='lt(t,3)',drawtext=fontfile=$F:textfile=entry/txt/hook2.txt:fontcolor=yellow:fontsize=84:borderw=5:bordercolor=black:x=(w-tw)/2:y=420:enable='lt(t,3)'"
log(){ echo "[$(date +%H:%M:%S)] $*"; }
if [ -s segA.mp4 ] && [ segA.mp4 -nt cut.sh ]; then
  log "reuse A"
else
log "cut A"
ffmpeg -nostdin -y -ss 1435 -to 1444 -i "$S" -filter_complex "[0:v]$BASE$HOOK" -c:v libx264 -preset veryfast -crf 20 -r 30 -pix_fmt yuv420p -c:a aac -ar 48000 -ac 2 segA.mp4 -loglevel error || exit 1
fi
log "cut B"
ffmpeg -nostdin -y -ss 1452 -to 1478 -i "$S" -filter_complex "[0:v]$BASE" -c:v libx264 -preset veryfast -crf 20 -r 30 -pix_fmt yuv420p -c:a aac -ar 48000 -ac 2 segB.mp4 -loglevel error || exit 1
log "card"
if [ ! -f card.png ]; then
  ffmpeg -nostdin -y -ss 1466 -i "$S" -frames:v 1 card.png -loglevel error || exit 1
fi
printf "%s\n" "Made by my AI agent for a \$500 bounty on make.fun" "where you can earn money making clips with AI:" "https://make.fun/bounty/gta6-clipper-01" > txt/card.txt
log "cut C"
ffmpeg -nostdin -y -loop 1 -t 6 -i card.png -f lavfi -t 6 -i anullsrc=r=48000:cl=stereo -filter_complex "[0:v]fps=30,scale=270:480:force_original_aspect_ratio=increase,crop=270:480,gblur=sigma=8,eq=brightness=-0.30,scale=1080:1920,drawtext=fontfile=$F:textfile=txt/card.txt:fontsize=46:line_spacing=16:fontcolor=white:borderw=5:bordercolor=black:box=1:boxcolor=black@0.6:boxborderw=22:x=(w-text_w)/2:y=(h-text_h)/2,format=yuv420p[v]" -map "[v]" -map 1:a -t 6 -r 30 -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -c:a aac -ar 48000 -ac 2 segC.mp4 -loglevel error || exit 1
log "concat"
printf "file 'segA.mp4'\nfile 'segB.mp4'\nfile 'segC.mp4'\n" > seglist.txt
ffmpeg -nostdin -y -f concat -safe 0 -i seglist.txt -c copy -movflags +faststart clip-final.mp4 -loglevel error || exit 1
log "probe"
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 clip-final.mp4
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 clip-final.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 clip-final.mp4
log "done"