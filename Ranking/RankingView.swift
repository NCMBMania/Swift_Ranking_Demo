//
//  RankingView.swift
//  Ranking
//
//  Created by Atsushi on 2021/08/07.
//

import SwiftUI
import NCMB

struct RankingView: View {
    @State private var rankings: [NCMBObject] = []
    var body: some View {
        VStack {
            Text("ランキング")
                .font(.title)
            if rankings.count > 0 {
                List {
                    ForEach(rankings.indices) { i in
                        Text(listString(index: i))
                    }
                }
            }
        }.onAppear {
            getRanking()
        }
    }
    
    // ランキングの順位、ゲームユーザ名、スコアを返します
    func listString(index: Int) -> String {
        let ranking = rankings[index]
        let displayName: String = ranking["displayName"] ?? ""
        let score: Int = ranking["score"] ?? 0
        return "\(index + 1)位 \(displayName)さん (\(score)点)"
    }
    
    // ランキングデータを取得します
    func getRanking() {
        // ランキングデータ検索用のクエリオブジェクトを作成
        var query = NCMBQuery.getQuery(className: "Ranking")
        // 並び順はスコアの高い順です
        query.order = ["-score"]
        // 100件のデータを取得します
        query.limit = 100
        // 検索実行
        let results = query.find()
        switch results {
        case let .success(ary):
            // 検索成功したら、それをrankingsに適用します
            rankings = ary
        case .failure(_): break
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
