#!/bin/bash

echo "========================================="
echo "   神兽机器人 · 反重力视频生成器"
echo "========================================="

# 检查素材
if [ ! -d "神兽图片/神兽/webp_versions" ]; then
    echo "❌ 错误: 找不到神兽图片目录"
    exit 1
fi

if [ ! -d "神兽图片/机器人/webp_versions" ]; then
    echo "❌ 错误: 找不到机器人图片目录"
    exit 1
fi

if [ ! -f "音乐_128k.opus" ]; then
    echo "⚠️ 警告: 找不到音乐文件，将生成无声音视频"
    HAS_AUDIO=0
else
    HAS_AUDIO=1
    echo "✅ 音乐文件: 音乐_128k.opus"
fi

# 清理旧文件
rm -rf temp_antigravity
mkdir -p temp_antigravity

DURATION=2
FPS=24
W=800
H=800

> temp_antigravity/segments.txt
COUNT=0

echo ""
echo "开始处理 20 对神兽机器人图片..."

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20; do
    ORIG="神兽图片/神兽/webp_versions/${i}.webp"
    ROBOT="神兽图片/机器人/webp_versions/${i}R.webp"
    
    if [ -f "$ORIG" ] && [ -f "$ROBOT" ]; then
        echo "  ✅ 处理: 神兽 ${i} + 机器人 ${i}"
        
        # 神兽原版（反重力悬浮文字）
        ffmpeg -loop 1 -i "$ORIG" -t $DURATION \
            -vf "scale=$W:$H:force_original_aspect_ratio=1,pad=$W:$H:(ow-iw)/2:(oh-ih)/2,drawtext=text='神兽 ${i}':fontsize=36:fontcolor=white:x=20:y=20,drawtext=text='⚡ ANTIGRAVITY':fontsize=20:fontcolor=#ffcc00:x=w-180:y=h-40" \
            -c:v libx264 -pix_fmt yuv420p -r $FPS -y "temp_antigravity/orig_${i}.mp4" 2>/dev/null
        
        # 机器人版（金属质感）
        ffmpeg -loop 1 -i "$ROBOT" -t $DURATION \
            -vf "scale=$W:$H:force_original_aspect_ratio=1,pad=$W:$H:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:contrast=1.1,drawtext=text='机器人 ${i}':fontsize=36:fontcolor=#ffcc00:x=20:y=20,drawtext=text='⚙️ MECHA MODE':fontsize=20:fontcolor=#00ccff:x=w-180:y=h-40" \
            -c:v libx264 -pix_fmt yuv420p -r $FPS -y "temp_antigravity/robot_${i}.mp4" 2>/dev/null
        
        echo "file 'orig_${i}.mp4'" >> temp_antigravity/segments.txt
        echo "file 'robot_${i}.mp4'" >> temp_antigravity/segments.txt
        ((COUNT++))
    else
        echo "  ⚠️ 跳过: 神兽 ${i} (缺少文件)"
    fi
done

echo ""
echo "已处理 ${COUNT} 对图片"

if [ $COUNT -eq 0 ]; then
    echo "❌ 没有成功处理任何图片，请检查 webp_versions 目录"
    exit 1
fi

# 合并视频
echo ""
echo "合并视频片段..."
cd temp_antigravity
ffmpeg -f concat -safe 0 -i segments.txt -c copy temp_merged.mp4 -y 2>/dev/null
cd ..

# 添加音频
if [ $HAS_AUDIO -eq 1 ]; then
    echo "添加背景音乐..."
    ffmpeg -i temp_antigravity/temp_merged.mp4 -i "音乐_128k.opus" \
        -c:v copy -c:a aac -b:a 128k -map 0:v:0 -map 1:a:0 \
        -shortest -y "antigravity_final.mp4" 2>/dev/null
else
    mv temp_antigravity/temp_merged.mp4 antigravity_final.mp4
fi

# 清理临时文件
rm -rf temp_antigravity

echo ""
echo "========================================="
echo "🎉 生成成功！"
echo "========================================="
ls -lh antigravity_final.mp4
echo ""
echo "播放命令: ffplay antigravity_final.mp4"
echo "或: xdg-open antigravity_final.mp4"
