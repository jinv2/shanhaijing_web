#!/bin/bash
echo "file 'list.txt'" > concat.txt
> list.txt

for i in {01..20}; do
  # 找原版图
  orig=$(find 神兽 -maxdepth 1 -name "${i}.*" | head -1)
  rob=$(find 机器人 -maxdepth 1 -name "${i}R.*" | head -1)
  
  if [ -f "$orig" ] && [ -f "$rob" ]; then
    # 每对生成 3 秒悬浮片段
    ffmpeg -loop 1 -i "$orig" -t 1.5 \
      -vf "scale=800:800,format=rgba,geq='if(lte(abs(X-400),200)*lte(abs(Y-400),200), lum, lum*0.3)',drawtext=text='神兽${i}':fontsize=30:fontcolor=white:x=10:y=10" \
      -c:v libx264 -pix_fmt yuv420p -f mp4 temp_${i}_a.mp4 -y
      
    ffmpeg -loop 1 -i "$rob" -t 1.5 \
      -vf "scale=800:800,format=rgba,geq='if(lte(abs(X-400),200)*lte(abs(Y-400),200), lum*1.2, lum*0.5)',drawtext=text='机器人${i}':fontsize=30:fontcolor=yellow:x=10:y=10" \
      -c:v libx264 -pix_fmt yuv420p -f mp4 temp_${i}_b.mp4 -y
      
    echo "file 'temp_${i}_a.mp4'" >> list.txt
    echo "file 'temp_${i}_b.mp4'" >> list.txt
  fi
done

# 合成最终视频
ffmpeg -f concat -safe 0 -i list.txt -c copy 神兽机器人_antigravity.mp4

# 清理
rm temp_*_?.mp4 list.txt
