import AVFoundation
import AppKit

var exit = false

let audioQueue = DispatchQueue(label: "audio test queue")

var captureSession: AVCaptureSession?
var audioInput: AVCaptureDeviceInput?

var fileOutput: AVCaptureAudioFileOutput?
let outputFileURL = URL(filePath: "/tmp/audio-engine-test.m4a")

final class CaptureDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    static let shared = CaptureDelegate()

    private override init() { }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Did finish recording to", outputFileURL)
        if let error {
            print("Error:", error.localizedDescription)
        }
    }
}

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
        print("Cannot capture input from", device.localizedName, "because", error.localizedDescription)
    }
}

func getInput() {
    print("> ", terminator: "")
    
    let input = readLine(strippingNewline: true)

    switch input {
    case "h", "?":
        printBanner()

    case "q":
        exit = true

    case "ls":
        let devices = captureDevices()
        if devices.isEmpty {
            print("No microphones found!")
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

    case "df":
        guard fileOutput == nil
        else { return print("File output already set up") }

        fileOutput = AVCaptureAudioFileOutput()

    case "s":
        guard let audioInput 
        else { return print("Set input device first") }
        guard let fileOutput
        else { return print("Set file output first") }

        let newCaptureSession = AVCaptureSession()
        defer { captureSession = newCaptureSession }

        newCaptureSession.beginConfiguration()
        defer { newCaptureSession.commitConfiguration() }

        newCaptureSession.sessionPreset = .medium

        guard newCaptureSession.canAddInput(audioInput)
        else { return print("Cannot add audio input to new capture session") }
        newCaptureSession.addInput(audioInput)

        guard newCaptureSession.canAddOutput(fileOutput)
        else { return print("Cannot add file output to session") }
        newCaptureSession.addOutput(fileOutput)

        audioQueue.async {
            newCaptureSession.startRunning()
            fileOutput.startRecording(to: outputFileURL, outputFileType: .m4a, recordingDelegate: CaptureDelegate.shared)
        }

    case "S":
        guard let captureSession
        else { return print("Start capture session first") }

        audioQueue.async {
            fileOutput?.stopRecording()
            captureSession.stopRunning()
        }

    case "rm":
        guard FileManager.default.fileExists(atPath: outputFileURL.path(percentEncoded: false))
        else { return print("File does not exist") }
        do {
            try FileManager.default.removeItem(at: outputFileURL)
            print("File removed at", outputFileURL)
        } catch {
            print("Could not remove file at", outputFileURL, "because:", error.localizedDescription)
        }

    case "o":
        guard FileManager.default.fileExists(atPath: outputFileURL.path(percentEncoded: false))
        else { return print("File does not exist") }
        NSWorkspace.shared.open(outputFileURL)

    default:
        NSSound.beep()
    }
}

func printBanner() {
    let outputPath = outputFileURL.path(percentEncoded: false)
    let separator = "-----------------------------------"
    [
        "Usage:",
        "\tq\t\tquit",
        "\th\t\tprint this help",
        separator,
        "\tls\t\tlist devices",
        "\ti[0--9]\tset input device",
        "\tdi\t\tset default input device",
        "\tdf\t\tset default file output (\(outputPath))",
        separator,
        "\ts\t\tstart capture session",
        "\tS\t\tstop capture session",
        "\trm\t\tremove file output (\(outputPath))",
        "\to\t\topen file output (\(outputPath))"
    ].forEach { print($0) }
}

printBanner()

repeat {
    getInput()
} while (!exit)
