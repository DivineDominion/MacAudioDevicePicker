import AVFoundation
import AppKit

var exit = false

let audioQueue = DispatchQueue(label: "audio test queue")

var captureSession: AVCaptureSession?
var audioInput: AVCaptureDeviceInput?

func captureDevices() -> [AVCaptureDevice] {
    return AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInMicrophone],
        mediaType: .audio,
        position: .unspecified
    ).devices
}

func changeCaptureDevice(to device: AVCaptureDevice) {
    do {
        try audioInput = AVCaptureDeviceInput(device: device)
        print("→ Set input device to", device.localizedName)
    } catch {
        print("Cannot capture input from", device.localizedName, "because", error)
    }
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
        changeCaptureDevice(to: captureDevices()[inputDeviceNumber])

    case "di":
        guard let defaultDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)
        else { return print("No default input device") }
        changeCaptureDevice(to: defaultDevice)

    case "s":
        guard let audioInput 
        else { return print("Set input device first") }

        let newCaptureSession = AVCaptureSession()
        defer { captureSession = newCaptureSession }

        newCaptureSession.beginConfiguration()
        defer { newCaptureSession.commitConfiguration() }

        newCaptureSession.sessionPreset = .medium

        guard newCaptureSession.canAddInput(audioInput)
        else { return print("Cannot add audio input to new capture session") }
        newCaptureSession.addInput(audioInput)

        audioQueue.async {
            newCaptureSession.startRunning()
        }

    case "S":
        guard let captureSession
        else { return print("Start capture session first") }

        audioQueue.async {
            captureSession.stopRunning()
        }

    default:
        NSSound.beep()
    }
}

func printBanner() {
    let separator = "-----------------------------------"
    [
        "Usage:",
        "\tq\tquit",
        "\th\tprint this help",
        separator,
        "\tls\tlist devices",
        "\ti[0--9]\tset input device",
        "\tdi\tset default input device",
        separator,
        "\ts\tstart capture session",
        "\tS\tstop capture session",
    ].forEach { print($0) }
}

printBanner()

repeat {
    getInput()
} while (!exit)
