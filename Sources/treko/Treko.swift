import Foundation

@main
@MainActor
enum Treko {
    private(set) static var hadError: Bool = false

    public static func main() -> Void {
        switch CommandLine.arguments.count {
        case 1:
            runPrompt()
        case 2:
            runFile(path: CommandLine.arguments[1])
        default:
            print("Usage: streko [script]")
            exit(64)
        }
    }

    private static func runFile(path: String) -> Void {
        guard let content: String = try? String(contentsOfFile: path, encoding: .utf8) else {
            let errorMsg: String = "Could not read file at \(path)\n"
            if let data: Data = errorMsg.data(using: .utf8) {
                try? FileHandle.standardError.write(contentsOf: data)
            }
    
            exit(66)    
        }

        run(source: content)

        if hadError {
            exit(65)
        }
    }

    private static func runPrompt() -> Void {
        while true {
            if let data: Data = "> ".data(using: .utf8) {
                try? FileHandle.standardOutput.write(contentsOf: data)
            }

            guard let line: String = readLine() else {
                print("")
                break
            }

            run(source: line)
            hadError = false
        }
    }

    private static func run(source: String) {
        let scanner: Scanner = Scanner(source: source)
        let tokens: [Token] = scanner.scanTokens()

        for token in tokens {
            print(token)
        }

        if hadError {
            exit(66)
        }
    }

    private static func error(line: Int, message: String) -> Void {
        report(line: line, location: "", message: message)
    }

    private static func report(line: Int, location: String, message: String) {
        let reportString: String = "[line \(line)] Error \(location): \(message)\n"
        if let data: Data = reportString.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
        
        hadError = true
    }
}