//
//  RankingApp.swift
//  Ranking
//
//  Created by Atsushi on 2021/08/07.
//

import SwiftUI
import NCMB

@main
struct RankingApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.onChange(of: scenePhase) { scene in
            switch scene {
            case .active:
                // キーの設定
                let applicationKey = "YOUR_APPLICATION_KEY"
                let clientKey = "YOUR_CLIENT_KEY"
                // 初期化
                NCMB.initialize(applicationKey: applicationKey, clientKey: clientKey)
                NCMBUser.enableAutomaticUser()
                checkAuth()
                if checkSession() == false {
                    checkAuth()
                }
            case .background: break
            case .inactive: break
            default: break
            }
        }
    }
    
    func checkAuth() -> Void {
        // 認証データがあれば処理は終了
        if NCMBUser.currentUser != nil {
            return;
        }
        // 匿名認証実行
        _ = NCMBUser.automaticCurrentUser()
    }

    func checkSession() -> Bool {
        var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "Todo")
        query.limit = 1 // レスポンス件数を最小限にする
        // アクセス
        let results = query.find()
        // 結果の判定
        switch results {
        case .success(_): break
        case .failure(_):
            // 強制ログアウト処理
            _ = NCMBUser.logOut()
            return false
        }
        return true
    }
}
