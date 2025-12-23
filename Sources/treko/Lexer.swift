@MainActor
class Lexer {
    private let source: String
    private let characters: [Character]
    private var tokens: [Token] = []
    private var start: Int = 0
    private var current: Int = 0
    private var line: Int = 1

    private var isAtEnd: Bool {
        !characters.indices.contains(current)
    }
    
    private var currentLexeme: String {
        String(characters[start..<current])
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
        self.characters = Array(source)
    }

    func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            scanToken()            
        }

        tokens.append(Token(type: .eof, lexeme: "", literal: nil, line: line))
        return tokens
    }

    private func scanToken() -> Void {
        let c: Character = advance()
        
        switch c {
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
        case "=": addToken(match("=") ? .equalEqual : .equal)
        case "!": addToken(match("=") ? .bangEqual : .bang)
        case ">": addToken(match("=") ? .greaterEqual : .greater)
        case "<": addToken(match("=") ? .lessEqual : .less)
        case _ where c.isWhitespace:
            if c.isNewline {
                line += 1
            }
        case _ where c.isLetter || c == "_": identifier()
        case _ where c.isWholeNumber: number()
        case "\"": string()
        default: Treko.error(line: line, message: "Unexpected character.")
        }
    }

    private func addToken(_ type: TokenType, literal: Any? = nil) -> Void {
        tokens.append(Token(type: type, lexeme: currentLexeme, literal: literal, line: line))
    }

    private func advance() -> Character {
        let char: Character = characters[current]
        current += 1
        return char
    }

    private func match(_ expected: Character) -> Bool {
        guard !isAtEnd, characters[current] == expected else {
            return false
        }

        current += 1
        return true
    }

    private func peek(by offset: Int = 0) -> Character {
        let index: Int = current + offset
        guard characters.indices.contains(index) else {
            return "\0"
        }

        return characters[index]
    }

    private func string() -> Void {
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

        let value: String = String(characters[(start + 1)..<(current - 1)])
        addToken(.string, literal: value)
    }

    private func number() -> Void {
        while peek().isWholeNumber {
            _ = advance()
        }

        if peek() == "." && peek(by: 1).isWholeNumber {
            repeat {
                _ = advance()
            } while peek().isWholeNumber
        }

        addToken(.number, literal: Double(currentLexeme))
    }

    private func identifier() -> Void {
        while peek().isLetter || peek().isWholeNumber || peek() == "_" {
            _ = advance()
        }
        
        let type: TokenType = Lexer.keywords[currentLexeme] ?? .identifier
        addToken(type)
    }
}