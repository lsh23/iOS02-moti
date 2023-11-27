//
//  MotiAPI.swift
//
//
//  Created by Kihyun Lee on 11/13/23.
//

import Foundation
import Domain

enum MotiAPI: EndpointProtocol {
    case version
    case login(requestValue: LoginRequestValue)
    case autoLogin(requestValue: AutoLoginRequestValue)
    case fetchAchievementList(requestValue: FetchAchievementListRequestValue?)
    case fetchCategoryList
    case addCategory(requestValue: AddCategoryRequestValue)
    case fetchDetailAchievement(requestValue: FetchDetailAchievementRequestValue)
    case saveImage(requestValue: SaveImageRequestValue)
}

extension MotiAPI {
    var version: String {
        return "v1"
    }
    
    var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as! String + "/api/\(version)"
    }
    
    var path: String {
        switch self {
        case .version: return "/operate/policy"
        case .login: return "/auth/login"
        case .autoLogin: return "/auth/refresh"
        case .fetchAchievementList: return "/achievements"
        case .fetchCategoryList: return "/categories"
        case .addCategory: return "/categories"
        case .fetchDetailAchievement(let requestValue): return "/achievements/\(requestValue.id)"
        case .saveImage: return "/images"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .version: return .get
        case .login: return .post
        case .autoLogin: return .post
        case .fetchAchievementList: return .get
        case .fetchCategoryList: return .get
        case .addCategory: return .post
        case .fetchDetailAchievement: return .get
        case .saveImage: return .post
        }
    }
    
    var queryParameters: Encodable? {
        switch self {
        case .fetchAchievementList(let requestValue):
            return requestValue
        default:
            return nil
        }
    }
    
    var bodyParameters: Encodable? {
        switch self {
        case .login(let requestValue):
            return requestValue
        case .autoLogin(let requestValue):
            return requestValue
        case .addCategory(let requestValue):
            return requestValue
        case .saveImage(let requestValue):
            return makeMultipartFormDataBody(
                boundary: requestValue.boundary,
                contentType: requestValue.contentType,
                data: requestValue.imageData
            )
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var header: [String: String] = [:]
        
        // Content-Type
        switch self {
        case .saveImage(let requestValue):
            header["Content-Type"] = "multipart/form-data; boundary=\(requestValue.boundary)"
        default:
            header["Content-Type"] = "application/json"
        }
        
        // Authorization
        switch self {
        case .version, .login:
            break
        default:
            // TODO: Keychain Storage로 변경
            if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                header["Authorization"] = "Bearer \(accessToken)"
            }
        }
        
        return header
    }
}
