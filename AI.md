# AI Usage Documentation

### Project Overview
- **Project Name:** Rectangle Splitter (`rectangle_app`)
- **Description:** A cross-platform Flutter application implementing interactive binary space partitioning (BSP), inspired by tiling window managers (such as i3 and bspwm). Tapping any rectangle splits it in two equal halves with alternating vertical and horizontal orientations, featuring real-time customization (border thickness, corner radius, HSL gradient mode, random color palettes) and visual metrics (live rectangle count and depth indicators).
- **AI Tools Used:** 
  - **Claude (Anthropic):** Used to brainstorm requirements, organize prompts, and structure user stories.
  - **Antigravity Coding Assistant (Google DeepMind / Gemini):** Used as an interactive pair programmer inside the IDE to scaffold the project, write Flutter/Dart code, run analyzer/test commands, and diagnose layout issues.

---

### Development Conversation Log

**Me:** I want to create a Flutter app that starts with a single full-screen beige rectangle. When tapped, it should split into two equal rectangles. The first split should be vertical (two side-by-side vertical rectangles in a `Row`). Each subsequent split on any rectangle should alternate direction relative to its parent (horizontal cut in a `Column`, then vertical, etc.), repeating indefinitely like a binary space partition (BSP) tree. How should we model and implement this?

**AI:** We can represent the partition tree with a recursive `Node` class containing `bool isLeaf`, `SplitOrientation orientation` (an enum: `vertical` or `horizontal`), and `List<Node> children`. When a leaf node is clicked, `split()` sets `isLeaf = false` and assigns two child leaf nodes with the opposite orientation. In Flutter, we build the widget tree recursively using a `_buildNode(Node node)` function: leaf nodes return a `GestureDetector` wrapping a `Container`, while split nodes return a `Row` (for vertical cuts) or a `Column` (for horizontal cuts), wrapping each child in an `Expanded` widget so each half gets exactly 50% of the parent space.

**Me:** That works. Now let's add three more features:
1. A restart button (refresh icon) at the top right to reset the tree back to a single beige rectangle.
2. Random colors on each split: each new child rectangle should get a distinct color from a curated, aesthetic palette so it doesn't look muddy.
3. An options button at the top left that opens a settings modal sheet with sliders for border width and corner radius, a toggle switch for "mode dégradé" (where children get tints/shades of the parent's color using `HSLColor`), and a selectable base color palette.

**AI:** I'll modularize the codebase into `lib/models/node.dart`, `lib/widgets/options_sheet.dart`, and `lib/main.dart`. In `Node`, we'll add a `Color color` property and an `aestheticPalette` of non-muddy colors. In `split({required bool gradientMode})`, if gradient mode is off, we assign random palette colors to both children; if on, we use `HSLColor.fromColor(color)` to shift lightness ($\pm 0.10$) and saturation ($\pm 0.05$) to generate smooth shade variations. In `OptionsSheet` (`showModalBottomSheet`), we add sliders for border thickness and corner radius, a `Switch` for gradient mode, and a circular color palette that resets the root rectangle when tapped.

**Me:** There is a visual bug on the screen: the rectangles only fill a small strip at the top instead of the entire page, and the floating buttons in the `Stack` are layered directly over the rectangles, causing sizing and tap issues. Can we fix this so there is a fixed `AppBar` and the rectangles take 100% of the remaining screen?

**AI:** The reason the rectangles collapsed is twofold: first, the `Stack` did not provide tight constraints down the tree. Second, in Flutter, `Row` and `Column` have `crossAxisAlignment: CrossAxisAlignment.center` by default, so without explicit child sizes or stretch constraints, the secondary axis collapses. 
To fix this cleanly:
1. We replace the `Stack` with a standard `Scaffold` with an `AppBar`. The options button goes into `leading` and the restart button into `actions`, keeping navigation completely separated from the canvas.
2. In the body, we wrap the root node in `SizedBox.expand()`.
3. In both `Row` and `Column`, we set `crossAxisAlignment: CrossAxisAlignment.stretch`.
4. In each leaf node, we wrap the `Container` with `SizedBox.expand` and set its width and height to `double.infinity`. Now every rectangle strictly fills 100% of the body space at all split depths.

**Me:** I verified the fix and the layout fills the screen properly now. Now I want to display the total number of visible rectangles in the `AppBar` title (e.g., "Rectangles : X"). It should update automatically on every split and reset to 1 on restart.

**AI:** Since each visible rectangle corresponds to a leaf in the tree, we can count them by traversing the tree and summing all nodes where `isLeaf == true`. I added a recursive helper function `countRectangles(Node node)` (and a `leafCount` getter on `Node`). In `RectangleSplitScreen.build()`, we compute `final int rectangleCount = countRectangles(_root);` and display it in the `AppBar`'s centered title: `Text('Rectangles : $rectangleCount')`. Because `setState()` is called on every split and reset, the counter recalculates and updates instantly.

**Me:** Next, I want each rectangle to display its tree depth (`depth`) right in the center. The root should show 0, its children 1, grandchildren 2, etc. The text must remain readable regardless of the background color, and it shouldn't overflow if the rectangle becomes small.

**AI:** We add an `int depth` field to `Node` (defaulting to 0 for the root). When `node.split()` is called, each child receives `depth: depth + 1`. In `_buildNode`, inside the leaf `Container`, we center a `FittedBox(fit: BoxFit.scaleDown)` containing `Text('${node.depth}')`. To guarantee readability across light, dark, and gradient backgrounds, we use `ThemeData.estimateBrightnessForColor(node.color)` to choose dark text (`#2C2523`) for light rectangles and white text for dark ones, plus a subtle drop shadow. `FittedBox` ensures the text scales down cleanly without overflowing when rectangles become very small.

**Me:** Let's run static analysis and tests to make sure there are no errors, deprecations, or broken behavior.

**AI:** I ran `flutter analyze` which caught one deprecation: `activeColor` on `Switch` in `options_sheet.dart` needed to be updated to `activeThumbColor`. After fixing it, `flutter analyze` passed with 0 issues. I also created a test suite in `test/widget_test.dart` containing 7 tests verifying:
- Initial state (1 leaf rectangle with depth 0, counter showing "Rectangles : 1").
- Splitting progression and alternating `Row`/`Column` orientation.
- Physical layout dimensions under the `AppBar` (800x544 px with 0 gaps).
- Depth incrementation (`0 -> 1 -> 2`).
- Options sheet sliders and gradient mode toggle.
- Full reset back to a single rectangle.
All 7 tests passed successfully.

---

### What I Learned / My Own Contribution

- **Binary Space Partitioning & Recursion:** I learned how to represent a 2D spatial layout as a binary tree in Dart and how recursive widget rendering mirrors the data structure directly.
- **Flutter Layout Constraints:** I diagnosed why nested `Row` and `Column` widgets collapsed along their cross-axes, and learned the critical role of `CrossAxisAlignment.stretch`, `Expanded`, and `SizedBox.expand` in passing tight constraints down through arbitrary nesting.
- **Color Systems & Accessibility:** I learned how to work with `HSLColor` for programmatic shade and tint generation, and how to use `ThemeData.estimateBrightnessForColor` to dynamically adapt foreground text contrast.
- **Iterative Problem Solving & Testing:** Instead of trying to build everything in a single prompt, I guided the project step-by-step (core logic $\rightarrow$ styling $\rightarrow$ layout debugging $\rightarrow$ metrics $\rightarrow$ tests), verified each step with `flutter analyze` and `flutter test`, and ensured zero deprecated APIs remained in the codebase.
