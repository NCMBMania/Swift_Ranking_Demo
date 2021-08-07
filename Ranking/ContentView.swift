//
//  ContentView.swift
//  Ranking
//
//  Created by Atsushi on 2021/08/07.
//

import SwiftUI
import NCMB

struct ContentView: View {
    // 10秒間のカウントタイマー
    @State private var timer: Timer? = nil
    // タップした回数
    @State private var count = 0
    // ゲームが開始したら true。時間切れになったら false
    @State private var enabled = true
    // 開始したかどうかのフラグ
    @State private var start = false
    // ゲーム秒数
    @State private var limit = 10
    
    // ランキングを表示するかどうかのフラグ
    @State private var showRanking = false
    // ゲームユーザ名
    @State private var userName = ""
    // メッセージ表示用のフラグ
    @State private var showAlert = false
    // メッセージ内容
    @State private var message = ""
    
    var body: some View {
        VStack {
            Text("連打アプリ")
                .padding(10)
                .font(.title)
            Text("\(count)回")
                .padding(10)
            Text(limitText())
                .padding(10)
            HStack {
                Button("連打！", action: add)
                    .disabled(!enabled)
                Button("リセット", action: reset)
                    .disabled(enabled)
            }
            if count > 0 && limit == 0{
                VStack {
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: nil, content: {
                        TextField("名前", text: $userName)
                            .padding(20)
                    })
                    HStack {
                        Button("記録する", action: record)
                        Button("ランキングを見る", action: {
                            showRanking = true
                        })
                    }
                }
            }
        }.sheet(isPresented: $showRanking, content: {
            RankingView()
        })
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text(message))
        })
    }
    
    // リセットボタンをタップした際の処理
    func reset() {
        count = 0
        enabled = true
        start = false
        limit = 10
    }
    
    // 連打ボタンをタップした際の処理
    func add() {
        // 終わっていればすぐ終了
        if !enabled {
            return
        }
        // 開始していなければタイマー開始
        if !start {
            startTimer()
        }
        // タップ回数のカウントアップ
        count = count + 1
    }
    
    // ゲーム開始時に一度だけ実行する
    func startTimer() {
        // フラグを立てる
        start = true
        // ゲームユーザ名を取得しておく
        let user = NCMBUser.currentUser
        if let name:String = user!["displayName"] {
            userName = name
        }
        // 10秒間のカウントダウンタイマー用
        let cal = Calendar(identifier: .japanese)
        let endDate = Calendar.current.date(byAdding:.second,value:limit,to:Date())
        timer = Timer.scheduledTimer(withTimeInterval:0.01, repeats: true){ _ in
            let timeVal = cal.dateComponents([.day,.hour,.minute,.second], from: Date(),to: endDate!)
            limit = timeVal.second!
            // 0になったら終了のフラグを立てて、タイマーを止める
            if limit == 0 {
                enabled = false
                timer?.invalidate()
            }
        }
    }
    
    // 残り何秒表示用の文字列を返す
    func limitText() -> String {
        if limit == 0 {
            return "終了！"
        } else {
            return "残り\(limit)秒"
        }
    }
    
    // ゲームスコアの記録用
    func record() {
        if userName == "" {
            message = "ユーザ名を入力してください"
            showAlert = true
            return
        }
        // ランキングデータの作成
        let ranking = NCMBObject(className: "Ranking")
        // ゲームユーザ名とスコアを設定
        ranking["displayName"] = userName
        ranking["score"] = count
        
        // ACL（アクセス権限）を作成・設定
        var acl = NCMBACL.empty
        let user = NCMBUser.currentUser
        // ゲームした本人のみ読み書き可能
        acl.put(key: user!.objectId!, readable: true, writable: true)
        // 他の人は閲覧のみ可
        acl.put(key: "*", readable: true, writable: false)
        ranking.acl = acl
        // 保存
        let results = ranking.save()
        switch results {
        case .success(_): // 保存が成功した場合
            let num = getMyRanking() // ランキングを取得
            message = "あなたのランキングは\(num)位です！" // アラート用メッセージ
        default: // 保存失敗した場合
            message = "ランキングを保存できませんでした" // アラート用メッセージ
        }
        showAlert = true // アラートを表示するフラグを立てる
        // 名前を保存しておく
        user!["displayName"] = userName
        _ = user!.save()
    }
    
    // 何位か表示するためにカウントを取る
    func getMyRanking() -> Int {
        // ランキングデータ検索用のクエリオブジェクトを作成
        var query = NCMBQuery.getQuery(className: "Ranking")
        // 検索条件を指定
        query.where(field: "score", greaterThan: count)
        // 検索実行（countで件数が取得できます）
        let results = query.count()
        switch results {
        case let .success(num): // 検索できれば引数に件数が返ってきます
            return num + 1 // 件数 + 1が順位
        case .failure(_):
            return 0
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

