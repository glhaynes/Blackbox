# Blackbox
### Nintendo Entertainment System (NES) emulator for Apple platforms

Blackbox is an NES emulator app for iOS, iPadOS, macOS, and visionOS.

It’s a work in progress by [Grady Haynes](mailto:grady@wordparts.com) and is freely available under the MIT license. Feedback and contributions are welcomed. It requires a minimum of iOS/iPadOS 16.4, macOS Ventura 13.3, or the visionOS 1.0 simulator. Building Blackbox requires Xcode 14. (visionOS support requires the Xcode 15 beta.)

Blackbox is a hobby project for experimentation and learning, but I’d be delighted for anyone to use it, learn from it, or reuse its code in another project.

It’s named for the classic [“black box” games](https://videogamegraders.com/nes-black-box-games-details/) released alongside and soon after the NES’s release in North America in 1985. 

<p align="center">
  <img src="Media/Blackbox running Super Mario Bros..gif" hspace="20" vspace="20" alt="Blackbox running Super Mario Bros on a Mac" />
</p>
<p align="center">
  <img src="Media/Golf-Dark-iPhone14ProMaxWithBezel.png" hspace="20" vspace="20" alt="Blackbox running Golf on an iPhone 14 Pro Max" />
  <img src="Media/OnboardingTitleScreen-Dark-iPhone14ProMaxWithBezels.png" hspace="20" vspace="20" alt="Blackbox’s onboarding screen on an iPhone 14 Pro Max" />
</p>
<p align="center">
  <img src="Media/BalloonFight-Light-iPadPro11WithBezels.png" hspace="20" vspace="20" alt="Blackbox running Balloon Fight on an iPad Pro 11&#34;" />
</p>
<p align="center">
  <img src="Media/Baseball-AppleVisionPro.jpg" hspace="20" vspace="20" alt="Blackbox running Baseball on Apple Vision Pro" />
</p>

## Playing NES games
Blackbox is *not* the best way to play NES games on its supported platforms, at least not currently. It isn’t compatible with most games and has no audio emulation. That said, I’ve had a great time playing through [Super Mario Bros.](https://en.wikipedia.org/wiki/Super_Mario_Bros.) several times during its development!

If your primary goal is playing NES games on Apple platforms, I’d suggest checking out [OpenEmu](https://openemu.org) for Mac, [Delta](https://github.com/rileytestut/Delta) for iOS, or [Provenance](https://github.com/Provenance-Emu/Provenance) for iOS and tvOS.

To play a game on Blackbox, you’ll need to open a `.nes` file (a “ROM”) for the game. I can’t provide copyrighted ROMs, but there are many sources on the internet that can provide more information, including how to “dump” a ROM from a cartridge you own.

A freely-distributable sample ROM is included in the app so the app can be tested. See “Acknowledgments” section below for details on it.

## Technical Details
Blackbox uses the SwiftUI app lifecycle. It includes:
- Game controller and keyboard support leveraging the system [Game Controller framework](https://developer.apple.com/documentation/gamecontroller)
- An onscreen virtual touch controller [available as a Swift package](https://github.com/glhaynes/OnscreenController)
- A set of “accessories” providing realtime information on the emulated NES’s CPU state and the PPU’s palettes and pattern tables
- An onboarding/usage workflow
- Support for opening NES ROM files (iNES format), including a recents list
- A sample ROM for testing

It’s built on top of `CoreBlackbox`, a module that provides the following:
- A 6502 emulator, “CPU6502”, written in Swift
  - Aside from cycle timing, this is an accurate emulator, including “illegal” instructions.
- A Swift wrapper around the C-language `m6502` CPU emulator from [floooh’s “chips” project](https://github.com/floooh/chips)
  - This is useful during testing/debugging as it’s a “known good”, cycle-accurate, cycle-stepped 6502 emulator.
- Emulation of the NES’s Picture Processing Unit (PPU)
- (Very) basic mapper support
- Loading and parsing iNES files (ROMs)

More of the above components may be separated into their own Swift packages in the future. If you have suggestions for what would be particularly useful, please let me know.

## Privacy and Data Collection
Blackbox does not make any network calls; no personal data is recorded or sent by the app.

## Acknowledgements
This project relies heavily on some fantastic resources, most prominently those below. I’m grateful for their work.

- Javidx9’s [NES Emulator From Scratch](https://www.youtube.com/playlist?list=PLrOv9FMX8xJHqMvSGB_9G9nZZ_4IgteYf) channel on YouTube was tremendously helpful, particularly when building the PPU emulation.
- `m6502` from [floooh’s “chips” project](https://github.com/floooh/chips) is a well-crafted set of highly-accurate 8-bit chip emulators. The project’s 6502 emulator is used in this project for testing and debugging. [This document](https://floooh.github.io/2019/12/13/cycle-stepped-6502.html) describing it was enlightening reading.
- [RussianManSMWC](https://github.com/RussianManSMWC)’s [Donkey Kong NES disassembly](https://github.com/RussianManSMWC/Donkey-Kong-NES-Disassembly) saved hours of debugging time while getting the project’s components connected.
- The included “Sample ROM” is [`NES-ca65-example`](https://github.com/bbbradsmith/NES-ca65-example) by [Brad Smith](http://rainwarrior.ca/). Assembly source is available at the link.
- [Toffer D. Brutechild](https://itstoffer.com) beta tested and gave valuable feedback, ideas, and encouragement. 
