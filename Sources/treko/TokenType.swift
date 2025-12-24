enum TokenType {
    case leftParen, rightParen, leftBrace, rightBrace
    case comma, dot, semicolon, colon
    case minus, plus, slash, star
    case equal, equalEqual, bang, bangEqual, greater, greaterEqual, less, lessEqual
    case identifier, string, number, bool, `true`, `false`, `nil`
    case and, or, `if`, elsif, `else`, unless
    case `class`, this, `super`
    case `var`, `let`
    case fun, `print`, `return`
    case `repeat`, `while`, `for`, until
    case eof
}
