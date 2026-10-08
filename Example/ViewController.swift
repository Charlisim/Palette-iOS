//The MIT License (MIT)
//
//Copyright (c) 2015 Carlos Simón
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Palette
import UIKit

@MainActor
final class ViewController: UIViewController {
  private var samples: [(background: UIView, label: UILabel, name: String)] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    let content = UIStackView()
    content.axis = .vertical
    content.spacing = 8
    content.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(content)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
      content.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
      content.leadingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
      content.trailingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
      content.widthAnchor.constraint(
        equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
    ])
    let title = UILabel()
    title.text = "Palette"
    title.font = .preferredFont(forTextStyle: .largeTitle)
    title.adjustsFontForContentSizeCategory = true
    content.addArrangedSubview(title)
    let subtitle = UILabel()
    subtitle.text = "Swift · Foreground chosen from each background"
    subtitle.font = .preferredFont(forTextStyle: .subheadline)
    subtitle.textColor = .secondaryLabel
    subtitle.numberOfLines = 0
    subtitle.adjustsFontForContentSizeCategory = true
    content.addArrangedSubview(subtitle)
    content.setCustomSpacing(20, after: subtitle)

    let colors: [(String, UIColor)] = [
      ("System background", .systemBackground),
      ("Red · #FF0000", .red),
      ("Orange · #FF8000", UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)),
      ("Yellow · #FFFF00", .yellow),
      ("Green · #00FF00", .green),
      ("Cyan · #00FFFF", .cyan),
      ("Blue · #0000FF", .blue),
      ("Purple · #800080", UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)),
    ]
    for (name, color) in colors {
      let background = UIView()
      background.backgroundColor = color
      background.layer.cornerRadius = 12
      background.layer.borderWidth = 1
      let label = UILabel()
      label.font = .preferredFont(forTextStyle: .body)
      label.adjustsFontForContentSizeCategory = true
      label.numberOfLines = 0
      label.text = name
      label.translatesAutoresizingMaskIntoConstraints = false
      background.addSubview(label)
      NSLayoutConstraint.activate([
        background.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
        label.topAnchor.constraint(equalTo: background.topAnchor, constant: 12),
        label.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -12),
        label.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -16),
      ])
      content.addArrangedSubview(background)
      samples.append((background, label, name))
    }
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
        (controller: ViewController, _: UITraitCollection) in
        controller.view.setNeedsLayout()
      }
    }
  }

  @available(iOS, introduced: 15.0, deprecated: 17.0)
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if #unavailable(iOS 17.0) {
      view.setNeedsLayout()
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    for sample in samples {
      sample.background.layer.borderColor =
        UIColor.separator.resolvedColor(with: traitCollection).cgColor
      do {
        let foreground = try Palette(background: sample.background, forView: sample.label)
          .contrastingColor()
        sample.label.textColor = foreground
        let text = "\(sample.name)\n\(foreground == .black ? "Black" : "White") foreground"
        if sample.label.text != text {
          sample.label.text = text
        }
      } catch {
        sample.label.textColor = .label
        assertionFailure("Unable to sample the example background: \(error)")
      }
    }
  }
}
