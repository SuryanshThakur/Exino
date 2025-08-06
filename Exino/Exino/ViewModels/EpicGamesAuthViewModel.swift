import Foundation
import Combine
import AuthenticationServices

class EpicGamesAuthViewModel: NSObject, ObservableObject {
        @Published private(set) var accessToken: String? 
    @Published private(set) var refreshToken: String?
        @Published private(set) var accountId: String?
    @Published private(set) var games: [EpicGame] = []

    var isAuthenticated: Bool {
        accessToken != nil
    }
    private var webAuthSession: ASWebAuthenticationSession?

    private let authURL = "https://www.epicgames.com/id/authorize"
    private let tokenURL = "https://api.epicgames.dev/epic/oauth/v1/token"
    private let redirectURI = "exino://auth"
    private let scope = "basic_profile"

    private var cancellables = Set<AnyCancellable>()

    // This will be the function that starts the authentication process
    func connect() {
        guard var components = URLComponents(string: authURL) else {
            print("Invalid auth URL")
            return
        }

        components.queryItems = [
            URLQueryItem(name: "client_id", value: Credentials.epicGamesClientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope)
        ]

        guard let url = components.url else {
            print("Could not create auth URL")
            return
        }

        webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "exino") { callbackURL, error in
            if let error = error {
                print("Authentication session failed with error: \(error.localizedDescription)")
                return
            }
            guard let callbackURL = callbackURL else {
                print("Invalid callback URL")
                return
            }
            self.handleOAuthCallback(url: callbackURL)
        }
        
        // This is required on macOS to present the auth session
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.start()
    }

    // This function will handle the callback from the browser
    func handleOAuthCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("Could not extract authorization code from callback URL")
            return
        }

        exchangeCodeForToken(code: code)
    }

    private func exchangeCodeForToken(code: String) {
        guard let url = URL(string: tokenURL) else {
            print("Invalid token URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let clientCredentials = "\(Credentials.epicGamesClientId):\(Credentials.epicGamesClientSecret)"
        guard let base64Credentials = clientCredentials.data(using: .utf8)?.base64EncodedString() else {
            print("Could not encode credentials")
            return
        }
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]

        request.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Token exchange failed with error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from token exchange")
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                print("Access Token: \(tokenResponse.accessToken)")
                DispatchQueue.main.async {
                    self.accessToken = tokenResponse.accessToken
                    self.refreshToken = tokenResponse.refreshToken
                    self.accountId = tokenResponse.accountId
                    self.fetchGames()
                    // In a real app, you would securely store these tokens in the Keychain.
                }
            } catch {
                print("Failed to decode token response: \(error.localizedDescription)")
            }
        }.resume()
    }

    func fetchGames() {
        guard let accessToken = accessToken, let accountId = accountId else {
            print("Not authenticated, cannot fetch games.")
            return
        }

        let gamesURL = "https://api.epicgames.dev/epic/ecom/v3/identities/\(accountId)/entitlements"

        guard let url = URL(string: gamesURL) else {
            print("Invalid games URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch games: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for games")
                return
            }

            do {
                let entitlements = try JSONDecoder().decode([EpicEntitlement].self, from: data)
                DispatchQueue.main.async {
                    self.games = entitlements.map { EpicGame(id: $0.catalogItemId, name: $0.entitlementName, namespace: $0.namespace) }
                    print("Fetched \(self.games.count) games.")
                }
            } catch {
                print("Failed to decode games response: \(error.localizedDescription)")
            }
        }.resume()
    }

    func logout() {
        accessToken = nil
        refreshToken = nil
        accountId = nil
        games = []
    }

    func fetchGameDetails(for game: EpicGame) {
        guard let accessToken = accessToken else {
            print("Not authenticated, cannot fetch game details.")
            return
        }

        let detailsURL = "https://api.epicgames.dev/epic/ecom/v3/public/catalog/items/\(game.id)"

        guard let url = URL(string: detailsURL) else {
            print("Invalid game details URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch game details: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for game details")
                return
            }

            do {
                let catalogItem = try JSONDecoder().decode(CatalogItem.self, from: data)
                DispatchQueue.main.async {
                    if let index = self.games.firstIndex(where: { $0.id == game.id }) {
                        self.games[index].description = catalogItem.longDescription ?? catalogItem.description
                        self.games[index].keyImages = catalogItem.keyImages
                        print("Updated details for \(catalogItem.title)")
                    }
                }
            } catch {
                print("Failed to decode game details response: \(error.localizedDescription)")
            }
        }.resume()
    }
}

private struct TokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String
    let accountId: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case accountId = "account_id"
    }
}

extension EpicGamesAuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

}
