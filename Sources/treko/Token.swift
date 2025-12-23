enum LiteralValue {
    case number(Double)
    case string(String)
    case bool(Bool)
    case none
}
struct Token {
    let type: TokenType
    let lexeme: String
    let literal: LiteralValue
    let line: Int
}

extension Token: CustomStringConvertible {
    var description: String {
        "\(type) \(lexeme) \(String(describing: literal))"
    }
}