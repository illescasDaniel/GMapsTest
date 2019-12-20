// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum MainMapView {
    internal enum Location {
      /// Latitude
      internal static let latitude = L10n.tr("Localizable", "**MainMapView.location.latitude**")
      /// Longitude
      internal static let longitude = L10n.tr("Localizable", "**MainMapView.location.longitude**")
    }
    internal enum Place {
      /// Address
      internal static let address = L10n.tr("Localizable", "**MainMapView.place.address**")
      /// City
      internal static let city = L10n.tr("Localizable", "**MainMapView.place.city**")
      /// Place
      internal static let place = L10n.tr("Localizable", "**MainMapView.place.place**")
    }
    internal enum ResourceAttributes {
      /// Allow drop off
      internal static let allowDropOff = L10n.tr("Localizable", "**MainMapView.resourceAttributes.allowDropOff**")
      /// Available resources
      internal static let availableResources = L10n.tr("Localizable", "**MainMapView.resourceAttributes.availableResources**")
      /// Available bikes
      internal static let bikesAvailable = L10n.tr("Localizable", "**MainMapView.resourceAttributes.bikesAvailable**")
      /// Engine type
      internal static let engineType = L10n.tr("Localizable", "**MainMapView.resourceAttributes.engineType**")
      /// Helmets
      internal static let helmets = L10n.tr("Localizable", "**MainMapView.resourceAttributes.helmets**")
      /// License plate
      internal static let licensePlate = L10n.tr("Localizable", "**MainMapView.resourceAttributes.licensePlate**")
      /// Model
      internal static let model = L10n.tr("Localizable", "**MainMapView.resourceAttributes.model**")
      /// Price per minute driving
      internal static let pricePerMinuteDriving = L10n.tr("Localizable", "**MainMapView.resourceAttributes.pricePerMinuteDriving**")
      /// Price per minute parking
      internal static let pricePerMinuteParking = L10n.tr("Localizable", "**MainMapView.resourceAttributes.pricePerMinuteParking**")
      /// Seats
      internal static let seats = L10n.tr("Localizable", "**MainMapView.resourceAttributes.seats**")
      /// Available spaces
      internal static let spacesAvailable = L10n.tr("Localizable", "**MainMapView.resourceAttributes.spacesAvailable**")
      /// Station
      internal static let station = L10n.tr("Localizable", "**MainMapView.resourceAttributes.station**")
      /// Type
      internal static let type = L10n.tr("Localizable", "**MainMapView.resourceAttributes.type**")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: BundleToken.bundle, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
