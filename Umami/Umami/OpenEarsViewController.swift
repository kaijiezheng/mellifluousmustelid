//
//  OpenEarsViewController.swift
//  Umami
//
//  Created by Kaijie Zheng on 12/8/15.
//  Copyright © 2015 Honey Badger. All rights reserved.
//

import UIKit

var lmPath: String!
var dictPath: String!
var words: [String] = []
var currentWord: String!

var kLevelUpdatesPerSecond = 18

class OpenEarsViewController: UIViewController, OEEventsObserverDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var heardTextView: UITextView!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!

    // Continuously tracks mic activity, works with OEEventsObserverDelegate
    var openEarsEventsObserver = OEEventsObserver()
    var startupFailedDueToLackOfPermissions = Bool()
    var buttonFlashing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        loadOpenEars()
    }

    @IBAction func record(sender: UIButton) {
        if !buttonFlashing {
            startFlashingButton()
            startListening()
        } else {
            stopFlashingButton()
            stopListening()
        }
    }

    func startFlashingButton() {
        buttonFlashing = true
        recordButton.alpha = 1
        
        UIView.animateWithDuration(0.5 , delay: 0.0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.AllowUserInteraction], animations: {
            
            self.recordButton.alpha = 0.1
            
            }, completion: {Bool in
        })
    }

    func stopFlashingButton() {

        buttonFlashing = false

        UIView.animateWithDuration(0.1, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {

            self.recordButton.alpha = 1

            }, completion: {Bool in
        })
    }

    //OpenEars methods

    func loadOpenEars() {

        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self

        let lmGenerator = OELanguageModelGenerator()

        words.append("HELLO")
        words.append("START")
        words.append("STOP")
        words.append("REPEAT")
        words.append("NEXT")
        words.append("PREVIOUS")
        words.append("UMAMI")

        let name = "UmamiLanguageModel"
        lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        // Might want to do error checking here
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dictPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        heardTextView.text = "Heard: \(hypothesis)"
    }
    
    func startListening() {
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch {
            print("error")
        }
        
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dictPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }

    func pocketsphinxDidStartListening() {
        statusTextView.text = "Open Ears is now listening."
        print(statusTextView.text)
    }
    
    func pocketsphinxDidDetectSpeech() {
        statusTextView.text = "Open Ears has detected speech."
        print(statusTextView.text)
    }
    
    func pocketsphinxDidDetectFinishedSpeech() {
        statusTextView.text = "Open Ears has detected a period of silence, concluding an utterance."
        print(statusTextView.text)
    }
    
    func pocketsphinxDidStopListening() {
        statusTextView.text = "Open Ears has stopped listening."
        print(statusTextView.text)
    }
    
    func pocketsphinxDidSuspendRecognition() {
        statusTextView.text = "Open Ears has suspended recognition."
        print(statusTextView.text)
    }
    
    func pocketsphinxDidResumeRecognition() {
        statusTextView.text = "Open Ears has resumed recognition."
        print(statusTextView.text)
    }
    
    // Probably won't use this
    func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String, newDictionaryPathAsString: String) {
        print("Open Ears is now using the following language model: \(newLanguageModelPathAsString) and the following dictionary: \(newDictionaryPathAsString)")
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String) {
        statusTextView.text = "Listening setup wasn't successful and returned the failure reason: \(reasonForFailure)"
        print(statusTextView.text)
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String) {
        statusTextView.text = "Listening teardown wasn't successful and returned the failure reason: \(reasonForFailure)"
        print(statusTextView.text)
    }
    
    func testRecognitionCompleted() {
        statusTextView.text = "A test file that was submitted for recognition is now complete."
        print(statusTextView.text)
    }
    
    func pocketsphinxFailedNoMicPermissions() {
        NSLog("The user has never set mic permissions or denied permission to access mic.")
        self.startupFailedDueToLackOfPermissions = true
        if OEPocketsphinxController.sharedInstance().isListening {
            let error = OEPocketsphinxController.sharedInstance().stopListening() // Stop listening if we are listening.
            if (error != nil) {
                NSLog("Error while stopping listening in micPermissionCheckCompleted: %@", error);
            }
        }
    }

}
