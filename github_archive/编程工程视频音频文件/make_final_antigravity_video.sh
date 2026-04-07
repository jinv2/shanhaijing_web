#!/bin/bash

# 进入工作目录
cd "/home/mmm/桌面/Shensist_Matrix/shanhaijing_web/编程工程视频音频文件"

# 清理并创建临时目录
rm -rf temp_antigravity
mkdir -p temp_antigravity

# 参数设置
DURATION=2
FPS=24
WIDTH=800
HEIGHT=800

# 检查图片和音乐是否存在
echo "=== 检查素材 ==="
if [ ! -f "音乐_128k.opus" ]; then
    echo "❌ 找不到音乐文件: 音乐_128k.opus"
    exit 1
fi
echo "✅ 音乐文件存在"

# 清空片段列表
> temp_antigravity/segments.txt

# 循环处理 1 到 20
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20; do
    ORIG="神兽图片/神兽/webp_versions/${i}.webp"
    ROBOT="神兽图片/机器人/webp_versions/${i}R.webp"
    
    if [ -f "$ORIG" ] && [ -f "$ROBOT" ]; then
        echo "✅ 处理: 神兽 ${i} + 机器人 ${i}"
        
        # 神兽原版片段（反重力悬浮）
        ffmpeg -loop 1 -i "$ORIG" -t $DURATION \
            -vf "scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=1,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,drawtext=text='神兽 ${i}':fontsize=36:fontcolor=white:x=20:y=20,drawtext=text='⚡ ANTIGRAVITY':fontsize=20:fontcolor=#ffcc00:x=w-200:y=h-40" \
            -c:v libx264 -pix_fmt yuv420p -r $FPS -y "temp_antigravity/orig_${i}.mp4" 2>/dev/null
        
        # 机器人版片段（金属质感 + 反重力）
        ffmpeg -loop 1 -i "$ROBOT" -t $DURATION \
            -vf "scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=1,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:contrast=1.1,drawtext=text='机器人 ${i}':fontsize=36:fontcolor=#ffcc00:x=20:y=20,drawtext=text='⚙️ MECHA MODE':fontsize=20:fontcolor=#00ccff:x=w-200:y=h-40" \
            -c:v libx264 -pix_fmt yuv420p -r $FPS -y "temp_antigravity/robot_${i}.mp4" 2>/dev/null
        
        echo "file 'orig_${i}.mp4'" >> temp_antigravity/segments.txt
        echo "file 'robot_${i}.mp4'" >> temp_antigravity/segments.txt
    else
        echo "⚠️ 跳过: 神兽 ${i} 或机器人 ${i} 图片缺失"
        echo "   缺少: $ORIG 或 $ROBOT"
    fi
done

# 检查是否有片段生成
SEGMENT_COUNT=$(cat temp_antigravity/segments.txt 2>/dev/null | wc -l)
if [ $SEGMENT_COUNT -eq 0 ]; then
    echo "❌ 没有生成任何视频片段，请检查图片路径"
    exit 1
fi

echo "=== 合并视频片段 ==="
cd temp_antigravity
ffmpeg -f concat -safe 0 -i segments.txt -c copy temp_merged.mp4 -y 2>/dev/null

if [ ! -f "temp_merged.mp4" ]; then
    echo "❌ 视频合并失败"
    exit 1
fi

echo "=== 添加背景音乐 ==="
cd ..
ffmpeg -i temp_antigravity/temp_merged.mp4 -i "音乐_128k.opus" \
    -c:v copy -c:a aac -b:a 128k -map 0:v:0 -map 1:a:0 \
    -shortest -y "antigravity_final.mp4" 2>/dev/null

if [ -f "antigravity_final.mp4" ]; then
    echo ""
    echo "🎉 成功！视频已生成: antigravity_final.mp4"
    ls -lh antigravity_final.mp4
    echo ""
    echo "📹 播放命令:"
    echo "   ffplay antigravity_final.mp4"
    echo "   或: xdg-open antigravity_final.mp4"
else
    echo "❌ 最终视频生成失败"
fi

# 清理临时文件（可选，注释掉以便调试）
# rm -rf temp_antigravity
