import AVFoundation
import AppKit

var exit = false

var inputDevice: AVCaptureDeviceInput?

func captureDevices() -> [AVCaptureDevice] {
    return AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInMicrophone],
        mediaType: .audio,
        position: .unspecified
    ).devices
}

func getInput() {
    print("> ", terminator: "")
    
    let input = readLine(strippingNewline: true)

    switch input {
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
                print(offset, terminator: "\t")
                print(device.localizedName, !device.isConnected ? "(DISCONNECTED)" : "")
            }
        }

    case .some(let cmd) where cmd.hasPrefix("i"):
        guard let inputDeviceNumber = Int(cmd.dropFirst(1))
        else { return print("No valid device number: \(cmd)") }
        let device = captureDevices()[inputDeviceNumber]
        do {
            try inputDevice = AVCaptureDeviceInput(device: device)
            print("→ Set input device to", device.localizedName)
        } catch {
            print("Cannot capture input from", device.localizedName, "because", error)
        }

    case "di":
        guard let defaultDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified) 
        else { return print("No default input device") }
        do {
            try inputDevice = AVCaptureDeviceInput(device: defaultDevice)
            print("→ Set input device to", defaultDevice.localizedName)
        } catch {
            print("Cannot capture input from", defaultDevice.localizedName, "because", error)
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
        "\ti[0--9]\tset input device",
        "\tdi\tset default input device",
    ].forEach { print($0) }
}

printBanner()

repeat {
    getInput()
} while (!exit)
