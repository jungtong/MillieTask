import Foundation
import Combine

class ViewModel {

    let newsValueSubject = CurrentValueSubject<[NewsVO], Never>([])

    // 진입했던 News들의 Hash 저장
    private var readNewsHashSet = Set<Int>()

    func fetchNewsData() {
        Task {
            do {
                // API응답 성공하면
                let response = try await Api.getTopHeadlines()

                // 성공한 데이터를 이용해서 데이터를 그려주고
                newsValueSubject.send(response.articles)

                Task {
                    // 기존의 로컬 데이터를 모두 삭제하고
                    CoreDataManager.shared.removeAllNews()

                    // 새로 받아온 데이터를 저장한다.
                    await CoreDataManager.shared.batchInsertNews(response.articles)
                }
            }
            catch { // 데이터 불러오기에 실패한 경우

                // CoreData에 저장되어 있던 데이터를 불러와서
                if let localDatas = CoreDataManager.shared.getNews() {
                    // 그려준다.
                    newsValueSubject.send(localDatas)
                }
            }
        }
    }

    // 선택했던 news 저장
    func newsRead(newsHash: Int) {
        readNewsHashSet.insert(newsHash)
    }
    // 선택했던 news 여부 확인
    func isNewsReaded(newsHash: Int) -> Bool {
        return readNewsHashSet.contains(newsHash)
    }
}
