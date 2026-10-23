# Pickle Rally 3D

Windows 優先、明亮低多邊形的 3D 匹克球單打原型。使用 **Godot 4.7.2 stable**、GDScript、Compatibility 渲染器；所有模型與音效由程式產生。內附 Noto Sans TC 備援字型，讓網頁版與不同電腦能顯示中文。`MyFirstGame` 是另一個既有專案，本遊戲位於獨立資料夾。

## 啟動

以 Godot 開啟本資料夾的 `project.godot`，按 **F5**。本機已安裝 Godot，也可雙擊 `launch.cmd`，或執行：

```powershell
godot --path C:\Users\Tony\GameDev\PickleRally3D
```

## 打包與分享

安裝與編輯器相同版本的 Godot 匯出模板後，在專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/export_project.ps1
# 只匯出其中一種：加上 -Target Windows 或 -Target Web
```

- Windows：`builds/windows/PickleRally3D.exe`，資料已嵌入 EXE；分享 `builds/PickleRally3D-windows.zip`，解壓後雙擊執行，玩家不需安裝 Godot。
- 網頁：`builds/web/index.html` 及其配套檔案；分享／上傳 `builds/PickleRally3D-web.zip`。使用桌面瀏覽器、鍵盤與滑鼠。
- 本機預覽網頁：`python -m http.server 8060 --bind 127.0.0.1 --directory builds/web`，開啟 <http://127.0.0.1:8060/>；不能直接雙擊 HTML 執行。

網頁版若在啟動時辨識到 SwiftShader 等軟體繪圖器，會立即關閉即時陰影並隱藏場邊裝飾；若瀏覽器未提供繪圖器資訊，遊戲視窗有焦點且連續 2 秒低於 25 FPS 時也會自動切換。流暢時維持原有畫質；重新載入網頁會重新判斷。此模式減少繪圖負擔，但軟體繪圖的效能仍依瀏覽器與電腦而異。

完整步驟、模板位置與授權來源見 [匯出說明](docs/export.md)。產物放在 Git 忽略的 `builds/`；匯出設定與腳本保留在版本控制。

## 操作與第一場比賽

| 操作 | 效果 |
| --- | --- |
| WASD | 移動；擊球瞬間同時控制大致落點 |
| 滑鼠左鍵 | Drive 抽球；發球、回合結束後繼續 |
| 滑鼠右鍵 | 近網 Dink 網前小球；中後場 Drop 放短球 |
| Space | Lob 高吊球 |
| Shift + 滑鼠左鍵 | Smash 扣殺；需可及高球，否則提示並改為 Drive |
| A / D + 擊球 | 打向左側 / 右側 |
| W / S + 擊球 | 深球 / 短球 |
| 不按方向 + 擊球 | 安全回到對方中央 |
| Esc | 暫停 / 繼續 |
| R | 整場重新開始 |

1. 角色已站在底線後方，按左鍵對角發球；發球目標會自動保持正確對角。
2. AI 回球後，往**黃色預測落點圈**移動，讓接發回球先彈地，再靠近球按左鍵。提早約 0.3 秒按鍵也能接上。
3. 雙方各讓球落地一次後，可在 Kitchen 外向前靠近並截擊；彩圈表示你的出球目標，黃色圈仍是來球預測落點。
4. 安全回中央可以持續對打；上網後交替打向左右可突破 AI。AI 有反應延遲、速度限制，且必須移動到球後方才能回擊。
5. 回合結束會顯示原因、得分或換發球；按左鍵繼續。AI 發球時先按左鍵準備，0.8 秒後 AI 自動發球。

## 五種打法（方案 A：按鍵直接擊球）

| 打法 | 如何使用與球路差異 |
| --- | --- |
| Drive | 左鍵；較快、中深場的抽球，適合一般來回與穿越空檔 |
| Dink | 右鍵，觸球時距網不超過 3.4 m；短距離低速送進對方 Kitchen |
| Drop | 右鍵，觸球時距網超過 3.4 m；從中後場以柔和弧線放進 Kitchen |
| Lob | Space；高弧線落到深場，迫使已上網的對手退後 |
| Smash | Shift＋左鍵，球高至少 1.65 m 且角度可向下過網；快速向下扣殺 |

右側提示顯示右鍵目前對應 Dink／Drop、扣殺可用狀態與最近擊球。五種球路有不同目標範圍、飛行時間、弧度、揮拍幅度與聲音；黃色球的大小不變。AI 也共用五種球路，依站位選擇短球、高吊與高壓進攻。

提早約 0.3 秒按鍵會保留該次擊球意圖；放開按鍵仍會在進入範圍時完成一次擊球。WASD 的方向與右鍵的近網／中後場判斷以實際觸球時為準。Smash 高度或角度不足會清楚提示並改用 Drive，不會平白消耗回球。右鍵與 Space 不會啟動發球或跳過回合結果；發球一律用左鍵並保持合法對角。

Kitchen 可自由進入並擊打已落地的球；五種打法均不能繞過 Kitchen 截擊或兩次落地限制。球速與高壓球已為原型操作做輔助，並非真人動作／球拍碰撞模擬。

## 已實作

- 6.096 × 13.4112 公尺球場；兩側 Kitchen 深 2.1336 公尺；球網中央高 0.8636、側邊高 0.9144 公尺；白線寬 0.0508 公尺。
- 球員後方的高位第三人稱鏡頭，能看清整座球場與對手；簡單走路、揮拍動畫。
- 重力彈道、反彈、連續碰網判定、落點圈、球影、尾跡、擊球與落地聲音。
- 下手發球、Dink／Drive／Lob／Drop／Smash 五種球路、合法網前截擊，以及共享球路與擊球判定的追球 AI。
- 對角發球、依發球方分數奇偶換側、發球站位、兩次落地規則、Kitchen 截擊與截擊後踏入限制。
- 界內外、白線界內、發球 Kitchen 線界外、兩次彈地、傳統發球方得分制、先到 11 分且領先 2 分。
- 中文比分、發球方、回合結果、拍數、勝利畫面、暫停及重新開始。

## 原型取捨

球體碰撞半徑 0.04 公尺，視覺半徑放大至 0.105 公尺，並提供寬容的玩家擊球範圍與時間窗。方向鍵選擇安全的大致落點，各球路自動調整可過網的弧線；未做自由力道、旋轉、跳躍或體力。球採確定性的彈道模擬，沒有使用 RigidBody3D，重力與反彈係數不隨打法改變。

碰到網面且無法越網會立即判失分；尚未模擬擦網帶後翻越、繞網球、球擊中身體、球拍越網，以及完整的步伐／裁判判例。Kitchen 截擊後進區的檢查持續至下一次球落地，未建立完整慣性動作裁判系統。初版不含雙打、連線、角色自訂、手機操作或正式競賽認證。

## 結構與驗證

`scripts/shots.gd`：五種球路與意圖解析；`flight.gd`：彈道與碰撞；`rules.gd`：純單打規則與計分；`actor.gd`：移動及模型；`court.gd`：場地；`match.gd`：輸入／AI／比賽流程；`hud.gd`：介面。

開發文件入口：[docs/README.md](docs/README.md)；貢獻指南：[AGENTS.md](AGENTS.md)。

```powershell
powershell -ExecutionPolicy Bypass -File tools/check_project.ps1
# 實際 GPU 渲染截圖存至 .tools/visual/
godot --path . --script tools/capture.gd
```

測試涵蓋五種球路的速度／弧頂／目標、低球扣殺降級、連續碰撞、單打規則、11–10 繼續／12–10 獲勝、重置、AI 真實來回與得分、指定球路的提前揮拍緩衝、終局與暫停凍結，以及 Godot 實際輸入事件（WASD／左右鍵／Space／Shift＋左鍵／Esc／R）。驗證工具會將任何錯誤、警告或非零退出碼判為失敗。

規則依據：[USA Pickleball 規則摘要](https://www.usapickleball.org/docs/rules/USAP-Rules-Summary.pdf)。命令列與驗證方式：[Godot 官方文件](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)。
