document.addEventListener('DOMContentLoaded', () => {
    const video1 = document.getElementById('video1');
    const video2 = document.getElementById('video2');
    const syncBtn = document.getElementById('sync-play-btn');
    const accordionToggle = document.getElementById('accordion-toggle');
    const accordionContent = document.getElementById('accordion-content');
    const gallery = document.querySelector('.grid-gallery');
    
    // 生成20个神兽动画格
    for (let i = 1; i <= 20; i++) {
        const div = document.createElement('div');
        div.className = 'beast-card';
        div.textContent = `神兽 ${i}`;
        gallery.appendChild(div);
    }
    
    // 折叠面板控制
    let isExpanded = false;
    accordionToggle.addEventListener('click', () => {
        isExpanded = !isExpanded;
        const span = accordionToggle.querySelector('span');
        if (isExpanded) {
            span.textContent = '▲';
            accordionContent.style.maxHeight = accordionContent.scrollHeight + "px";
        } else {
            span.textContent = '▼';
            accordionContent.style.maxHeight = "0px";
        }
    });

    // ----------------------------------------
    // 视频同步逻辑: 基于事件双向绑定
    // ----------------------------------------
    let isSeeking = false;
    
    // 一键同步按钮：方便用户无忧播放
    syncBtn.addEventListener('click', () => {
        if (video1.paused || video2.paused) {
            video1.play();
            video2.play();
        } else {
            video1.pause();
            video2.pause();
        }
    });
    
    // 核心绑定函数：令 target 同步 source
    const bindSync = (source, target) => {
        source.addEventListener('play', () => {
            if (target.paused) target.play().catch(e => console.warn('自动播放阻挡', e));
        });
        
        source.addEventListener('pause', () => {
            if (!target.paused) target.pause();
        });
        
        source.addEventListener('seeking', () => {
            // 防止相互触发导致的死循环
            if (!isSeeking && Math.abs(source.currentTime - target.currentTime) > 0.5) {
                isSeeking = true;
                target.currentTime = source.currentTime;
                // 延迟解开 seeking 锁
                setTimeout(() => { isSeeking = false; }, 50);
            }
        });
        
        source.addEventListener('ratechange', () => {
            target.playbackRate = source.playbackRate;
        });
    };
    
    bindSync(video1, video2);
    bindSync(video2, video1);

    // ----------------------------------------
    // 全屏与退出全屏事件通知与状态修复
    // 注：在 HTML5 视频 API 体系下，用户点击原生全屏控件或者触发 requestFullscreen，
    // 浏览器会自动将其提到视口最前端（并隐藏其他内容），ESC退出时原生恢复分屏，
    // 我们的两只视频在底层因为没有被销毁或手动暂停，依旧会受我们的 js 操控实现无缝同步！
    // ----------------------------------------
    document.addEventListener('fullscreenchange', () => {
        if (!document.fullscreenElement) {
            console.log('UI: 监听到退出全屏，已恢复至正常分屏状态，视频将保持原进度双轨同步');
        } else {
            console.log('UI: 视频已全屏', document.fullscreenElement.id);
        }
    });
});
