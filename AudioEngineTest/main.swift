import AVFAudio
import AppKit

var exit = false

func getInput() {
    print("> ", terminator: "")
    
    switch readLine(strippingNewline: true) {
    case "q": 
         exit = true
    default:
        NSSound.beep()
    }
}

repeat {
    getInput()
} while (!exit)
