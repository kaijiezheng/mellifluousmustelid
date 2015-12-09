//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "SWRevealViewController.h"

// Generates new language model and accompanying acoustic model, ideally 10 to 500 words
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>

// Performs speech recognition
#import <OpenEars/OEPocketsphinxController.h>

// Continuous monitor status of mic via callbacks
#import <OpenEars/OEEventsObserver.h>

// Allows logging of recording status
#import <OpenEars/OELogging.h>

// Text to speech, slt is the voice
#import <OpenEars/OEFliteController.h>
#import <Slt/Slt.h>
