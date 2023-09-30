import AVFAudio
import AppKit

var exit = false

func getInput() {
    print("> ", terminator: "")
    
    switch readLine(strippingNewline: true) {
    case "h":
        printBanner()

    case "q":
        exit = true

    default:
        NSSound.beep()
    }
}

func printBanner() {
    [
        "Usage:",
        "\tq\tquit",
        "\th\tprint this help",
    ].forEach { print($0) }
}

printBanner()

repeat {
    getInput()
} while (!exit)
