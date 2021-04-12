import ConsoleCore

let tool = ConsoleTool()

do {
    try tool.run()
} catch {
    print("An error occurred: \(error)")
}
