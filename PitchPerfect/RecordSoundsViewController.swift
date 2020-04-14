//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Sarah Gunnels Porter on 4/11/20.
//  Copyright © 2020 Gunnels Porter. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Variables for delegation
    var audioRecorder: AVAudioRecorder!

    // MARK: Label and Button IBOutlets
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    
    // MARK: Override functions
    // Extend viewDidLoad to set-up initial state of buttons and label
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        stopRecordingButton.isEnabled = false
        recordingLabel.text = "Tap to Record"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    // MARK: Record Button Action
    @IBAction func recordAudio(_ sender: Any) {
        // Set state of the buttons, including change label text to provide feedback that recording is in progress
        recordingLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        recordingButton.isEnabled = false
        
        // Set-up recording file/storage for recording audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        print(filePath?.absoluteString ?? "")

        // Set settings of recording session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        // Record the audio
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    //MARK: Stop Recording Button Action
    @IBAction func stopRecording(_ sender: Any) {
        // Set state of buttons and update label to reflect ready to initiate new recording
        // Assumption that this processing will happen fast enough that new recording will not be requested
        // (i.e. button smashing on record button) before this recording is stoped (line 73)
        stopRecordingButton.isEnabled = false
        recordingButton.isEnabled = true
        recordingLabel.text = "Tap to Record"
        
        // Stop recording and stop session
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    //MARK: Delegate function performed when recording finished
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("ERROR: recording not successful")
        }
    }
    
    //MARK: Extension for when stop record segue requested
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            // Get the new view controller using segue.destination.
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            // Pass the selected object to the new view controller.
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

