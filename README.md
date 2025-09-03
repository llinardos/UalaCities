# Mobile Challenge - Ualá - iOS
## Leandro Linardos

https://github.com/user-attachments/assets/691b6ca8-adca-4f93-92e8-b92d3d4b7b89

### General process

I think it is really valuable to have an app/feature running as fast as possible. So I've started with a list of cities names in portrait only, no error handling, no progress indication. I've parsed just the name of the city from the online json and showed a list of cities names. Once I pinned this behavior with smoke and unit tests I've continued adding new features and variations iterative and incrementally. I've added filtering, performance issues arose, I've fixed them, then favoriting, then persistent favorites. Then city on the map. Then landscape support. Finally the info screen.

I've used TDD so I have tests verifying almost each implemented behavior, which allowed me to refactor several times during this process. Some components (even foundational ones) emerged from these refactors, i.e. Cities API, CitiesStore, abstractions to inverse dependency on user defautls, http client, etc, also extracted views (like the info message view used for empty states and errors). 

### Architecture

I've used MVVM because is part of my development process and I prefer it over other mobile front end architectural patterns. I think it allows us to represent real elements on the ui (like screens, buttons, flows, even the whole app) and also makes it really easy to write testable code without boilerplate.
In this project there are VMs for screens, for views and subviews, and even for the app. I use to have VMs for flows too (collections of screens that work together, e.g. auth, profile, settings, home, payment, etc). Theres no flow vm in this app because it's pretty small.
Related to asynchronous handling, I've used standard completion callbacks + Result monad.
Relatead to UI I've used SwiftUI, but I'm pretty comfortable with UIKit too. The kind of view model used in this project works with both UIKit and SwiftUI, so I think they are really useful for UIKit to SwiftUI migrations.

### Fitering performance

I've started with the simplest approach: filter + hasPrefix. It looked to work ok but there were hangs on the filterings. Filtering performance is not related to the number of elements in the result set. We need to traverse all the collection no matter if there are 10k results or just 1. So the culprit of this hangs wasn't the filter algorithm.
The problem was setting 200k+ items in a SwiftUI.List, so I've implemented a local pagination mechanism that collaborates with the list. Given the 200k+ items, it provides just the first 100 (configurable). When the user scrolls and is close to the last item, the pagination mechanims servers the next 100 and now the list shows 200. This process repeats. Beyond that, filtering also runs on a background thread.

Note 1: at some point I added rows view models and performance issues come back. The reason was I was creating a row viewmodel for each city. So I moved the row creating to the pagination mechanism.

Note 2: in case filter + hasPrefix is not enough performance, we can switch to a Trie structure which is great for prefix text filtering. Performance will go from O(number of elements) o O(query lenght).

### Testing Strategy

There's a single smoke ui test that touches the happy paths and some important variations of each feature of the app (showing cities, filtering, favoriting, rotating, navigating). It uses the real online cities json.
There's a single integration test checking that the cities json is available and we're parsing it ok.
I've used TDD so there's a bunch of unit tests covering almost all of the variations of each feature. These tests use stubs for http client, user defaults, async running (for the filtering running on background), and a logger.

This test harness checks the system behavior, coupled to the UI but decoupled from code structure allowed me to refactor safely during the whole development process.

For views restructuring (i.e. extracting the info message view used for empty and errors views) it would have been useful to have snapshot tests but no third party libs were allowed (I rely on pointfree snapshot testing lib for this).
