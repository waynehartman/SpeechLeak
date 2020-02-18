//
//  InterfaceController.swift
//  SpeechLeakWatch Extension
//
//  Created by Wayne Hartman on 2/17/20.
//  Copyright © 2020 Wayne Hartman. All rights reserved.
//

import WatchKit
import Foundation
import MachO
import AVFoundation


class NewSynthesizerInterfaceController: WKInterfaceController {
    var timer: Timer?
    let numberFormatter = NumberFormatter()
    var counter = 0
    
    @IBOutlet fileprivate var sizeLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.numberFormatter.numberStyle = .decimal
        
        weak var weakSelf = self
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer: Timer) in
            guard let weakSelf = weakSelf else {
                timer.invalidate()
                return
            }
            
            if
                let amount = weakSelf.getMemoryUsage(),
                let formatted = weakSelf.numberFormatter.string(from: NSNumber(value: amount))
            {
                DispatchQueue.main.async {
                    weakSelf.sizeLabel.setText(formatted)
                }
            }
            
            weakSelf.counter += 1
            
            let speechSynth = CustomSpeechSynthesizer()
            speechSynth.speak(AVSpeechUtterance(string: String(weakSelf.counter)))
            
        })
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    fileprivate func getMemoryUsage() -> Int? {
        let TASK_VM_INFO_COUNT = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size
        
        var vmInfo = task_vm_info_data_t()
        var vmInfoSize = mach_msg_type_number_t(TASK_VM_INFO_COUNT)
        
        let kern: kern_return_t = withUnsafeMutablePointer(to: &vmInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(TASK_VM_INFO),
                          $0,
                          &vmInfoSize)
            }
        }
        
        if kern == KERN_SUCCESS {
            let usedSize = Int(vmInfo.internal + vmInfo.compressed)
            return usedSize
        } else {
            let errorString = String(cString: mach_error_string(kern), encoding: .ascii) ?? "unknown error"
            print("Error with task_info(): %s", errorString);
            return nil
        }
    }

}
