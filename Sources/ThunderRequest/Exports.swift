// The Carthage framework's umbrella header imported UIKit, which re-exported UIKit (and
// Foundation) to every file that imported this module. Keep doing so, so code written
// against the framework still compiles without its own UIKit/Foundation imports.
@_exported import UIKit
