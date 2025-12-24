indirect enum Expr {
    case binary(left: Expr, operatorToken: Token, right: Expr)
    case grouping(expression: Expr)
    case literal(value: Any?)
    case unary(operatorToken: Token, right: Expr)
}