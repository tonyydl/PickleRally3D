# 開發文件索引

文件與遊戲程式一同保留在本儲存庫；專案貢獻指南位於根目錄 [AGENTS.md](../AGENTS.md)。

## 遊戲設計規格

- [初版單打原型設計](superpowers/specs/2026-10-22-pickle-rally-design.md)：球場、物理、規則、AI、單打計分與原型範圍。
- [五種打法與直接擊球操作](superpowers/specs/2026-10-22-five-shots-design.md)：使用者選定方案 A 的操作、球路差異、AI、回饋與驗收標準；後續球路開發以此補充初版規格。
- [網頁版自動低效能模式](superpowers/specs/2026-10-22-web-low-performance-mode-design.md)：軟體繪圖辨識、FPS 備援與畫面調整範圍。

## 開發計畫與驗證紀錄

- [初版開發計畫](superpowers/plans/2026-10-22-pickle-rally.md)／[初版進度與驗證](progress.md)
- [五種打法開發計畫](superpowers/plans/2026-10-22-five-shots.md)／[五種打法進度與驗證](progress-five-shots.md)
- [網頁版自動低效能模式計畫](superpowers/plans/2026-10-23-web-auto-performance.md)

## 遊玩與畫面

- [Windows／網頁匯出說明](export.md)：模板安裝、重複打包、本機預覽與分享方式。
- [遊戲 README](../README.md)：最新已實作操作、啟動指令與原型限制。
- [遊戲預覽](preview.png)：實際 Godot GPU 渲染畫面。

新增功能時，保留舊階段規格與驗證紀錄，另外新增功能文件並更新此索引；若改變既有操作或數值決策，同步更新遊戲 README 及對應規格。
