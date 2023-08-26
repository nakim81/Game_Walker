//
//  AudioPlayerManager.swift
//  Game_Walker
//
//  Created by Noah Kim on 8/24/23.
//

import Foundation
import AVFoundation

class AudioPlayerManager {
    private var audioPlayer: AVAudioPlayer?

    func playAudioFile(named fileName: String, withExtension fileExtension: String) {
        // Stop any currently playing audio before playing a new file
        stop()

        if let audioURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error playing audio:", error)
            }
        } else {
            print("Audio file not found.")
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

