extension Expr: CustomStringConvertible {
    var description: String {
        switch self {
        case .binary(let left, let operatorToken, let right):
            return parenthesize(name: operatorToken.lexeme, exprs: left, right)
        case .grouping(let expression):
            return parenthesize(name: "group", exprs: expression)
        case .literal(let value):
            guard let value = value else {
                return "nil"
            }
            
            return "\(value)"
        case .unary(let operatorToken, let right):
            return parenthesize(name: operatorToken.lexeme, exprs: right)
        }
    }

    private func parenthesize(name: String, exprs: Expr...) -> String {
        let parts: [String] = exprs.map { $0.description }
        let joined = parts.joined(separator: " ")
        
        return "(\(name)\(joined.isEmpty ? "" : " ")\(joined))"
    }
}