#if canImport(Foundation)
    import Foundation
#else
    #error("unsupported platform")
#endif

@main
@MainActor
enum Treko {
    private(set) static var hadError = false

    public static func main() throws {
        switch CommandLine.arguments.count {
        case 1:
            try runPrompt()
        case 2:
            try runFile(path: CommandLine.arguments[1])
        default:
            print("Usage: treko [script]")
            exit(64)
        }
    }

    private static func runFile(path: String) throws {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        run(source: content)

        if hadError {
            exit(65)
        }
    }

    private static func runPrompt() throws {
        guard let data = "> ".data(using: .utf8) else {
            return
        }

        while true {
            try FileHandle.standardOutput.write(contentsOf: data)

            guard let line: String = readLine() else {
                print("")
                break
            }

            run(source: line)
            hadError = false
        }
    }

    private static func run(source: String) {
        var lexer = Lexer(source: source)
        let tokens: [Token] = lexer.scanTokens()

        for token in tokens {
            print(token)
        }

        if hadError {
            exit(66)
        }
    }

    static func error(line: Int, message: String) {
        report(line: line, location: "", message: message)
    }

    private static func report(line: Int, location: String, message: String) {
        let reportString = "[line \(line)] Error \(location): \(message)\n"
        if let data = reportString.data(using: .utf8) {
            try? FileHandle.standardError.write(contentsOf: data)
        }

        hadError = true
    }
}
