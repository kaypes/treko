@MainActor
class Lexer {
    private let source: String
    private let scalars: [UnicodeScalar]
    private var tokens: [Token] = []
    private var start = 0
    private var current = 0
    private var line = 1

    private var isAtEnd: Bool {
        current >= scalars.count
    }

    private var currentLexeme: String {
        String(String.UnicodeScalarView(scalars[start..<current]))
    }

    static let keywords: [String: TokenType] = [
        "and": .and,
        "or": .or,
        "if": .if,
        "elsif": .elsif,
        "else": .else,
        "unless": .unless,
        "class": .class,
        "this": .this,
        "super": .super,
        "var": .var,
        "let": .let,
        "fun": .fun,
        "print": .print,
        "return": .return,
        "loop": .loop,
        "while": .while,
        "for": .for,
        "until": .until,
        "true": .true,
        "false": .false,
        "nil": .nil
    ]

    init(source: String) {
        self.source = source
        self.scalars = Array(source.unicodeScalars)
    }

    func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            scanToken()
        }

        tokens.append(Token(type: .eof, lexeme: "", literal: .none, line: line))
        return tokens
    }

    private func scanToken() {
        let scalar = advance()

        switch scalar {
        case "(": addToken(.leftParen)
        case ")": addToken(.rightParen)
        case "{": addToken(.leftBrace)
        case "}": addToken(.rightBrace)
        case ",": addToken(.comma)
        case ".": addToken(.dot)
        case "-": addToken(.minus)
        case "+": addToken(.plus)
        case "*": addToken(.star)
        case "/":
            if match("/") {
                while peek() != "\n" && !isAtEnd {
                    _ = advance()
                }
            } else {
                addToken(.slash)
            }
        case ";": addToken(.semicolon)
        case ":": addToken(.colon)
        case "=": addToken(match("=") ? .equalEqual : .equal)
        case "!": addToken(match("=") ? .bangEqual : .bang)
        case ">": addToken(match("=") ? .greaterEqual : .greater)
        case "<": addToken(match("=") ? .lessEqual : .less)
        case " ", "\r", "\t": break
        case "\n": line += 1
        case "\"": string()
        case "0"..."9": number()
        case "a"..."z", "A"..."Z", "_": identifier()
        default: Treko.error(line: line, message: "Unexpected character.")
        }
    }

    private func addToken(_ type: TokenType, literal: LiteralValue = .none) {
        tokens.append(Token(type: type, lexeme: currentLexeme, literal: literal, line: line))
    }

    private func advance() -> UnicodeScalar {
        let scalar = scalars[current]
        current += 1
        return scalar
    }

    private func match(_ expected: UnicodeScalar) -> Bool {
        guard !isAtEnd, scalars[current] == expected else {
            return false
        }

        current += 1
        return true
    }

    private func peek(by offset: Int = 0) -> UnicodeScalar {
        let index: Int = current + offset
        guard scalars.indices.contains(index) else {
            return "\0"
        }

        return scalars[index]
    }

    private func string() {
        while peek() != "\"" && !isAtEnd {
            if peek() == "\n" {
                line += 1
            }

            _ = advance()
        }

        guard !isAtEnd else {
            Treko.error(line: line, message: "Unterminated string.")
            return
        }

        _ = advance()

        let value = String(String.UnicodeScalarView(scalars[(start + 1)..<(current - 1)]))
        addToken(.string, literal: .string(value))
    }

    private func number() {
        while isDigit(peek()) {
            _ = advance()
        }

        if peek() == "." && isDigit(peek(by: 1)) {
            repeat {
                _ = advance()
            } while isDigit(peek())
        }

        addToken(.number, literal: .number(Double(currentLexeme)!))
    }

    private func identifier() {
        while isAlphaNumeric(peek()) {
            _ = advance()
        }

        let type: TokenType = Lexer.keywords[currentLexeme] ?? .identifier

        switch type {
        case .true: addToken(.true, literal: .bool(true))
        case .false: addToken(.false, literal: .bool(false))
        case .nil: addToken(.nil, literal: .none)
        default: addToken(type)
        }
    }

    private func isDigit(_ scalar: UnicodeScalar) -> Bool {
        return scalar >= "0" && scalar <= "9"
    }

    private func isAlphaNumeric(_ scalar: UnicodeScalar) -> Bool {
        return (scalar >= "a" && scalar <= "z") ||
               (scalar >= "A" && scalar <= "Z") ||
               (scalar >= "0" && scalar <= "9") ||
                scalar == "_"
    }
}
