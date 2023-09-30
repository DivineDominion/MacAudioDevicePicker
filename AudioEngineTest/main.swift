import AVFAudio
import AppKit

var exit = false

let engine = AVAudioEngine()

func getInput() {
    print("> ", terminator: "")
    
    switch readLine(strippingNewline: true) {
    case "h":
        printBanner()

    case "q":
        exit = true

    case "i":
        [
            engine.inputNode.description,
            engine.outputNode.description,
        ].forEach { print($0) }

    case "s":
        do {
            try engine.start()
        } catch {
            print("Failed to start engine:\n", error)
        }

    case "S":
        engine.stop()

    default:
        NSSound.beep()
    }
}

func printBanner() {
    [
        "Usage:",
        "\tq\tquit",
        "\th\tprint this help",
        "-----------------------------------",
        "\ti\tinfo about current setup",
        "\ts\tstart audio engine",
        "\tS\tstop audio engine",
    ].forEach { print($0) }
}

printBanner()

repeat {
    getInput()
} while (!exit)
