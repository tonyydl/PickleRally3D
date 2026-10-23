# Windows 與網頁版匯出

目前提供兩個 Release 預設，設定保存在根目錄 `export_presets.cfg`。遊戲玩法與操作相同。

## 準備環境

1. 使用 Godot **4.7.2 stable**，並確認 `godot --version`。
2. 在 Godot 的 **Editor → Manage Export Templates** 安裝同版本模板；Windows x86_64 與 Web 單執行緒匯出需要對應模板。
3. 執行 `powershell -ExecutionPolicy Bypass -File tools/check_project.ps1`，確認專案匯入及測試通過。

本機 Scoop 的 Godot 使用可攜式資料目錄，模板位於 `C:\Users\Tony\scoop\apps\godot\current\editor_data\export_templates\4.7.2.stable\`。其他安裝方式通常位於 `%APPDATA%\Godot\export_templates\4.7.2.stable\`。模板須與引擎版本一致，不能混用舊版。

## 重複打包

在儲存庫根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/export_project.ps1
powershell -ExecutionPolicy Bypass -File tools/export_project.ps1 -Target Windows
powershell -ExecutionPolicy Bypass -File tools/export_project.ps1 -Target Web
```

預設匯出兩種平台。腳本遇到 Godot 錯誤、警告或失敗退出碼會停止，日誌存入 `.tools/export/`；成功後附上授權、操作說明並產生 ZIP。腳本不會自動執行測試，發布前另跑完整驗證。

| 平台 | 啟動檔 | 分享包 |
| --- | --- | --- |
| Windows x86_64 | `builds/windows/PickleRally3D.exe` | `builds/PickleRally3D-windows.zip` |
| Web | `builds/web/index.html` | `builds/PickleRally3D-web.zip` |

`builds/` 不提交 Git，並以 `.gdignore` 排除 Godot 資源掃描。測試、工具、開發文件及既有產物不納入遊戲資源包。使用固定的輸出資料夾供此腳本管理，避免手動放入額外檔案後一併壓縮分享。

## Windows 遊玩

解壓 Windows ZIP，雙擊 EXE。遊戲資料嵌入 EXE，玩家不需要 Godot 或另附 PCK。保留包內授權文件。這是未簽署的原型版本，尚未製作安裝程式或自訂執行檔圖示。

## 網頁預覽與上架

```powershell
python -m http.server 8060 --bind 127.0.0.1 --directory builds/web
```

開啟 <http://127.0.0.1:8060/>；按 Ctrl+C 停止伺服器。需要 Python。不能直接以 `file://` 開啟 HTML。

部署時將 `builds/web/` 完整內容上傳至 HTTP／HTTPS 靜態網站，保持 HTML、JavaScript、WASM、PCK 的相對位置與檔名。亦可將 Web ZIP 上傳至 itch.io 的 HTML 遊戲專案，ZIP 根目錄已包含 `index.html`。目前只產生本機檔案，未公開部署。

Web 使用 Compatibility／WebGL 2.0、WebAssembly 與單執行緒，不需要 COOP／COEP 隔離標頭。以桌面 Chrome 或 Firefox 測試；先點擊畫面取得鍵盤焦點並允許音效播放。仍須鍵盤與滑鼠，未提供手機觸控。若啟動時辨識到 SwiftShader 等軟體繪圖器，立即降低畫質；若瀏覽器未提供繪圖器資訊，遊戲視窗有焦點且連續 2 秒低於 25 FPS 時也會自動切換。重新載入網頁會重新判斷。網頁版效能與聲音表現可能和原生版本不同。

## 字型與授權

HUD 保留既有系統字型選擇，另以內附的 `assets/fonts/NotoSansTC.ttf` 備援，避免網頁版缺少中文字形。模型與音效仍由程式產生。

- [Godot 引擎授權](distribution/GODOT_LICENSE.txt)：來源為 [Godot 4.7.2 LICENSE.txt](https://github.com/godotengine/godot/blob/4.7.2-stable/LICENSE.txt)，隨分享包附上。
- [Godot 內含第三方元件聲明](distribution/GODOT_COPYRIGHT.txt)：來源為同版引擎的 `COPYRIGHT.txt`，隨分享包附上。
- [Noto Sans TC 字型來源](https://github.com/google/fonts/tree/main/ofl/notosanstc)，使用 SIL Open Font License 1.1；原始授權存於 `assets/fonts/OFL.txt`，匯出時另附 `NOTO_FONT_LICENSE.txt`。
- [Godot Windows 匯出文件](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html)
- [Godot Web 匯出文件](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)

## 本次驗證（2026-10-22）

- 完整 `check_project.ps1` 八組檢查通過，包含實際輸入事件與 AI 75 拍來回。
- Windows／Web Release 匯出成功，兩個 ZIP 根目錄的啟動檔及授權文件已檢查。
- Windows EXE 複製到獨立目錄，以嵌入資料啟動；headless 啟動與 NVIDIA RTX 3080 的實際 GPU 畫面通過，無錯誤或警告。
- 桌面 Chrome 已載入 WebAssembly 遊戲，檢查中文、發球、暫停、重開與右鍵輸入，未記錄瀏覽器錯誤或警告。尚未完成整場人工對戰、主觀音效確認或其他瀏覽器／電腦測試。
