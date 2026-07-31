# Spider-Man: Brand New Day

以 SwiftUI 製作的《蜘蛛人：重生日》電影 App。電影詳情、圖片、卡司、影片連結與相關電影由 TMDb API 提供。

## TMDb 設定

1. 到 [TMDb API Settings](https://www.themoviedb.org/settings/api) 取得 **API Read Access Token**。
2. 複製 `Config/Secrets.example.xcconfig`，並將副本命名為
   `Config/Secrets.xcconfig`。
3. 在 `Secrets.xcconfig` 中將 `YOUR_TMDB_READ_ACCESS_TOKEN` 換成真實 token。

`Secrets.xcconfig` 已列入 `.gitignore`，不會提交到版本庫。
`Config/Shared.xcconfig` 會以可選方式載入本機秘密檔，再透過
`Config/Info.plist` 將設定注入 App bundle 的 `TMDBReadAccessToken` 鍵；
其餘 Info.plist 內容仍由 Xcode 產生。

請勿將正式 token 寫入 Swift 原始碼、`project.pbxproj`、
`Secrets.example.xcconfig` 或任何會提交到版本庫的檔案。

若未設定 token，App 仍會以已查核的官方展示資料啟動，並在首頁清楚標示「展示資料模式」；設定後重新執行即可載入 TMDb 即時內容。

## 資料來源

- TMDb movie ID：`969681`
- Sony Pictures 官方電影頁
- TMDb API：`/movie/969681?append_to_response=credits,images,videos,similar`

This product uses the TMDB API but is not endorsed or certified by TMDB.
