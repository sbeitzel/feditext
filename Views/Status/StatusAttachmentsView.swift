// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Network
import UIKit
import ViewModels

final class StatusAttachmentsView: UIView {
    private let containerStackView = UIStackView()
    private let leftStackView = UIStackView()
    private let rightStackView = UIStackView()
    private let curtain = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let curtainButton = UIButton(type: .system)
    private let hideButtonBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let hideButton = UIButton()
    private var aspectRatioConstraint: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()

    var viewModel: StatusViewModel? {
        didSet {
            for stackView in [leftStackView, rightStackView] {
                for view in stackView.arrangedSubviews {
                    stackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }

            let attachmentViewModels = viewModel?.attachmentViewModels ?? []
            let attachmentCount = attachmentViewModels.count

            rightStackView.isHidden = attachmentCount == 1

            for (index, viewModel) in attachmentViewModels.enumerated() {
                let attachmentView = StatusAttachmentView(viewModel: viewModel)

                if attachmentCount == 2 && index == 1
                    || attachmentCount == 3 && index != 0
                    || attachmentCount > 3 && index % 2 != 0 {
                    rightStackView.addArrangedSubview(attachmentView)
                } else {
                    leftStackView.addArrangedSubview(attachmentView)
                }
            }

            let newAspectRatio: CGFloat

            if attachmentCount == 1, let aspectRatio = attachmentViewModels.first?.aspectRatio {
                newAspectRatio = max(CGFloat(aspectRatio), 16 / 9)
            } else {
                newAspectRatio = 16 / 9
            }

            aspectRatioConstraint?.isActive = false
            aspectRatioConstraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: newAspectRatio)
            aspectRatioConstraint?.priority = .justBelowMax
            aspectRatioConstraint?.isActive = true

            curtain.isHidden = viewModel?.shouldShowAttachments ?? false
            curtainButton.setTitle(
                NSLocalizedString((viewModel?.sensitive ?? false)
                                    ? "attachment.sensitive-content"
                                    : "attachment.media-hidden",
                                  comment: ""),
                                   for: .normal)
            hideButtonBackground.isHidden = !(viewModel?.shouldShowHideAttachmentsButton ?? false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialSetup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatusAttachmentsView {
    var shouldAutoplay: Bool {
        guard !isHidden, let viewModel = viewModel, viewModel.shouldShowAttachments else { return false }

        let appPreferences = viewModel.identification.appPreferences
        let onWifi = NWPathMonitor(requiredInterfaceType: .wifi).currentPath.status == .satisfied
        let hasVideoAttachment = viewModel.attachmentViewModels.contains { $0.attachment.type == .video }
        let shouldAutoplayVideo = appPreferences.autoplayVideos == .always
            || appPreferences.autoplayVideos == .wifi && onWifi

        if hasVideoAttachment && shouldAutoplayVideo {
            return true
        }

        let hasGIFAttachment = viewModel.attachmentViewModels.contains { $0.attachment.type == .gifv }
        let shouldAutoplayGIF = appPreferences.autoplayGIFs == .always || appPreferences.autoplayGIFs == .wifi && onWifi

        return hasGIFAttachment && shouldAutoplayGIF
    }
}

private extension StatusAttachmentsView {
    // swiftlint:disable:next function_body_length
    func initialSetup() {
        backgroundColor = .clear
        layoutMargins = .zero
        clipsToBounds = true
        layer.cornerRadius = .defaultCornerRadius
        addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.distribution = .fillEqually
        containerStackView.spacing = .compactSpacing
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = .compactSpacing
        leftStackView.axis = .vertical
        rightStackView.distribution = .fillEqually
        rightStackView.spacing = .compactSpacing
        rightStackView.axis = .vertical
        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(rightStackView)

        let toggleShowAttachmentsAction = UIAction { [weak self] _ in
            self?.viewModel?.toggleShowAttachments()
        }

        addSubview(hideButtonBackground)
        hideButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        hideButtonBackground.clipsToBounds = true
        hideButtonBackground.layer.cornerRadius = .defaultCornerRadius

        hideButton.addAction(toggleShowAttachmentsAction, for: .touchUpInside)
        hideButtonBackground.contentView.addSubview(hideButton)
        hideButton.translatesAutoresizingMaskIntoConstraints = false
        hideButton.setImage(
            UIImage(systemName: "eye.slash", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)),
            for: .normal)
        addSubview(curtain)
        curtain.translatesAutoresizingMaskIntoConstraints = false
        curtain.contentView.addSubview(curtainButton)

        curtainButton.addAction(toggleShowAttachmentsAction, for: .touchUpInside)
        curtainButton.translatesAutoresizingMaskIntoConstraints = false
        curtainButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        curtainButton.titleLabel?.adjustsFontForContentSizeCategory = true

        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hideButtonBackground.topAnchor.constraint(equalTo: topAnchor, constant: .defaultSpacing),
            hideButtonBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .defaultSpacing),
            hideButton.topAnchor.constraint(
                equalTo: hideButtonBackground.contentView.topAnchor,
                constant: .compactSpacing),
            hideButton.leadingAnchor.constraint(
                equalTo: hideButtonBackground.contentView.leadingAnchor,
                constant: .compactSpacing),
            hideButtonBackground.contentView.trailingAnchor.constraint(
                equalTo: hideButton.trailingAnchor,
                constant: .compactSpacing),
            hideButtonBackground.contentView.bottomAnchor.constraint(
                equalTo: hideButton.bottomAnchor,
                constant: .compactSpacing),
            curtain.topAnchor.constraint(equalTo: topAnchor),
            curtain.leadingAnchor.constraint(equalTo: leadingAnchor),
            curtain.trailingAnchor.constraint(equalTo: trailingAnchor),
            curtain.bottomAnchor.constraint(equalTo: bottomAnchor),
            curtainButton.topAnchor.constraint(equalTo: curtain.contentView.topAnchor),
            curtainButton.leadingAnchor.constraint(equalTo: curtain.contentView.leadingAnchor),
            curtainButton.trailingAnchor.constraint(equalTo: curtain.contentView.trailingAnchor),
            curtainButton.bottomAnchor.constraint(equalTo: curtain.contentView.bottomAnchor)
        ])

        NotificationCenter.default.publisher(for: TableViewController.autoplayableAttachmentsViewNotification)
            .sink { [weak self] in
                guard let self = self else { return }

                for attachmentView in self.attachmentViews {
                    attachmentView.playing = $0.object as? Self === self
                }
            }
            .store(in: &cancellables)
    }

    var attachmentViews: [StatusAttachmentView] {
        (leftStackView.arrangedSubviews + rightStackView.arrangedSubviews)
            .compactMap { $0 as? StatusAttachmentView }
    }
}
