import AVFoundation
import AppKit

var exit = false

func captureDevices() -> [AVCaptureDevice] {
    return AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInMicrophone],
        mediaType: .audio,
        position: .unspecified
    ).devices
}

func getInput() {
    print("> ", terminator: "")
    
    switch readLine(strippingNewline: true) {
    case "h":
        printBanner()

    case "q":
        exit = true

    case "ls":
        let devices = captureDevices()
        if devices.isEmpty {
            print("No microphone devices found!")
        } else {
            devices.enumerated().forEach { (offset, device) in
                print(device.localizedName, !device.isConnected ? "(DISCONNECTED)" : "")
            }
        }


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
        "\tls\tlist devices",
    ].forEach { print($0) }
}

printBanner()

repeat {
    getInput()
} while (!exit)
