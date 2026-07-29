// Preface: we want to look at "screenSafe" sizes to work
// around nav bars, status bars, etc. We CAN use screen
// sizes, e.g. MediaQuery.of(context).size.height, but we
// are getting LayBuilder box constraints to determine the
// screenSafeHeight and screenSafeWidth.
// Aspect Ratio of to maintain is ~5:6 or 0.8371:1, e.g.
// 560ssw x 669ssh (560sw x 725sh). This is the point
// where it shrinks from width changes to height changes
// and vice versa.

// Goal: find a formula (or two) that handles dealing with
// the specific aspect ratio above while supplying values
// for the following variables:
// screenSafeWidth
// screenSafeHeight
// pageWidth
// pageHeight,
// spineOffset
// flipperOffset
// fadeEnd
// prevWidth

// For when screenSafeHeight == 941 (sh == 997)
// screenSafeWidth x screenSafeHeight => pageWidth x pageHeight (spineOffset) [flipperOffset] {fadeEnd} "prevWidth"
// 390ssw x 788ssh => 250pw x 345ph (58so) [-12.5off] {0.333fe} "315"
// 500ssw x 941ssh => 330pw x 447.5ph (76so) [-15off] {0.275fe} "415"
// 670ssw x 941ssh => 445pw x 610ph (103so) [-25off] {0.225fe} "570"
// 778ssw x 941ssh => 525pw x 710ph (120so) [-26.5off] {0.2fe} "660"
// > maintains above, i.e. triggers the aspect ratio to
// hold after this point, and we maintain. BUT if screen
// height goes down, we need below to recalculate and
// change our variables based on the new height & width.

// For when screenSafeWidth == 560 (sw == 560)
// screenSafeWidth => pageWidth x pageHeight (spineOffset) [flipperOffset] {fadeEnd} "prevWidth"
// 500ssw x 941ssh => 330pw x 447.5ph (76so) [-15off] {0.275fe} "415"
// 560ssw x 941ssh => 375pw x 500ph (86so) [-17.5off] {0.275fe} "470"
// 560ssw x 800ssh => 375pw x 500ph (86so) [-17.5off] {0.275fe} "470"
// 560ssw x 674ssh => 375pw x 500ph (85so) [-17.5off] {0.275fe} "470"
// This is no longer holding those values because the aspect
// ratio.
// 560ssw x 550ssh => 310pw x 410ph (70so) [-15.5off] [0.225fe] "387.5"
// 560ssw x 424ssh => 237.5pw x 315ph (53so) [-10off] [0.2fe] "297.5"
// 560ssw x 244ssh => 137.5pw x 185ph (31so) [-6.5off] [0.333fe] "170"

// Consideration: when the aspect ratio is triggered and
// more width is added, the calculations stay the same;
// however, if the height changes, we need to recalculate.
