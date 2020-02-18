//
//  CustomSpeechSynthesizer.swift
//  SpeechLeakWatch Extension
//
//  Created by Wayne Hartman on 2/17/20.
//  Copyright © 2020 Wayne Hartman. All rights reserved.
//

import AVFoundation

/**
 Custom AVSpeechSynthesizer specifically to demonstrate that the instance is geting dealloc'ed, however, the memory allocated from underlying framework(s) is leaked.
 */
class CustomSpeechSynthesizer: AVSpeechSynthesizer {
    deinit {
        print("CustomSpeechSynthesizer: deinit")
    }
}
