//
//  RankingView.swift
//  Ranking
//
//  Created by Atsushi on 2021/08/07.
//

import SwiftUI
import NCMB

enum RankingRange {
    case All, Month, Week
}

struct RankingView: View {
    @State private var rankings: [NCMBObject] = []
    var body: some View {
        VStack {
            Text("ランキング")
                .font(.title)
            HStack {
                Button("全期間", action: {
                    getRanking()
                })
                Button("過去30日", action: {
                    getRanking(range: RankingRange.Month)
                })
                Button("過去7日", action: {
                    getRanking(range: RankingRange.Week)
                })
            }
            if rankings.count > 0 {
                List {
                    ForEach(Array(rankings.enumerated()), id: \.offset) { i, ranking in
                        Text(listString(index: i, ranking: ranking))
                    }
                }
            }
        }.onAppear {
            getRanking()
        }
    }
    
    // ランキングの順位、ゲームユーザ名、スコアを返します
    func listString(index: Int, ranking: NCMBObject) -> String {
        let displayName: String = ranking["displayName"] ?? ""
        let score: Int = ranking["score"] ?? 0
        return "\(index + 1)位 \(displayName)さん (\(score)点)"
    }
    
    // ランキングデータを取得します
    func getRanking(range: RankingRange = .All) {
        var date: Date?
        let calendar = Calendar.current
        let today = Date()
        
        switch range {
        case .Month:
            date = calendar.date(byAdding: .day, value: -30, to: today)
            break
        case .Week:
            date = calendar.date(byAdding: .day, value: -7, to: today)
            break
        default:
            break
        }
        // ランキングデータ検索用のクエリオブジェクトを作成
        var query = NCMBQuery.getQuery(className: "Ranking")
        // 並び順はスコアの高い順です
        query.order = ["-score"]
        // 100件のデータを取得します
        query.limit = 100
        if date != nil {
            query.where(field: "createDate", greaterThanOrEqualTo: date!)
        }
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
