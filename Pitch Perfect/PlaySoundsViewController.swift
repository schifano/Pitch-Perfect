//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Rachel Schifano on 6/22/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioFile: AVAudioFile!
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        // Initialize, used to convert NSURL to AVAudioFile
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /**
        Plays back audio at a slower rate.
    
        - parameter sender: The UIButton clicked on - snail image
    */
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableRate(0.5)
    }
    
    /**
        Plays back audio at a faster rate.
    
        - parameter sender: The UIButton clicked on - rabbit image
    */
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithVariableRate(2.0)
    }
    
    /**
        Helper function for playing back audio at variable rates.
    
        - parameter rate: The playback rate value
    */
    func playAudioWithVariableRate(rate: Float) {
        stopAudio()
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0 // play from beginning
        audioPlayer.play()
    }
    
    /**
        Plays back audio at a higher pitch.
    
        - parameter sender: The UIButton clicked on - chipmunk image
    */
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    /**
        Plays back audio at a lower pitch.
    
        - parameter sender: The UIButton clicked on - Darth Vader image
    */
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    /**
        Helper function for playing back audio at variable pitches.
    
        - parameter pitch: The playback pitch value
    */
    func playAudioWithVariablePitch(pitch: Float) {
        let pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        playAudioWithEffect(pitchEffect)
    }
    
    /**
        Plays back audio with echo (delayed) effect.
    
        - parameter sender: The UIButton clicked on - the right circles button.
    */
    @IBAction func playAudioWithEcho(sender: UIButton) {
        let delayEffect = AVAudioUnitDelay()
        delayEffect.wetDryMix = 50
        delayEffect.delayTime = 0.5
        playAudioWithEffect(delayEffect)
    }
    
    /**
        Plays back audio with reverb effect.
    
        - parameter sender: The UIButton clicked on - the left circles button.
    */
    @IBAction func playAudioWithReverb(sender: UIButton) {
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.LargeHall2)
        reverbEffect.wetDryMix = 50
        playAudioWithEffect(reverbEffect)
    }
    
    /**
        Plays audio  back with various effect params.
    
        :parm: effect The effect subclassed within AVAudioUnit
    */
    func playAudioWithEffect(effect: AVAudioUnit) {
        stopAudio()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(effect)

        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do
        {
            try audioEngine.start()
        }
        catch let error as NSError
        {
            print(error.description)
        }
        audioPlayerNode.play()
    }

    /**
        Stops audio from playing back.
    
        - parameter sender: The UIButton clicked on - stop button
    */
    @IBAction func stopAudio() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
}