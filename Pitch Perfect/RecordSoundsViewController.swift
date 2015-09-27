//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Rachel Schifano on 5/11/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {

    // FIXME: Adjust accessibility feature for recording
    // Declare global AVAudioRecorder variable
    var audioRecorder:AVAudioRecorder!
    // Create new object for the RecordedAudio class
    var recordedAudio: RecordedAudio!
    var paused: Bool = false
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    /**
        Records audio and hides the stop button and recording label.
    
        - parameter sender: The UIButton clicked on - microphone button
    */
    @IBAction func recordAudio(sender: UIButton) {
        recordButton.enabled = false
        stopButton.hidden = false
        pauseButton.hidden = false
        recordingLabel.hidden = false
        recordingLabel.text = "Recording in Progress..."
        recordingLabel.accessibilityHint = "Audio recording is currently in progress."
        
        // Check if a resume needs to occur due to previous pause
        if (paused) {
            audioRecorder.record()
        } else {
            // Prepare for recording audio
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            let recordingName = "my_audio.wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            print(filePath)
            
            // Create new recording session
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch _ {
            }
            
            // FIXME: Add error alert for user
            do
            {
                audioRecorder = try AVAudioRecorder(URL:filePath!, settings:[:])
            }
            catch let error as NSError
            {
                print(error.description)
            }
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
    }
    
    /**
        Pauses audio from recording.
    */
    @IBAction func pauseAudio(sender: UIButton) {
        audioRecorder.pause()
        recordingLabel.text = "Tap Record to Resume"
        recordingLabel.accessibilityHint = "Tap the record button to resume recording audio"
        recordButton.enabled = true
        paused = true
    }
    
    /**
        Stops recording audio.
    
        - parameter sender: The UIButton - stop image
    */
    @IBAction func stopRecordingAudio(sender: UIButton) {
        recordingLabel.hidden = true
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stopButton.hidden = true
        pauseButton.hidden = true
        recordButton.enabled = true
        recordingLabel.hidden = false
        recordingLabel.isAccessibilityElement = true
        
        // Bold and Darken text for accessibility
        if (UIAccessibilityIsBoldTextEnabled()) {
            recordingLabel.font = UIFont(name: "Heiti SC Medium", size: 15)
        }
        if (UIAccessibilityDarkerSystemColorsEnabled()) {
            recordingLabel.textColor = UIColor.blackColor()
        }
        recordingLabel.text = "Tap to Record"
        recordingLabel.accessibilityHint = "Tap the record button to begin recording audio"
    }
    
    /**
        Function that segues the RecordSoundsVC to the PlaySoundsVC.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Important if multiple segues for a view controller
        if (segue.identifier == "stopRecording") {
            // Make destinationVC the correct type
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            playSoundsVC.receivedAudio = recordedAudio
        }
    }
}

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    /**
        Checks if a recording has completed successfully or not.
        This function is an AVAudioRecorder delegate.
        
        - parameter recorder: The audio recorder that has finished recording.
        - parameter flag: A boolean value for success or failure
    */
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            // Initialize the recordedAudio object
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            // Inherit from UIViewController, recordedAudio is obj that initiates segue
            // FIXME: Why does this not work when it changes to a struct?
            self.performSegueWithIdentifier("stopRecording", sender: nil)
        } else {
            // FIXME: Add alert to the iOS user.
            print("Recording not successful.")
            recordButton.enabled = true // Record again
            stopButton.hidden = true
        }
    }
}