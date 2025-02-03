enum AuthProvider: String {
  case google = "google.com"
  case apple = "apple.com"
  case twitter = "twitter.com"
  case microsoft = "microsoft.com"
  case gitHub = "github.com"
  case yahoo = "yahoo.com"
  case facebook = "facebook.com"
  case emailPassword = "password"
  case passwordless = "emailLink"
  case phoneNumber = "phone"
  case anonymous
  case custom

  /// More intuitively named getter for `rawValue`.
  var id: String { rawValue }

  /// The UI friendly name of the `AuthProvider`. Used for display.
  var name: String {
    switch self {
    case .google:
      return "Google"
    case .apple:
      return "Apple"
    case .twitter:
      return "Twitter"
    case .microsoft:
      return "Microsoft"
    case .gitHub:
      return "GitHub"
    case .yahoo:
      return "Yahoo"
    case .facebook:
      return "Facebook"
    case .emailPassword:
      return "Email & Password Login"
    case .passwordless:
      return "Email Link/Passwordless"
    case .phoneNumber:
      return "Phone Number"
    case .anonymous:
      return "Anonymous Authentication"
    case .custom:
      return "Custom Auth System"
    }
  }

  /// Failable initializer to create an `AuthProvider` from it's corresponding `name` value.
  /// - Parameter rawValue: String value representing `AuthProvider`'s name or type.
  init?(rawValue: String) {
    switch rawValue {
    case "Google":
      self = .google
    case "Apple":
      self = .apple
    case "Twitter":
      self = .twitter
    case "Microsoft":
      self = .microsoft
    case "GitHub":
      self = .gitHub
    case "Yahoo":
      self = .yahoo
    case "Facebook":
      self = .facebook
    case "Email & Password Login":
      self = .emailPassword
    case "Email Link/Passwordless":
      self = .passwordless
    case "Phone Number":
      self = .phoneNumber
    case "Anonymous Authentication":
      self = .anonymous
    case "Custom Auth System":
      self = .custom
    default: return nil
    }
  }
}
