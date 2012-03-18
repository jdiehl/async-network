= Mac OS

== Build

Build AsyncNetwork for Archiving (Release Configuration)

== Installation

1. In Project Summary: Add CFNetwork.framework to Linked Frameworks and Libraries
2. In Project Summary: Add AsyncNetwork.framework to Linked Frameworks and Libraries
3. In Project Build Phases: Add Build Phase: Add Copy Files
   - Destination: Frameworks
   - Add AsyncNetwork.framework
4. Add to Project-Prefix.pch: #import <AsycnNetwork/AsyncNetwork.h>


= iOS

== Build (Device + Simulator)

This will build a static library for device and simulator and embed it in a framework structure.

1. Build AsyncNetwork for Archiving (Release Configuration)
2. Build AsyncNetwork.iOS on Simulator (Debug Configuration)
3. Build AsyncNetwork.iOS on Device for Archiving (Release Configuration)
4. Build AsyncNetwork.iOS.finish for Archiving (Release Configuration)

== Installation

Same as for Mac OS (use iOS/AsyncNetwork.framework)
