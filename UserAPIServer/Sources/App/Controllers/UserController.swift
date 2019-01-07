import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        // basic Authenication i.e. will require an Authorization header
       // with username:password encoded in base64 encoding
        let user = try req.requireAuthenticated(User.self)
        let console = Terminal()
        console.output("email: \(user.email), password:\(user.passwordHash)".consoleText(), newLine: true)
        // create new token for this user
        let token = try UserToken.create(userID: user.requireID())
        
        // save and return token
        // saves a UserToken response and sends it back to the client
        return token.save(on: req)
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<UserResponse> {
        // decode request content
        // accepts application/json or
      return try req.http.body.data.map { data -> Future<User> in
        // verify that passwords match
        guard let user = try? JSONDecoder().decode(CreateUserRequest.self, from: data) else {
          let responseStatus = HTTPResponseStatus.custom(code: 499, reasonPhrase: "")
          throw Abort(responseStatus)
        }
        let console = Terminal()
        console.output("email: \(user.email), password:\(user.password), verifyPassword:\(user.verifyPassword)".consoleText(), newLine: true)
            guard user.password == user.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            // save new user
            return User(id: nil, email: user.email, passwordHash: hash)
                .save(on: req)
        }.map { savedUser in
          return savedUser.map { UserResponse(id: $0.id!, email: $0.email)}
          
        }!
            // map to public user response (omits password hash)
          
//        }
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequest: Content, Codable {
  
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

/// Public representation of user data.
struct UserResponse: Content {
  
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
  
    /// User's email address.
    var email: String
}
