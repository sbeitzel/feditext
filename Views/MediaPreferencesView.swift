// Copyright © 2020 Metabolist. All rights reserved.

import SwiftUI
import ViewModels

struct MediaPreferencesView: View {
    @StateObject var viewModel: MediaPreferencesViewModel
    @EnvironmentObject var identification: Identification
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion

    var body: some View {
        Form {
            if accessibilityReduceMotion {
                Section {
                    Toggle("preferences.media.use-system-reduce-motion",
                           isOn: $identification.appPreferences.useSystemReduceMotionForMedia)
                }
            }
            Section(header: Text("preferences.media.autoplay")) {
                Picker("preferences.media.autoplay.gifs",
                       selection: reduceMotion ? .constant(.never) : $identification.appPreferences.autoplayGIFs) {
                    ForEach(AppPreferences.Autoplay.allCases) { option in
                        Text(option.localizedStringKey).tag(option)
                    }
                }
                Picker("preferences.media.autoplay.videos",
                       selection: reduceMotion ? .constant(.never) : $identification.appPreferences.autoplayVideos) {
                    ForEach(AppPreferences.Autoplay.allCases) { option in
                        Text(option.localizedStringKey).tag(option)
                    }
                }
            }
            .disabled(reduceMotion)
            Section(header: Text("preferences.media.avatars")) {
                Picker("preferences.media.avatars.animate",
                       selection: reduceMotion ? .constant(.never) : $identification.appPreferences.animateAvatars) {
                    ForEach(AppPreferences.AnimateAvatars.allCases) { option in
                        Text(option.localizedStringKey).tag(option)
                    }
                }
                .disabled(reduceMotion)
            }
            Section(header: Text("preferences.media.headers")) {
                Toggle("preferences.media.headers.animate",
                       isOn: reduceMotion ? .constant(false) : $identification.appPreferences.animateHeaders)
                    .disabled(reduceMotion)
            }
        }
        .navigationTitle("preferences.media")
    }
}

private extension MediaPreferencesView {
    var reduceMotion: Bool {
        identification.appPreferences.shouldReduceMotion
    }
}

extension AppPreferences.AnimateAvatars {
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .everywhere:
            return "preferences.media.avatars.animate.everywhere"
        case .profiles:
            return "preferences.media.avatars.animate.profiles"
        case .never:
            return "preferences.media.avatars.animate.never"
        }
    }
}

extension AppPreferences.Autoplay {
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .always:
            return "preferences.media.autoplay.always"
        case .wifi:
            return "preferences.media.autoplay.wifi"
        case .never:
            return "preferences.media.autoplay.never"
        }
    }
}

#if DEBUG
struct MediaPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPreferencesView(viewModel: .init(identification: .preview))
    }
}
#endif
