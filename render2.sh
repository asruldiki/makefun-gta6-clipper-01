#!/bin/bash
cd "$(dirname "$0")"
F=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
set -e
mkdir -p cut
# segment A: source 1435-1444 (9s), hook text for first 3s
ffmpeg -y -ss 1435 -t 9 -i footage/speed-first-time.webm -filter_complex "\
[0:v]fps=30,split=2[b][f];\
[b]scale=270:480:force_original_aspect_ratio=increase,crop=270:480,gblur=sigma=6,eq=brightness=-0.12,scale=1080:1920[b2];\
[f]scale=1080:-2[f2];\
[b2][f2]overlay=(W-w)/2:(H-h)/2,\
drawtext=fontfile=$F:text='iShowSpeed GTA 6':fontcolor=white:fontsize=64:borderw=9:bordercolor=black:x=(w-text_w)/2:y=250:enable='lt(t,3)',\
drawtext=fontfile=$F:text='FIRST GUNFIGHT':fontcolor=yellow:fontsize=64:borderw=9:bordercolor=black:x=(w-text_w)/2:y=340:enable='lt(t,3)'\
[v]" -map "[v]" -map 0:a -r 30 -c:a aac -b:a 128k -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p cut/A.mp4
echo A_OK