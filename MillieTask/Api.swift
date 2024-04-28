import UIKit
import Alamofire

struct Api {
    private init() {}

    private static let apiHost = "https://newsapi.org"
    private static let apiKey = "aa9396c072a84bb9bfd638562ed7ecf2"

    private static let dev_apiAlwaysFail: Bool = false

    static func getTopHeadlines() async throws -> NewsResponseVO {
        if dev_apiAlwaysFail {
            throw "dev error"
        }

        let address = "\(apiHost)/v2/top-headlines"

        let parameters: Parameters = [
            "country": "kr",
            "apiKey": apiKey
        ]
        let request = AF.request(address,
                                 parameters: parameters)
        let responseResult = await request.validate().serializingDecodable(NewsResponseVO.self).response.result
        switch responseResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    // 서버에서 image를 받아온다. 직접 호출하지 말고, getUIImageWithCoreData를 사용할것
    private static func getUIImage(urlString: String?) async throws -> UIImage? {
        if dev_apiAlwaysFail {
            throw "dev error"
        }

        guard let urlString else {
            return nil
        }
        let responseResult = await AF.request(urlString).validate().serializingData().response.result
        switch responseResult {
        case .success(let result):
            return UIImage(data: result)
        case .failure(let error):
            throw error
        }
    }

    // CoreData에서 image를 찾아보고, 없으면 서버에서 받아서 처리한다.
    static func getUIImageWithCoreData(urlString: String?) async throws -> UIImage? {
        guard let urlString else {
            return nil
        }

        // CoreData에 urlString에 해당하는 이미지가 있으면 그것을 바로 return
        if let queryResult = CoreDataManager.shared.queryImage(imageUrl: urlString),
           let imageData = queryResult.data {
            return UIImage(data: imageData)
        }
        else {
            // 없으면 API에서 이미지를 받아오고
            if let recvImage = try await getUIImage(urlString: urlString) {
                Task {
                    // 받아온이미지를 CoreData에 저장
                    CoreDataManager.shared.insertImage(url: urlString, image: recvImage)
                }
                return recvImage
            }
        }

        return nil
    }
}
