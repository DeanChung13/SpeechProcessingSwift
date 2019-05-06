//
//  ViewController.swift
//  BeatVox
//
//  Created by Nahuel Proietto on 14/2/18.
//  Copyright © 2018 ADBAND. All rights reserved.
//

import UIKit

struct Parameters {
  static let REQUIRED_TRAINING = 500
  static let PROBABILITY_THRESHOLD:Float = 55.0
  static let FFT_BANDS_PER_OCTAVE = 45
}

class ViewController: UIViewController {
  
  @IBOutlet weak var spectralView: SpectralView!
  @IBOutlet weak var phonemaTextField: UITextField?
  
  var audioInput: Audio!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    self.phonemaTextField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    let audioInputCallback: AudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
      let numberOfBands = UIScreen.main.bounds.size.width * UIScreen.main.scale
      Analyser.sharedInstance.analyse(timeStamp: Double(timeStamp),
                                      numberOfFrames: Int(numberOfFrames),
                                      numberOfBands: Int(numberOfBands),
                                      samples: samples)
      // UI rendering
      tempi_dispatch_main { () -> () in
        self.refreshViews()
      }
    }
    self.audioInput = Audio(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
    self.audioInput.startRecording()
  }
  
  func setupConstraints() {
    view.addConstraints([
      spectralView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      spectralView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      spectralView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
      ])
  }
  
  func refreshViews() {
    self.spectralView.fft = Analyser.sharedInstance.fft
    self.spectralView.setNeedsDisplay()
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    Analyser.sharedInstance.phonema = textField.text!
  }
  
  @IBAction func listenMode(sender: AnyObject) {
    Analyser.sharedInstance.listeningMode = true
  }
  
}

