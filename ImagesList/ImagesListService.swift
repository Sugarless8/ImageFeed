import Foundation

// MARK: - DTO (JSON decoding)

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

// MARK: - UI Model

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - Service

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var lastLoadedPage: Int?
    private var task: URLSessionTask?

    private let urlSession = URLSession.shared
    private let perPage = 10

    private lazy var isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard task == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makePhotosRequest(page: nextPage) else {
            print("[ImagesListService]: Не удалось создать запрос")
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let data):
                do {
                    let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                    let newPhotos = photoResults.map { self.convert($0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                } catch {
                    print("[ImagesListService fetchPhotosNextPage]: Ошибка декодирования - \(error.localizedDescription)")
                }
            case .failure(let error):
                print("[ImagesListService fetchPhotosNextPage]: Ошибка запроса - \(error.localizedDescription)")
            }

            self.task = nil
        }

        self.task = task
        task.resume()
    }

    private func convert(_ result: PhotoResult) -> Photo {
        let date: Date? = result.createdAt.flatMap { isoDateFormatter.date(from: $0) }
        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: date,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }

    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService]: Токен авторизации отсутствует")
            return nil
        }

        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
