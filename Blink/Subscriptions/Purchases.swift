////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

import Combine
import Foundation
import SystemConfiguration

import Purchases
import BlinkConfig

public class AppStoreEntitlementsSource: NSObject, EntitlementsSource, PurchasesDelegate {
  public weak var delegate: EntitlementsSourceDelegate?
  
  public func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
    var dict = Dictionary<String, Entitlement>()
    for (key, value) in purchaserInfo.entitlements.all {      
      dict[key] = Entitlement(
        id: value.identifier,
        active: value.isActive,
        unlockProductID: value.productIdentifier
      )
    }
    delegate?.didUpdateEntitlements(
      source: self,
      entitlements: dict,
      activeSubscriptions: purchaserInfo.activeSubscriptions,
      nonSubscriptionTransactions: Set(purchaserInfo.nonSubscriptionTransactions.map({$0.productId}))
    )
  }
  
  public func startUpdates() {
    Purchases.shared.delegate = self
  }
}


func configureRevCat() {
  Purchases.logLevel = .debug
  Purchases.configure(
    withAPIKey: XCConfig.infoPlistRevCatPubliKey(),
    appUserID: nil,
    observerMode: false,
    userDefaults: UserDefaults.suite
  )
  print("RevCat UserID is \(Purchases.shared.appUserID)")
}
