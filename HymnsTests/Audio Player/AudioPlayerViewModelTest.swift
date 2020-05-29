import Nimble
import XCTest
import AVFoundation
@testable import Hymns

class AudioPlayerViewModelTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_playerCurrentTime() {
        let audio = AudioPlayerViewModel(item: URL(string: "http://www.hymnal.net/en/hymn/h/894/f=mp3"))
        guard let url = audio.item else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        audio.player.replaceCurrentItem(with: playerItem)
        audio.player.play()
        audio.player.seek(to: CMTimeMake(value: 3500,
                                         timescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        expect(audio.playerCurrentTime).to(equal(3.5))
    }

    func test_CMTimeConverter() {
        let audio = AudioPlayerViewModel(item: URL(string: "http://www.hymnal.net/en/hymn/h/894/f=mp3"))
        let convertedTime = audio.convertFloatToCMTime(1.0)
        let cmtime = CMTimeMake(value: 1000,
                                timescale: 1000)
        expect(convertedTime).to(equal(cmtime))
    }
}
