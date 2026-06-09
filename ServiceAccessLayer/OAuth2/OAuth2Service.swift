import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()

    private var task: URLSessionTask?
    private var lastCode: String?

    private(set) var authToken: String? {
        get {
            tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }

    private init() { }

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let data):
                do {
                    let responseBody = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.authToken = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("[OAuth2Service fetchOAuthToken]: Ошибка декодирования - \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[OAuth2Service fetchOAuthToken]: Ошибка запроса - \(error.localizedDescription)")
                completion(.failure(error))
            }

            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}

private struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
