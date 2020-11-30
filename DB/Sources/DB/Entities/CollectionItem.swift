// Copyright © 2020 Metabolist. All rights reserved.

import Mastodon

public enum CollectionItem: Hashable {
    case status(Status, StatusConfiguration)
    case loadMore(LoadMore)
    case account(Account)
    case notification(MastodonNotification, StatusConfiguration?)
    case conversation(Conversation)
}

public extension CollectionItem {
    typealias Id = String

    struct StatusConfiguration: Hashable {
        public let showContentToggled: Bool
        public let showAttachmentsToggled: Bool
        public let isContextParent: Bool
        public let isPinned: Bool
        public let isReplyInContext: Bool
        public let hasReplyFollowing: Bool

        init(showContentToggled: Bool,
             showAttachmentsToggled: Bool,
             isContextParent: Bool = false,
             isPinned: Bool = false,
             isReplyInContext: Bool = false,
             hasReplyFollowing: Bool = false) {
            self.showContentToggled = showContentToggled
            self.showAttachmentsToggled = showAttachmentsToggled
            self.isContextParent = isContextParent
            self.isPinned = isPinned
            self.isReplyInContext = isReplyInContext
            self.hasReplyFollowing = hasReplyFollowing
        }
    }

    var itemId: Id? {
        switch  self {
        case let .status(status, _):
            return status.id
        case .loadMore:
            return nil
        case let .account(account):
            return account.id
        case let .notification(notification, _):
            return notification.id
        case let .conversation(conversation):
            return conversation.id
        }
    }
}

public extension CollectionItem.StatusConfiguration {
    static let `default` = Self(showContentToggled: false, showAttachmentsToggled: false)
}