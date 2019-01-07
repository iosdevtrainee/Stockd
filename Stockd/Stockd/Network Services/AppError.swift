import Foundation

enum AppError: Error, ErrorProtocol {
  case badURL(String)
  case networkError(Error)
  case noResponse
  case decodingError(Error)
  case encodingError(Error)
  case userAPIError(String)
  case invalidLogin(String)
  
  public var errorMessage: String {
    switch self {
    case .badURL(let str):
      return "badURL: \(str)"
    case .networkError(let error):
      return "networkError: \(error)"
    case .noResponse:
      return "no network response"
    case .decodingError(let error):
      return "decoding error: \(error)"
    case .encodingError(let error):
      return "decoding error: \(error)"
    case .userAPIError(let error):
      return "User API error: \(error)"
    case .invalidLogin:
      return "Unable with current credentials"
    }
  }
}
